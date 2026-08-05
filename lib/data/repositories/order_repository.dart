import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/cart_item.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';

/// All order-related Supabase calls live here.
class OrderRepository {
  final SupabaseClient _client;

  OrderRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Realtime stream of orders, filtered by [since] (created_at >= since).
  ///
  /// Pass a today's-midnight ISO-8601 string to limit the stream to today.
  Stream<List<Map<String, dynamic>>> stream({String? since}) {
    var query = _client.from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(500);
    // The supabase stream API does not accept `.gte` for filtering;
    // we filter client-side in the provider. Limiting to 500 ensures we don't fetch history unbounded.
    return query;
  }

  /// Insert a new order.
  Future<void> insert(AppOrder order) async {
    final itemsJson = order.items
        .map(
          (cartItem) => {
            'item_id': cartItem.item.id,
            'name': cartItem.item.name,
            'quantity': cartItem.quantity,
            'size': cartItem.size,
            'milk_type': cartItem.milkType,
            'price': cartItem.item.price,
          },
        )
        .toList();

    final parsedTableId = int.tryParse(
      order.tableId.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    await _client.from('orders').insert({
      'id': order.id,
      'table_id': parsedTableId,
      'user_id': _client.auth.currentUser?.id,
      'status': order.status.name,
      'total_amount': order.totalAmount,
      'items': itemsJson,
      'payment_method': order.paymentMethod,
      'payment_status': order.paymentStatus,
    });
  }

  /// Update the status (and payment_status when transitioning to `paid`)
  /// of a single order.
  ///
  /// Throws if the row was not updated (e.g. RLS rejected it).
  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    final updateMap = <String, dynamic>{'status': newStatus.name};
    if (newStatus == OrderStatus.paid) {
      updateMap['payment_status'] = 'paid';
    }
    final res = await _client
        .from('orders')
        .update(updateMap)
        .eq('id', orderId)
        .select();
    if (res.isEmpty) {
      throw Exception('Database update failed (Check Supabase RLS policies!)');
    }
  }

  Future<void> updatePaymentMethod(String orderId, String method) async {
    await _client
        .from('orders')
        .update({'payment_method': method})
        .eq('id', orderId);
  }

  /// Parse a raw `orders` row into an [AppOrder].
  static AppOrder parseOrder(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final parsedItems = itemsJson.map((i) {
      return CartItem(
        item: MenuItem(
          id: i['item_id'] ?? '',
          name: i['name'] ?? '',
          price: (i['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: '',
          description: '',
          category: 'Coffee',
          rating: 0.0,
          volumeMl: 0,
        ),
        quantity: i['quantity'] ?? 1,
        size: i['size'] ?? 'Medium',
        milkType: i['milk_type'] ?? 'Whole Milk',
      );
    }).toList();

    final rawTableId = json['table_id'];
    final tableIdStr = rawTableId != null ? 'table_$rawTableId' : '';

    return AppOrder(
      id: json['id'] ?? '',
      tableId: tableIdStr,
      items: parsedItems,
      status: _parseStatus(json['status'] ?? 'pending'),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
    );
  }

  static OrderStatus _parseStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'prep':
        return OrderStatus.prep;
      case 'ready':
        return OrderStatus.ready;
      case 'served':
        return OrderStatus.served;
      case 'paid':
        return OrderStatus.paid;
      default:
        return OrderStatus.pending;
    }
  }
}
