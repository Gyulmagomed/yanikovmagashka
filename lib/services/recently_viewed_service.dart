import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/services/product_service.dart';

class RecentlyViewedService extends ChangeNotifier {
  RecentlyViewedService._();
  static final RecentlyViewedService _instance = RecentlyViewedService._();
  static RecentlyViewedService get instance => _instance;

  static const _key = 'yanikov_recently_viewed';
  static const _maxCount = 6;
  final List<String> _ids = [];

  List<String> get ids => List.unmodifiable(_ids);

  List<Product> get products {
    final result = <Product>[];
    for (final id in _ids) {
      final p = ProductService.instance.byId(id) ?? Product.byId(id);
      if (p != null) result.add(p);
    }
    return result;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids.clear();
    _ids.addAll(prefs.getStringList(_key) ?? []);
    notifyListeners();
  }

  Future<void> add(String productId) async {
    _ids.remove(productId);
    _ids.insert(0, productId);
    if (_ids.length > _maxCount) _ids.removeLast();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids);
    notifyListeners();
  }

  Future<void> clear() async {
    _ids.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }
}
