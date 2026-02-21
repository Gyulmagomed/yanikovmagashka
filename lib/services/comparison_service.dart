import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/services/product_service.dart';

class ComparisonService extends ChangeNotifier {
  ComparisonService._();
  static final ComparisonService _instance = ComparisonService._();
  static ComparisonService get instance => _instance;

  static const _key = 'yanikov_comparison';
  static const _maxCount = 4;
  final List<String> _ids = [];

  List<String> get ids => List.unmodifiable(_ids);

  bool isInComparison(String productId) => _ids.contains(productId);

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids);
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids.clear();
    _ids.addAll(prefs.getStringList(_key) ?? []);
    notifyListeners();
  }

  Future<void> add(String productId) async {
    if (_ids.contains(productId)) return;
    if (_ids.length >= _maxCount) _ids.removeLast();
    _ids.insert(0, productId);
    await _save();
  }

  Future<void> remove(String productId) async {
    _ids.remove(productId);
    await _save();
  }

  Future<void> toggle(String productId) async {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      if (_ids.length >= _maxCount) _ids.removeLast();
      _ids.insert(0, productId);
    }
    await _save();
  }

  Future<void> clear() async {
    _ids.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }

  List<Product> get products {
    final result = <Product>[];
    for (final id in _ids) {
      final p = ProductService.instance.byId(id) ?? Product.byId(id);
      if (p != null) result.add(p);
    }
    return result;
  }
}
