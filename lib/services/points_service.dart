import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsService extends ChangeNotifier {
  PointsService._();
  static final PointsService _instance = PointsService._();
  static PointsService get instance => _instance;

  static const _keyUserId = 'yanikov_points_user_id';
  static const _keyPoints = 'yanikov_points_balance';

  String? _userId;
  int _points = 0;
  bool _loaded = false;

  String get userId => _userId ?? '';
  int get points => _points;
  bool get isLoaded => _loaded;

  /// Данные для QR-кода (формат для сканирования в магазине)
  String get qrData => 'YANIKOV-BONUS:$userId';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_keyUserId);
    if (_userId == null || _userId!.isEmpty) {
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
      await prefs.setString(_keyUserId, _userId!);
    }
    _points = prefs.getInt(_keyPoints) ?? 0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> addPoints(int amount) async {
    if (amount <= 0) return;
    _points += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _points);
    notifyListeners();
  }

  Future<void> spendPoints(int amount) async {
    if (amount <= 0 || amount > _points) return;
    _points -= amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _points);
    notifyListeners();
  }

  /// Начисление баллов за заказ (например, 1 балл за каждые 100 ₽)
  Future<void> addPointsForOrder(int orderTotalRubles) async {
    final earned = (orderTotalRubles / 100).floor();
    if (earned > 0) await addPoints(earned);
  }
}
