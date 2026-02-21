import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/supabase_config.dart';

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService _instance = CartService._();
  static CartService get instance => _instance;

  static const _key = 'yanikov_cart';
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.fold(0, (s, e) => s + e.quantity);

  int get totalRaw {
    int sum = 0;
    for (final e in _items) {
      final num = e.price.replaceAll(RegExp(r'[^\d]'), '');
      sum += (int.tryParse(num) ?? 0) * e.quantity;
    }
    return sum;
  }

  String get totalSum {
    final sum = totalRaw;
    final str = sum.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '${buf.toString()} ₽';
  }

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
    final list = prefs.getStringList(_key) ?? [];
    _items.clear();
    for (final s in list) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      _items.add(CartItem(
        productId: map['productId'] as String,
        title: map['title'] as String,
        price: map['price'] as String,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      ));
    }
    notifyListeners();
  }

  Future<void> _loadFromSupabase() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final res = await Supabase.instance.client
          .from('user_cart')
          .select()
          .eq('user_id', uid);

      _items.clear();
      for (final row in res as List) {
        final map = row as Map<String, dynamic>;
        _items.add(CartItem(
          productId: map['product_id'] as String,
          title: map['title'] as String,
          price: map['price'] as String,
          quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('CartService: ошибка загрузки из Supabase: $e');
      await _loadLocal();
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _items.map((e) => jsonEncode({
      'productId': e.productId,
      'title': e.title,
      'price': e.price,
      'quantity': e.quantity,
    })).toList();
    await prefs.setStringList(_key, list);
    notifyListeners();
  }

  Future<void> add(Product product, {int quantity = 1}) async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        final existing = _items.indexWhere((e) => e.productId == product.id);
        final newQty = existing >= 0 ? _items[existing].quantity + quantity : quantity;

        await Supabase.instance.client.from('user_cart').upsert({
          'user_id': uid,
          'product_id': product.id,
          'title': product.title,
          'price': product.price,
          'quantity': newQty,
        }, onConflict: 'user_id,product_id');
        await _loadFromSupabase();
        return;
      } catch (e) {
        debugPrint('CartService: ошибка Supabase: $e');
      }
    }

    final i = _items.indexWhere((e) => e.productId == product.id);
    if (i >= 0) {
      _items[i] = CartItem(
        productId: _items[i].productId,
        title: _items[i].title,
        price: _items[i].price,
        quantity: _items[i].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        productId: product.id,
        title: product.title,
        price: product.price,
        quantity: quantity,
      ));
    }
    await _saveLocal();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final uid = _userId;

    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client
            .from('user_cart')
            .delete()
            .eq('user_id', uid)
            .eq('product_id', item.productId);
        _items.removeAt(index);
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('CartService: ошибка удаления из Supabase: $e');
      }
    }

    _items.removeAt(index);
    await _saveLocal();
  }

  Future<void> clear() async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client
            .from('user_cart')
            .delete()
            .eq('user_id', uid);
        _items.clear();
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('CartService: ошибка очистки Supabase: $e');
      }
    }
    _items.clear();
    await _saveLocal();
  }
}
