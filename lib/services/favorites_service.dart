import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/services/product_service.dart';
import 'package:telemost12_app/supabase_config.dart';

class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService _instance = FavoritesService._();
  static FavoritesService get instance => _instance;

  static const _key = 'yanikov_favorites';
  final List<String> _ids = [];

  List<String> get ids => List.unmodifiable(_ids);
  bool isFavorite(String productId) => _ids.contains(productId);

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> load() async {
    if (_userId != null && SupabaseConfig.isConfigured) {
      await _loadFromSupabase();
      return;
    }
    await _loadLocal();
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _ids.clear();
    _ids.addAll(prefs.getStringList(_key) ?? []);
    notifyListeners();
  }

  Future<void> _loadFromSupabase() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final res = await Supabase.instance.client
          .from('user_favorites')
          .select('product_id')
          .eq('user_id', uid);

      _ids.clear();
      for (final row in res as List) {
        final map = row as Map<String, dynamic>;
        final id = map['product_id'] as String?;
        if (id != null) _ids.add(id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('FavoritesService: ошибка загрузки из Supabase: $e');
      await _loadLocal();
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids);
    notifyListeners();
  }

  Future<void> toggle(String productId) async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        if (_ids.contains(productId)) {
          await Supabase.instance.client
              .from('user_favorites')
              .delete()
              .eq('user_id', uid)
              .eq('product_id', productId);
          _ids.remove(productId);
        } else {
          await Supabase.instance.client.from('user_favorites').insert({
            'user_id': uid,
            'product_id': productId,
          });
          _ids.add(productId);
        }
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('FavoritesService: ошибка Supabase: $e');
      }
    }

    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    await _saveLocal();
  }

  List<Product> getFavorites() {
    final result = <Product>[];
    for (final id in _ids) {
      final p = ProductService.instance.byId(id) ?? Product.byId(id);
      if (p != null) result.add(p);
    }
    return result;
  }

  List<Product> filterFeatured() => getFavorites();
}
