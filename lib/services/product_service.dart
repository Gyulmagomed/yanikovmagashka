import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/supabase_config.dart';

/// Сервис товаров. Загружает из Supabase, при отсутствии — из локальных данных.
class ProductService extends ChangeNotifier {
  ProductService._();
  static final ProductService _instance = ProductService._();
  static ProductService get instance => _instance;

  List<Product> _products = [];
  bool _loaded = false;
  bool _useSupabase = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);
  bool get loaded => _loaded;
  bool get useSupabase => _useSupabase;
  String? get error => _error;

  List<Product> get featured {
    if (_products.isEmpty) return Product.featured;
    return _products.take(4).toList();
  }

  List<Product> byCategory(String category) {
    if (_products.isEmpty) return Product.byCategory(category);
    return _products.where((p) => p.category == category).toList();
  }

  Product? byId(String id) {
    if (_products.isNotEmpty) {
      try {
        return _products.firstWhere((p) => p.id == id);
      } catch (_) {}
    }
    return Product.byId(id);
  }

  /// Товары из той же категории (кроме текущего), для блока "Похожие товары"
  List<Product> similarTo(Product product, {int limit = 4}) {
    final list = byCategory(product.category).where((p) => p.id != product.id).toList();
    return list.take(limit).toList();
  }

  List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _products.isNotEmpty ? _products : Product.all;
    final list = _products.isNotEmpty ? _products : Product.all;
    return list.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  Future<void> reload() async {
    _loaded = false;
    await load();
  }

  Future<void> load() async {
    if (_loaded) return;
    if (!SupabaseConfig.isConfigured) {
      _products = Product.all;
      _loaded = true;
      notifyListeners();
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      if (response != null && response is List && response.isNotEmpty) {
        _products = (response as List)
            .map((r) => _productFromRow(r as Map<String, dynamic>))
            .toList();
        _useSupabase = true;
        debugPrint('ProductService: загружено ${_products.length} товаров из Supabase');
      } else {
        _products = Product.all;
        debugPrint('ProductService: таблица products пуста, показываем локальные товары');
      }
      _error = null;
    } catch (e, st) {
      _products = Product.all;
      _useSupabase = false;
      _error = e.toString();
      debugPrint('ProductService: ошибка загрузки из Supabase: $e');
      debugPrint('ProductService: $st');
    }
    _loaded = true;
    notifyListeners();
  }

  Product _productFromRow(Map<String, dynamic> r) {
    final sizes = r['sizes'];
    return Product(
      id: r['id']?.toString() ?? '',
      title: r['title'] as String? ?? '',
      price: _formatPrice((r['price'] as num?)?.toDouble() ?? 0),
      category: r['category'] as String? ?? Product.catClothing,
      description: r['description'] as String?,
      sizes: sizes != null
          ? (sizes as List).map((e) => e.toString()).toList()
          : null,
      imageUrl: r['image_url'] as String?,
    );
  }

  /// Храним цену в рублях — конвертация при отображении через CurrencyService
  String _formatPrice(double value) {
    final str = value.toInt().toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '${buf.toString()} ₽';
  }
}
