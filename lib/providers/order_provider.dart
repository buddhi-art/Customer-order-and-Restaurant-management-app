import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/order_repository.dart';
import '../models/order.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(),
);

class OrderNotifier extends Notifier<List<AppOrder>> {
  StreamSubscription<List<Map<String, dynamic>>>? _orderSubscription;
  Timer? _midnightTimer;
  late final OrderRepository _repo;

  @override
  List<AppOrder> build() {
    _repo = ref.read(orderRepositoryProvider);
    _listenToOrders();
    ref.onDispose(() {
      _orderSubscription?.cancel();
      _midnightTimer?.cancel();
    });
    return <AppOrder>[];
  }

  void _listenToOrders() {
    // Only show today's orders on initial load. We filter client-side because
    // the supabase stream() API doesn't accept `.gte()`. The cutoff is
    // recomputed each time this runs, and a timer re-runs it at the next local
    // midnight so a long-open dashboard advances its "today" window instead of
    // freezing the boundary at build time.
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    _scheduleMidnightRefresh(now);

    _orderSubscription?.cancel();
    _orderSubscription = _repo.stream().listen(
      (List<Map<String, dynamic>> data) {
        final todays = data.where((row) {
          final createdAt = DateTime.tryParse(
            row['created_at'] as String? ?? '',
          );
          return createdAt != null && !createdAt.isBefore(todayMidnight);
        }).toList();

        final loadedOrders = todays
            .map<AppOrder>(OrderRepository.parseOrder)
            .toList();

        state = loadedOrders;
      },
      onError: (error) {
        debugPrint('Order stream error: $error');
        // Keep existing state on error — don't clear orders
      },
    );
  }

  void _scheduleMidnightRefresh(DateTime now) {
    _midnightTimer?.cancel();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), _listenToOrders);
  }

  Future<void> addOrder(AppOrder order) async {
    await _repo.insert(order);
    // Optimistically add so id-based lookups (OrderStatusScreen) resolve
    // immediately, before the realtime stream echoes the insert. The next
    // stream snapshot replaces state wholesale and reconciles this entry.
    if (state.every((o) => o.id != order.id)) {
      state = [...state, order];
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _repo.updateStatus(orderId, newStatus);
    } catch (e) {
      debugPrint('Error updating order: $e');
      rethrow;
    }
  }

  Future<void> updatePaymentMethod(String orderId, String method) async {
    try {
      await _repo.updatePaymentMethod(orderId, method);
    } catch (e) {
      debugPrint('Error updating payment method: $e');
      rethrow;
    }
  }

  List<AppOrder> getOrdersByStatus(OrderStatus status) {
    return state.where((element) => element.status == status).toList();
  }
}

final orderProvider = NotifierProvider<OrderNotifier, List<AppOrder>>(
  OrderNotifier.new,
);
