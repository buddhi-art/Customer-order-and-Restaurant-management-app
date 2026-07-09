import 'cart_item.dart';

enum OrderStatus {
  pending,
  prep,
  ready,
  served,
  paid
}

class AppOrder {
  final String id;
  final String tableId;
  final List<CartItem> items;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final String? paymentMethod;
  final String? paymentStatus;

  AppOrder({
    required this.id,
    required this.tableId,
    required this.items,
    this.status = OrderStatus.pending,
    required this.totalAmount,
    required this.createdAt,
    this.paymentMethod,
    this.paymentStatus,
  });

  AppOrder copyWith({
    String? id,
    String? tableId,
    List<CartItem>? items,
    OrderStatus? status,
    double? totalAmount,
    DateTime? createdAt,
    String? paymentMethod,
    String? paymentStatus,
  }) {
    return AppOrder(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
