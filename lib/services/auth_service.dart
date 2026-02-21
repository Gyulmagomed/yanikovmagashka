import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/supabase_config.dart';

/// Сервис авторизации. Использует Supabase Auth при наличии конфига, иначе — локальное хранилище.
class AuthService {
  static const _keyUsers = 'yanikov_users';
  static const _keyCurrentUser = 'yanikov_current_user';

  /// Текущий пользователь (имя, email). null = не авторизован.
  static Future<Map<String, String>?> getCurrentUser() async {
    if (SupabaseConfig.isConfigured) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final meta = session.user.userMetadata;
        final name = meta?['name'] as String? ?? session.user.email?.split('@').first ?? 'Пользователь';
        return {
          'name': name,
          'email': session.user.email ?? '',
        };
      }
      return null;
    }
    // Локальный режим: читаем сохранённую сессию
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyCurrentUser);
    if (json != null) {
      try {
        return Map<String, String>.from(jsonDecode(json) as Map);
      } catch (_) {}
    }
    return null;
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (SupabaseConfig.isConfigured) {
      await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
      // Supabase сохраняет сессию автоматически
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyUsers) ?? [];
    final users = list.map((e) => Map<String, String>.from(jsonDecode(e) as Map)).toList();
    users.add({
      'name': name.trim(),
      'email': email.toLowerCase().trim(),
      'password': password,
    });
    await prefs.setStringList(
      _keyUsers,
      users.map((e) => jsonEncode(e)).toList(),
    );
    final emailClean = email.toLowerCase().trim();
    await _saveCurrentUserLocal(name.trim(), emailClean);
  }

  static Future<Map<String, String>?> login({
    required String email,
    required String password,
  }) async {
    if (SupabaseConfig.isConfigured) {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.session == null) return null;
      final meta = res.user!.userMetadata;
      final name = meta?['name'] as String? ?? res.user!.email?.split('@').first ?? 'Пользователь';
      return {'name': name, 'email': res.user!.email ?? ''};
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyUsers) ?? [];
    final emailClean = email.toLowerCase().trim();
    for (final s in list) {
      final user = jsonDecode(s) as Map<String, dynamic>;
      if ((user['email'] as String?) == emailClean &&
          (user['password'] as String?) == password) {
        final u = {'name': user['name'] as String, 'email': user['email'] as String};
        await _saveCurrentUserLocal(u['name']!, u['email']!);
        return u;
      }
    }
    return null;
  }

  static Future<void> _saveCurrentUserLocal(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUser, jsonEncode({'name': name, 'email': email}));
  }

  static Future<void> logout() async {
    if (SupabaseConfig.isConfigured) {
      await Supabase.instance.client.auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
  }

  /// Удаление аккаунта: вызов Edge Function (если есть), затем выход и очистка локальных данных.
  /// Бросает исключение с сообщением при ошибке.
  static Future<void> deleteAccount() async {
    if (SupabaseConfig.isConfigured) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          throw Exception('Сначала войдите в аккаунт');
        }
        final res = await Supabase.instance.client.functions.invoke(
          'delete-user',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        );
        if (res.status != 200) {
          final msg = res.data is Map ? (res.data as Map)['error']?.toString() : null;
          throw Exception(msg ?? 'Не удалось удалить аккаунт (код ${res.status})');
        }
        if (res.data is Map && (res.data as Map)['error'] != null) {
          throw Exception((res.data as Map)['error'].toString());
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Не удалось удалить аккаунт. Обратитесь в поддержку support@yanikov.ru');
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyCurrentUser);
      if (json != null) {
        try {
          final user = Map<String, String>.from(jsonDecode(json) as Map);
          final email = user['email'];
          final list = prefs.getStringList(_keyUsers) ?? [];
          final filtered = list.where((e) {
            try {
              final u = jsonDecode(e) as Map<String, dynamic>;
              return u['email'] != email;
            } catch (_) {
              return true;
            }
          }).toList();
          await prefs.setStringList(_keyUsers, filtered);
        } catch (_) {}
      }
    }
    await logout();
  }
}
