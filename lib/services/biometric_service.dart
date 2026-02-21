import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:telemost12_app/services/locale_service.dart';

class BiometricService extends ChangeNotifier {
  BiometricService._();
  static final BiometricService _instance = BiometricService._();
  static BiometricService get instance => _instance;

  static const _keyEnabled = 'yanikov_biometric_enabled';
  final LocalAuthentication _auth = LocalAuthentication();

  bool _enabled = false;
  List<BiometricType> _availableTypes = [];

  bool get enabled => _enabled;
  List<BiometricType> get availableTypes => List.unmodifiable(_availableTypes);

  /// Отпечаток пальца доступен
  bool get hasFingerprint => _availableTypes.contains(BiometricType.fingerprint) ||
      _availableTypes.contains(BiometricType.weak);

  Future<bool> get isDeviceSupported async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> get canCheckBiometrics async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isAvailable async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      _availableTypes = await _auth.getAvailableBiometrics();
      return _availableTypes.isNotEmpty || supported;
    } catch (_) {
      return false;
    }
  }

  Future<void> refreshAvailableBiometrics() async {
    try {
      _availableTypes = await _auth.getAvailableBiometrics();
      notifyListeners();
    } catch (_) {
      _availableTypes = [];
      notifyListeners();
    }
  }

  Future<bool> authenticate() async {
    try {
      final options = Platform.isAndroid
          ? const AuthenticationOptions(
              biometricOnly: false,
              useErrorDialogs: true,
              sensitiveTransaction: false,
              stickyAuth: true,
            )
          : const AuthenticationOptions(
              biometricOnly: false,
              useErrorDialogs: true,
              sensitiveTransaction: true,
              stickyAuth: true,
            );
      return await _auth.authenticate(
        localizedReason: AppLocalizations.s(LocaleService.instance.locale, 'biometric_reason'),
        authMessages: _authMessages,
        options: options,
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e, st) {
      debugPrint('Biometric auth error: $e\n$st');
      return false;
    }
  }

  Iterable<AuthMessages> get _authMessages {
    final locale = LocaleService.instance.locale;
    String s(String k) => AppLocalizations.s(locale, k);
    if (Platform.isIOS || Platform.isMacOS) {
      return [
        IOSAuthMessages(
          cancelButton: s('cancel'),
          goToSettingsButton: s('settings'),
          goToSettingsDescription: s('biometric_touch_id'),
          lockOut: s('biometric_lock_out'),
          localizedFallbackTitle: s('biometric_fallback'),
        ),
      ];
    }
    if (Platform.isAndroid) {
      return [
        AndroidAuthMessages(
          signInTitle: s('biometric_sign_in'),
          cancelButton: s('cancel'),
          biometricHint: s('biometric_hint'),
          biometricNotRecognized: s('biometric_not_recognized'),
          biometricRequiredTitle: s('biometric_required'),
          goToSettingsButton: s('settings'),
          goToSettingsDescription: s('biometric_add_fingerprint'),
          deviceCredentialsRequiredTitle: s('biometric_pin_required'),
          deviceCredentialsSetupDescription: s('biometric_setup_pin'),
        ),
      ];
    }
    return const <AuthMessages>[
      IOSAuthMessages(),
      AndroidAuthMessages(),
    ];
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_keyEnabled) ?? false;
    try {
      _availableTypes = await _auth.getAvailableBiometrics();
    } catch (_) {
      _availableTypes = [];
    }
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
    if (value) {
      await refreshAvailableBiometrics();
    }
    notifyListeners();
  }
}
