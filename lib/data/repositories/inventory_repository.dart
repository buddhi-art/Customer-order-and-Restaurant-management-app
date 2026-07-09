import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/inventory_item.dart';

/// All inventory-related Supabase calls live here.
class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> stream() {
    return _client.from('inventory').stream(primaryKey: ['id']).order('name');
  }

  Future<void> insert(InventoryItem item) async {
    await _client.from('inventory').insert({
      'id': item.id,
      'name': item.name,
      'category': item.category,
      'current_stock': item.currentStock,
      'min_stock': item.minStock,
      'unit': item.unit,
      'cost_per_unit': item.costPerUnit,
    });
  }

  Future<void> updateFields(InventoryItem item) async {
    await _client
        .from('inventory')
        .update({
          'name': item.name,
          'category': item.category,
          'current_stock': item.currentStock,
          'min_stock': item.minStock,
          'unit': item.unit,
          'cost_per_unit': item.costPerUnit,
        })
        .eq('id', item.id);
  }

  Future<void> delete(String id) async {
    await _client.from('inventory').delete().eq('id', id);
  }

  Future<void> setStock(String id, double newStock) async {
    await _client
        .from('inventory')
        .update({'current_stock': newStock})
        .eq('id', id);
  }

  static InventoryItem parseItem(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0,
      minStock: (json['min_stock'] as num?)?.toDouble() ?? 10,
      unit: json['unit'] as String? ?? 'units',
      costPerUnit: (json['cost_per_unit'] as num?)?.toDouble() ?? 0,
    );
  }
}
