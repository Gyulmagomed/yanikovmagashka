import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/models/order.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:telemost12_app/supabase_config.dart';

class OrdersService extends ChangeNotifier {
  OrdersService._();
  static final OrdersService _instance = OrdersService._();
  static OrdersService get instance => _instance;

  static const _key = 'yanikov_orders';
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  int get totalSpent => _orders.fold(0, (s, o) => s + o.totalRubles);
  String get totalSpentFormatted => CurrencyService.instance.format(totalSpent);

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
    _orders.clear();
    for (final s in list) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      _orders.insert(0, Order(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        itemsSummary: map['itemsSummary'] as String,
        total: map['total'] as String,
        totalRubles: (map['totalRubles'] as num?)?.toInt() ?? CurrencyService.parseRubles(map['total'] as String? ?? '0'),
        addressLabel: map['addressLabel'] as String?,
      ));
    }
    notifyListeners();
  }

  Future<void> _loadFromSupabase() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final res = await Supabase.instance.client
          .from('user_orders')
          .select()
          .eq('user_id', uid)
          .order('date', ascending: false);

      _orders.clear();
      for (final row in res as List) {
        final map = row as Map<String, dynamic>;
        _orders.add(Order(
          id: map['order_id'] as String,
          date: DateTime.parse(map['date'] as String),
          itemsSummary: map['items_summary'] as String,
          total: map['total'] as String,
          totalRubles: (map['total_rubles'] as num?)?.toInt() ?? 0,
          addressLabel: map['address_label'] as String?,
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('OrdersService: ошибка загрузки из Supabase: $e');
      await _loadLocal();
    }
  }

  Future<void> add({
    required String itemsSummary,
    required String total,
    required int totalRubles,
    String? addressLabel,
  }) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final order = Order(
      id: orderId,
      date: DateTime.now(),
      itemsSummary: itemsSummary,
      total: total,
      totalRubles: totalRubles,
      addressLabel: addressLabel,
    );

    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.from('user_orders').insert({
          'user_id': uid,
          'order_id': orderId,
          'date': order.date.toIso8601String(),
          'items_summary': itemsSummary,
          'total': total,
          'total_rubles': totalRubles,
          'address_label': addressLabel,
        });
        _orders.insert(0, order);
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('OrdersService: ошибка добавления в Supabase: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.insert(0, jsonEncode({
      'id': order.id,
      'date': order.date.toIso8601String(),
      'itemsSummary': order.itemsSummary,
      'total': order.total,
      'totalRubles': order.totalRubles,
      'addressLabel': order.addressLabel,
    }));
    await prefs.setStringList(_key, list);
    _orders.insert(0, order);
    notifyListeners();
  }
}
