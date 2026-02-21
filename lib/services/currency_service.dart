import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService extends ChangeNotifier {
  CurrencyService._();
  static final CurrencyService _instance = CurrencyService._();
  static CurrencyService get instance => _instance;

  static const _keyCurrency = 'yanikov_currency';

  String _currencyCode = 'RUB';
  String get currencyCode => _currencyCode;

  /// Курсы к рублю (1 единица валюты = X рублей)
  static const _ratesToRub = {
    'RUB': 1.0,
    'USD': 100.0,  // 1 USD = 100 RUB
    'EUR': 110.0,  // 1 EUR = 110 RUB
  };

  static const supportedCurrencies = ['RUB', 'USD', 'EUR'];

  static const currencyNames = {
    'RUB': 'Рубли (₽)',
    'USD': 'Доллары (\$)',
    'EUR': 'Евро (€)',
  };

  static const currencySymbols = {
    'RUB': '₽',
    'USD': '\$',
    'EUR': '€',
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString(_keyCurrency) ?? 'RUB';
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    if (!supportedCurrencies.contains(code)) return;
    _currencyCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, code);
    notifyListeners();
  }

  /// Парсит строку цены в рубли (число)
  static int parseRubles(String priceStr) {
    final num = priceStr.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(num) ?? 0;
  }

  /// Форматирует сумму в рублях в выбранную валюту
  String format(int rubles) {
    if (rubles == 0) return '0 ${currencySymbols[_currencyCode] ?? '₽'}';
    final rate = _ratesToRub[_currencyCode] ?? 1.0;
    final value = rubles / rate;
    if (_currencyCode == 'RUB') {
      return '${_formatWithSpaces(rubles)} ₽';
    }
    if (_currencyCode == 'USD') {
      final v = value >= 1 ? value.round() : value;
      final str = v >= 1 ? _formatWithSpaces(v.round()) : value.toStringAsFixed(2);
      return '$str \$';
    }
    if (_currencyCode == 'EUR') {
      final v = value >= 1 ? value.round() : value;
      final str = v >= 1 ? _formatWithSpaces(v.round()) : value.toStringAsFixed(2);
      return '$str €';
    }
    return '${_formatWithSpaces(rubles)} ₽';
  }

  String _formatWithSpaces(int value) {
    final str = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  /// Форматирует строку цены (например "12 990 ₽") в выбранную валюту
  String formatPriceString(String priceStr) {
    return format(parseRubles(priceStr));
  }
}
