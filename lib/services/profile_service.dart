import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  ProfileService._();
  static final ProfileService _instance = ProfileService._();
  static ProfileService get instance => _instance;

  static const _keyNickname = 'yanikov_profile_nickname';
  static const _keyAvatarPath = 'yanikov_profile_avatar';
  static const _avatarFileName = 'avatar.jpg';

  String? _nickname;
  String? _avatarPath;
  int _avatarVersion = 0;

  String? get nickname => _nickname;
  String? get avatarPath => _avatarPath;
  int get avatarVersion => _avatarVersion;

  bool get hasAvatar => _avatarPath != null;

  Future<void> load(String? initialUserName) async {
    final prefs = await SharedPreferences.getInstance();
    _nickname = prefs.getString(_keyNickname) ?? initialUserName;
    _avatarPath = prefs.getString(_keyAvatarPath);
    notifyListeners();
  }

  Future<void> setNickname(String name) async {
    _nickname = name.trim().isEmpty ? null : name.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_nickname != null) {
      await prefs.setString(_keyNickname, _nickname!);
    } else {
      await prefs.remove(_keyNickname);
    }
    notifyListeners();
  }

  Future<void> setAvatarFromPath(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final destFile = File('${dir.path}/$_avatarFileName');
      await File(sourcePath).copy(destFile.path);
      _avatarPath = destFile.path;
      _avatarVersion++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAvatarPath, _avatarPath!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeAvatar() async {
    if (_avatarPath != null) {
      try {
        await File(_avatarPath!).delete();
      } catch (_) {}
      _avatarPath = null;
      _avatarVersion++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAvatarPath);
      notifyListeners();
    }
  }

  String get displayName => _nickname ?? 'Пользователь';
}
