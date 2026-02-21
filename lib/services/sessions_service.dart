import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/models/device_session.dart';
import 'package:telemost12_app/supabase_config.dart';

class SessionsService extends ChangeNotifier {
  SessionsService._();
  static final SessionsService _instance = SessionsService._();
  static SessionsService get instance => _instance;

  static const _key = 'yanikov_sessions';
  static const _currentIdKey = 'yanikov_current_session_id';
  final List<DeviceSession> _sessions = [];
  String? _currentSessionId;
  Timer? _heartbeatTimer;
  bool _sessionTerminated = false;
  bool _hasAddedSessionToSupabase = false;
  DateTime? _lastAddSessionAt;

  List<DeviceSession> get sessions => List.unmodifiable(_sessions);

  /// true если наше устройство было завершено с другого устройства
  bool get sessionTerminated => _sessionTerminated;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  /// [checkTermination] — проверять ли, что нашу сессию удалили (и выйти).
  /// false при первой загрузке после входа (избегаем ложных срабатываний).
  Future<void> load({bool checkTermination = false}) async {
    await _ensureCurrentSessionId();
    if (_userId == null || !SupabaseConfig.isConfigured) {
      await _loadLocal();
      return;
    }
    await _loadFromSupabase(checkTermination: checkTermination);
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSessionId = prefs.getString(_currentIdKey);
    final list = prefs.getStringList(_key) ?? [];
    _sessions.clear();
    for (final s in list) {
      final parts = s.split('|');
      if (parts.length >= 4) {
        _sessions.add(DeviceSession(
          id: parts[0],
          deviceName: parts[1],
          platform: parts[2],
          lastActive: DateTime.tryParse(parts[3]) ?? DateTime.now(),
          isCurrent: parts[0] == _currentSessionId,
        ));
      }
    }
    notifyListeners();
  }

  Future<void> _loadFromSupabase({bool checkTermination = false}) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      final res = await Supabase.instance.client
          .from('device_sessions')
          .select()
          .eq('user_id', uid)
          .order('last_active', ascending: false);

      _sessions.clear();
      for (final row in res as List) {
        final map = row as Map<String, dynamic>;
        final id = map['session_id'] as String? ?? '';
        _sessions.add(DeviceSession(
          id: id,
          deviceName: map['device_name'] as String? ?? 'Устройство',
          platform: map['platform'] as String? ?? 'Unknown',
          lastActive: DateTime.tryParse(map['last_active'] as String? ?? '') ?? DateTime.now(),
          isCurrent: id == _currentSessionId,
        ));
      }
      // НЕ проверяем завершение при load — только при явном действии (terminateAllOther).
      // Иначе при повторном входе возможны ложные срабатывания из-за Realtime/race.
      notifyListeners();
    } catch (e) {
      debugPrint('SessionsService: ошибка загрузки из Supabase: $e');
      await _loadLocal();
    }
  }

  Future<void> _save() async {
    if (_userId == null || !SupabaseConfig.isConfigured) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentIdKey, _currentSessionId ?? '');
      final list = _sessions.map((s) => '${s.id}|${s.deviceName}|${s.platform}|${s.lastActive.toIso8601String()}').toList();
      await prefs.setStringList(_key, list);
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  Future<void> _ensureCurrentSessionId() async {
    if (_currentSessionId != null) return;
    final prefs = await SharedPreferences.getInstance();
    _currentSessionId = prefs.getString(_currentIdKey);
    if (_currentSessionId != null) return;
    _currentSessionId = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    await prefs.setString(_currentIdKey, _currentSessionId!);
  }

  Future<void> addCurrentSession() async {
    await _ensureCurrentSessionId();

    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Устройство';
    String platform = 'Unknown';
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceName = '${android.model} (Android)';
        platform = 'Android';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceName = '${ios.name} (iOS)';
        platform = 'iOS';
      }
    } catch (_) {}

    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.from('device_sessions').upsert(
          {
            'user_id': uid,
            'session_id': _currentSessionId,
            'device_name': deviceName,
            'platform': platform,
            'last_active': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,session_id',
        );
        _hasAddedSessionToSupabase = true;
        _lastAddSessionAt = DateTime.now();
        await _loadFromSupabase();
        return;
      } catch (e) {
        debugPrint('SessionsService: ошибка добавления сессии в Supabase: $e');
      }
    }

    final existing = _sessions.indexWhere((s) => s.id == _currentSessionId);
    final session = DeviceSession(
      id: _currentSessionId!,
      deviceName: deviceName,
      platform: platform,
      lastActive: DateTime.now(),
      isCurrent: true,
    );
    final updated = <DeviceSession>[];
    if (existing >= 0) {
      for (final s in _sessions) {
        updated.add(s.id == _currentSessionId
            ? session
            : DeviceSession(
                id: s.id,
                deviceName: s.deviceName,
                platform: s.platform,
                lastActive: s.lastActive,
                isCurrent: false,
              ));
      }
    } else {
      updated.add(session);
      for (final s in _sessions) {
        updated.add(DeviceSession(
          id: s.id,
          deviceName: s.deviceName,
          platform: s.platform,
          lastActive: s.lastActive,
          isCurrent: false,
        ));
      }
    }
    _sessions.clear();
    _sessions.addAll(updated);
    await _save();
  }

  Future<void> removeSession(String id) async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client
            .from('device_sessions')
            .delete()
            .eq('user_id', uid)
            .eq('session_id', id);
        await _loadFromSupabase();
        return;
      } catch (e) {
        debugPrint('SessionsService: ошибка удаления сессии из Supabase: $e');
      }
    }

    _sessions.removeWhere((s) => s.id == id);
    if (_currentSessionId == id) _currentSessionId = null;
    await _save();
  }

  void startHeartbeat() {
    stopHeartbeat();
    if (_userId == null || !SupabaseConfig.isConfigured) return;
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      addCurrentSession();
    });
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> terminateAllOther() async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        // Удаляем ВСЕ сессии (включая текущую) — выкинет все устройства
        await Supabase.instance.client
            .from('device_sessions')
            .delete()
            .eq('user_id', uid);
        _sessions.clear();
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('SessionsService: ошибка завершения сессий в Supabase: $e');
      }
    }

    _sessions.removeWhere((s) => !s.isCurrent);
    await _save();
  }

  void clearSessionTerminated() {
    _sessionTerminated = false;
    notifyListeners();
  }

  /// Сброс при выходе — чтобы можно было войти снова
  Future<void> resetForLogout() async {
    stopHeartbeat();
    _sessionTerminated = false;
    _hasAddedSessionToSupabase = false;
    _lastAddSessionAt = null;
    _sessions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentIdKey);
    _currentSessionId = null;
    notifyListeners();
  }
}
