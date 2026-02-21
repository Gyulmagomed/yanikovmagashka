import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService extends ChangeNotifier {
  SearchHistoryService._();
  static final SearchHistoryService _instance = SearchHistoryService._();
  static SearchHistoryService get instance => _instance;

  static const _key = 'yanikov_search_history';
  static const _maxCount = 20;
  final List<String> _queries = [];

  List<String> get queries => List.unmodifiable(_queries);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _queries.clear();
    _queries.addAll(prefs.getStringList(_key) ?? []);
    notifyListeners();
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _queries.remove(trimmed);
    _queries.insert(0, trimmed);
    if (_queries.length > _maxCount) _queries.removeLast();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _queries);
    notifyListeners();
  }

  Future<void> remove(String query) async {
    _queries.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _queries);
    notifyListeners();
  }

  Future<void> clear() async {
    _queries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }
}
