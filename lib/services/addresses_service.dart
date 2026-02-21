import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/models/address.dart';
import 'package:telemost12_app/supabase_config.dart';

class AddressesService extends ChangeNotifier {
  AddressesService._();
  static final AddressesService _instance = AddressesService._();
  static AddressesService get instance => _instance;

  static const _key = 'yanikov_addresses';
  final List<Address> _addresses = [];

  List<Address> get addresses => List.unmodifiable(_addresses);

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
    _addresses.clear();
    for (final s in list) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      _addresses.add(Address(
        id: map['id'] as String,
        label: map['label'] as String,
        street: map['street'] as String,
        city: map['city'] as String,
        phone: map['phone'] as String,
      ));
    }
    notifyListeners();
  }

  Future<void> _loadFromSupabase() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final res = await Supabase.instance.client
          .from('user_addresses')
          .select()
          .eq('user_id', uid);

      _addresses.clear();
      for (final row in res as List) {
        final map = row as Map<String, dynamic>;
        _addresses.add(Address(
          id: map['address_id'] as String,
          label: map['label'] as String,
          street: map['street'] as String,
          city: map['city'] as String,
          phone: map['phone'] as String,
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AddressesService: ошибка загрузки из Supabase: $e');
      await _loadLocal();
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _addresses.map((a) => jsonEncode({
      'id': a.id,
      'label': a.label,
      'street': a.street,
      'city': a.city,
      'phone': a.phone,
    })).toList();
    await prefs.setStringList(_key, list);
    notifyListeners();
  }

  Future<void> add(Address address) async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.from('user_addresses').insert({
          'user_id': uid,
          'address_id': address.id,
          'label': address.label,
          'street': address.street,
          'city': address.city,
          'phone': address.phone,
        });
        _addresses.add(address);
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('AddressesService: ошибка Supabase: $e');
      }
    }
    _addresses.add(address);
    await _saveLocal();
  }

  Future<void> remove(String id) async {
    final uid = _userId;
    if (uid != null && SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client
            .from('user_addresses')
            .delete()
            .eq('user_id', uid)
            .eq('address_id', id);
        _addresses.removeWhere((a) => a.id == id);
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('AddressesService: ошибка удаления из Supabase: $e');
      }
    }
    _addresses.removeWhere((a) => a.id == id);
    await _saveLocal();
  }
}
