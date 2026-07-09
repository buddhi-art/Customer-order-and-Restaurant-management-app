import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cart_item.dart';
import '../../models/menu_item.dart';

/// Persists the shopping cart to `SharedPreferences` with an expiry stamp.
///
/// Cart entries are stored as a list of *skeleton* items (id/name/price/etc.)
/// plus a `cart_saved_at` ISO-8601 timestamp. On load, items older than
/// `maxAge` are discarded — by design, the cart should not survive a long
/// pause in the app.
class CartRepository {
  /// Maximum age of a stored cart, after which it is treated as stale.
  static const Duration maxAge = Duration(hours: 2);

  static const _itemsKey = 'cart_items';
  static const _savedAtKey = 'cart_saved_at';

  /// Read the timestamp the cart was last saved at (or null if never).
  Future<DateTime?> readSavedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Persist the cart to prefs and update the `cart_saved_at` timestamp.
  Future<void> save(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items
        .map(
          (item) => {
            'item_id': item.item.id,
            'item_name': item.item.name,
            'item_price': item.item.price,
            'item_category': item.item.category,
            'item_image': item.item.imageUrl,
            'quantity': item.quantity,
            'size': item.size,
            'milk_type': item.milkType,
          },
        )
        .toList();
    await prefs.setString(_itemsKey, jsonEncode(jsonList));
    await prefs.setString(_savedAtKey, DateTime.now().toIso8601String());
  }

  /// Read skeleton cart items from prefs.
  ///
  /// Returns `null` if no cart has been saved yet, and an empty list if the
  /// stored data is corrupted.
  Future<List<CartItem>?> readSkeleton() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
      return jsonList.map((j) {
        final map = j as Map<String, dynamic>;
        return CartItem(
          item: MenuItem(
            id: map['item_id']?.toString() ?? '',
            name: map['item_name']?.toString() ?? '',
            price: (map['item_price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: map['item_image']?.toString() ?? '',
            description: '',
            category: map['item_category']?.toString() ?? 'Coffee',
            rating: 0.0,
            volumeMl: 0,
          ),
          quantity: map['quantity'] as int? ?? 1,
          size: map['size']?.toString() ?? 'Medium',
          milkType: map['milk_type']?.toString() ?? 'Whole Milk',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading cart from prefs: $e');
      return <CartItem>[];
    }
  }

  /// Wipe the cart from prefs entirely.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey);
    await prefs.remove(_savedAtKey);
  }
}
