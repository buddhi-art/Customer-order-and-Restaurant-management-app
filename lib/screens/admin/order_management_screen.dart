import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/m3_theme.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../utils/print_receipt.dart';
import 'admin_shell.dart';

class OrderManagementScreen extends ConsumerWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AdminShell(
      title: 'Orders',
      selectedIndex: 1,
      body: Column(
        children: [
          // Status tabs
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _StatusChip(
                  label: 'Pending',
                  count: orders
                      .where((o) => o.status == OrderStatus.pending)
                      .length,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  label: 'Preparing',
                  count: orders
                      .where((o) => o.status == OrderStatus.prep)
                      .length,
                  color: CafeColors.warning,
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  label: 'Ready',
                  count: orders
                      .where((o) => o.status == OrderStatus.ready)
                      .length,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  label: 'Served',
                  count: orders
                      .where((o) => o.status == OrderStatus.served)
                      .length,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  label: 'Paid',
                  count: orders
                      .where((o) => o.status == OrderStatus.paid)
                      .length,
                  color: CafeColors.success,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Orders will appear here in real-time.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                        ),
                      ],
                    ),
                  )
                : KanbanBoard(orders: orders),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label • $count',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class KanbanBoard extends ConsumerWidget {
  final List<AppOrder> orders;
  const KanbanBoard({super.key, required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KanbanColumn(
            title: 'Pending',
            status: OrderStatus.pending,
            orders: orders
                .where((o) => o.status == OrderStatus.pending)
                .toList(),
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 20),
          _KanbanColumn(
            title: 'Preparing',
            status: OrderStatus.prep,
            orders: orders.where((o) => o.status == OrderStatus.prep).toList(),
            color: CafeColors.warning,
          ),
          const SizedBox(width: 20),
          _KanbanColumn(
            title: 'Ready',
            status: OrderStatus.ready,
            orders: orders.where((o) => o.status == OrderStatus.ready).toList(),
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 20),
          _KanbanColumn(
            title: 'Served',
            status: OrderStatus.served,
            orders: orders
                .where((o) => o.status == OrderStatus.served)
                .toList(),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 20),
          _KanbanColumn(
            title: 'Paid',
            status: OrderStatus.paid,
            orders: orders.where((o) => o.status == OrderStatus.paid).toList(),
            color: CafeColors.success,
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final OrderStatus status;
  final List<AppOrder> orders;
  final Color color;

  const _KanbanColumn({
    required this.title,
    required this.status,
    required this.orders,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      'Drag orders here',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) =>
                        _OrderCard(order: orders[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final AppOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DoubleBezelContainer(
        outerRadius: 20,
        padding: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Table ${order.tableId.replaceAll('table_', '').toUpperCase()}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.item.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.size != 'Medium') ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.size,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Action buttons row
              if (order.status != OrderStatus.paid)
                Row(
                  children: [
                    // Print Bill button — shown for served orders
                    if (order.status == OrderStatus.served) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _printBill(context),
                          icon: const Icon(Icons.print_rounded, size: 16),
                          label: const Text(
                            'Bill',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.outlineVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Details button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showOrderDetail(context, order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    // Advance button - shown for ALL statuses except paid
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _advanceOrder(context, ref),
                        style: FilledButton.styleFrom(
                          backgroundColor: _nextColor(colorScheme),
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          _nextLabel(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  OrderStatus get status => order.status;

  String _nextLabel() {
    switch (status) {
      case OrderStatus.pending:
        return 'Start Prep';
      case OrderStatus.prep:
        return 'Mark Ready';
      case OrderStatus.ready:
        return 'Mark Served';
      case OrderStatus.served:
        return 'Mark Paid';
      case OrderStatus.paid:
        return '';
    }
  }

  Color _nextColor(ColorScheme colorScheme) {
    switch (status) {
      case OrderStatus.pending:
        return CafeColors.warning;
      case OrderStatus.prep:
        return colorScheme.secondary;
      case OrderStatus.ready:
        return colorScheme.primary;
      case OrderStatus.served:
        return CafeColors.success;
      case OrderStatus.paid:
        return CafeColors.success;
    }
  }

  Future<void> _advanceOrder(BuildContext context, WidgetRef ref) async {
    if (status == OrderStatus.served) {
      // Show payment method dialog before marking paid
      _showPaymentDialog(context, ref);
      return;
    }

    final nextStatus = switch (status) {
      OrderStatus.pending => OrderStatus.prep,
      OrderStatus.prep => OrderStatus.ready,
      OrderStatus.ready => OrderStatus.served,
      OrderStatus.served => OrderStatus.paid,
      OrderStatus.paid => OrderStatus.paid,
    };

    try {
      await ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, nextStatus);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: const Text(
          'Mark this order as paid in cash at the counter?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handlePayment(context, ref, 'cash');
            },
            icon: const Icon(Icons.money_rounded),
            label: const Text('Mark Paid — Cash'),
            style: FilledButton.styleFrom(
              backgroundColor: CafeColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(
    BuildContext context,
    WidgetRef ref,
    String method,
  ) async {
    try {
      // Update payment method
      await ref
          .read(orderProvider.notifier)
          .updatePaymentMethod(order.id, method);

      // Advance to paid
      await ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, OrderStatus.paid);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not mark order paid: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      // Print receipt after marking paid
      _printBill(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order marked as paid via $method'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _printBill(BuildContext context) {
    printReceipt(
      cafeName: 'Kalpa Coffee',
      tableId: order.tableId,
      items: order.items
          .map(
            (item) => {
              'name': item.item.name,
              'quantity': item.quantity,
              'price': item.item.price,
              'size': item.size,
            },
          )
          .toList(),
      total: order.totalAmount,
      paymentMethod: order.paymentMethod,
      orderId: order.id,
    );
  }

  void _showOrderDetail(BuildContext context, AppOrder order) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Table: ${order.tableId.replaceAll('table_', '').toUpperCase()}',
            ),
            Text('Status: ${order.status.name.toUpperCase()}'),
            Text('Time: ${_formatTime(order.createdAt)}'),
            if (order.paymentMethod != null)
              Text('Payment: ${order.paymentMethod}'),
            const Divider(height: 24),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.item.name} (${item.size})'),
                    Text(
                      '\$${(item.item.price * item.quantity).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
