import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _loadFromPrefs();
    return {};
  }

  // ── Persistence ──

  static const _prefsKey = 'favorite_ids';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await _getPrefs();
    await prefs.setString(_prefsKey, jsonEncode(state.toList()));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final List<dynamic> ids = jsonDecode(raw) as List<dynamic>;
      state = ids.map((e) => e.toString()).toSet();
    } catch (e) {
      debugPrint('Error loading favorites from prefs: $e');
    }
  }

  // ── Mutations ──

  void toggleFavorite(String id) {
    if (state.contains(id)) {
      state = state.difference({id});
    } else {
      state = state.union({id});
    }
    _saveToPrefs();
  }

  bool isFavorite(String id) {
    return state.contains(id);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
