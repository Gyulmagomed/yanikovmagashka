import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService _instance = LocaleService._();
  static LocaleService get instance => _instance;

  static const _keyLocale = 'yanikov_locale';

  Locale _locale = const Locale('ru');
  Locale get locale => _locale;

  String get localeCode => _locale.languageCode;

  static const supportedLocales = [
    Locale('ru'),
    Locale('en'),
    Locale('uk'),
    Locale('tr'),
    Locale('kk'),
  ];

  static const localeNames = {
    'ru': 'Русский',
    'en': 'English',
    'uk': 'Українська',
    'tr': 'Türkçe',
    'kk': 'Қазақша',
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocale) ?? 'ru';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
    notifyListeners();
  }
}
