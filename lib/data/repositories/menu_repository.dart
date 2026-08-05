import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/menu_item.dart';

/// All menu-related Supabase calls live here.
class MenuRepository {
  final SupabaseClient _client;

  MenuRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Realtime stream of the full `menu_items` table.
  Stream<List<Map<String, dynamic>>> stream() {
    return _client.from('menu_items').stream(primaryKey: ['item_id']);
  }

  /// One-shot fetch of a single item.
  Future<MenuItem?> fetchById(String id) async {
    final res = await _client
        .from('menu_items')
        .select()
        .eq('item_id', id)
        .maybeSingle();
    if (res == null) return null;
    return _parseMenuItem(res);
  }

  /// One-shot fetch of multiple items by id.
  Future<List<MenuItem>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final res = await _client
        .from('menu_items')
        .select()
        .inFilter('item_id', ids)
        .limit(500);
    return (res as List<dynamic>)
        .map((j) => _parseMenuItem(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> setAvailability(String id, bool isAvailable) async {
    await _client
        .from('menu_items')
        .update({'is_available': isAvailable})
        .eq('item_id', id);
  }

  /// Parse a `menu_items` row into a [MenuItem].
  ///
  /// Description is stored as `"free text # Category"`. Only the *last* `#`
  /// separates the user-visible description from the implicit category, so a
  /// `#` inside the description body no longer corrupts the split.
  static MenuItem _parseMenuItem(Map<String, dynamic> json) {
    final rawDesc = json['description']?.toString() ?? '';
    final hashIndex = rawDesc.lastIndexOf('#');
    final String description;
    final String category;
    if (hashIndex >= 0) {
      description = rawDesc.substring(0, hashIndex).trim();
      final rawCategory = rawDesc.substring(hashIndex + 1).trim();
      category = rawCategory.isNotEmpty ? rawCategory : 'Coffee';
    } else {
      description = rawDesc.trim();
      category = 'Coffee';
    }

    return MenuItem(
      id: json['item_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      description: description,
      category: category,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      volumeMl: (json['volume_ml'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] ?? true,
    );
  }

  /// Public so providers can reuse the parser.
  static MenuItem parseMenuItem(Map<String, dynamic> json) =>
      _parseMenuItem(json);
}
