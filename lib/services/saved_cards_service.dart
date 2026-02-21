import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/models/saved_card.dart';
import 'package:telemost12_app/supabase_config.dart';

class SavedCardsService extends ChangeNotifier {
  SavedCardsService._();
  static final SavedCardsService _instance = SavedCardsService._();
  static SavedCardsService get instance => _instance;

  static const _key = 'yanikov_saved_cards';
  final List<SavedCard> _cards = [];

  List<SavedCard> get cards => List.unmodifiable(_cards);

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
    _cards.clear();
    for (final s in list) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      _cards.add(SavedCard(
        id: map['id'] as String,
        last4: map['last4'] as String,
        brand: map['brand'] as String,
        expiryMonth: (map['expiryMonth'] as num).toInt(),
        expiryYear: (map['expiryYear'] as num).toInt(),
        holderName: map['holderName'] as String?,
      ));
    }
    notifyListeners();
  }

  Future<void> _loadFromSupabase() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final res = await Supabase.instance.client
          .from('user_saved_cards')
          .select()
          .eq('user_id', uid);

      _cards.clear();
      for (final row in res as List) {
        final map = row as Map<String, dynamic>;
        _cards.add(SavedCard(
          id: map['card_id'] as String,
          last4: map['last4'] as String,
          brand: map['brand'] as String,
          expiryMonth: (map['expiry_month'] as num).toInt(),
          expiryYear: (map['expiry_year'] as num).toInt(),
          holderName: map['holder_name'] as String?,
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('SavedCardsService: ошибка загрузки из Supabase: $e');
      await _loadLocal();
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _cards.map((c) => jsonEncode({
      'id': c.id,
      'last4': c.last4,
      'brand': c.brand,
      'expiryMonth': c.expiryMonth,
      'expiryYear': c.expiryYear,
      'holderName': c.holderName,
    })).toList();
    await prefs.setStringList(_key, list);
    notifyListeners();
  }

  Future<void> add(SavedCard card) async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.from('user_saved_cards').insert({
          'user_id': uid,
          'card_id': card.id,
          'last4': card.last4,
          'brand': card.brand,
          'expiry_month': card.expiryMonth,
          'expiry_year': card.expiryYear,
          'holder_name': card.holderName,
        });
        _cards.add(card);
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('SavedCardsService: ошибка Supabase: $e');
      }
    }
    _cards.add(card);
    await _saveLocal();
  }

  Future<void> remove(String id) async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client
            .from('user_saved_cards')
            .delete()
            .eq('user_id', uid)
            .eq('card_id', id);
        _cards.removeWhere((c) => c.id == id);
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('SavedCardsService: ошибка удаления из Supabase: $e');
      }
    }
    _cards.removeWhere((c) => c.id == id);
    await _saveLocal();
  }

  SavedCard? byId(String id) {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static String detectBrand(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return 'Card';
    final first = digits[0];
    if (first == '4') return 'Visa';
    if (first == '5') return 'Mastercard';
    if (first == '2') return 'Mir';
    return 'Card';
  }
}
