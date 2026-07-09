import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/m3_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order.dart';
import 'user_shell.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../ui/core/widgets/double_bezel_container.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    List<AppOrder> filtered;
    switch (_filter) {
      case 'active':
        filtered = orders.where((o) => o.status != OrderStatus.paid).toList();
        break;
      case 'completed':
        filtered = orders.where((o) => o.status == OrderStatus.paid).toList();
        break;
      default:
        filtered = orders.toList();
    }
    filtered = filtered.reversed.toList();

    return UserShell(
      title: 'Orders',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    count: orders.length,
                    isSelected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: 'Active',
                    count: orders
                        .where((o) => o.status != OrderStatus.paid)
                        .length,
                    isSelected: _filter == 'active',
                    onTap: () => setState(() => _filter = 'active'),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: 'Completed',
                    count: orders
                        .where((o) => o.status == OrderStatus.paid)
                        .length,
                    isSelected: _filter == 'completed',
                    onTap: () => setState(() => _filter = 'completed'),
                  ),
                ],
              ),
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),

          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 80,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No orders yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Browse Menu',
                              style: TextStyle(
                                color: colorScheme.surface,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 600.ms)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return _OrderCard(
                            order: order,
                            onTap: () =>
                                context.push('/order_status/${order.id}'),
                            onReorder: () {
                              HapticFeedback.mediumImpact();
                              for (final item in order.items) {
                                ref
                                    .read(cartProvider.notifier)
                                    .addItem(
                                      item.item,
                                      item.quantity,
                                      item.size,
                                    );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Items from order added to cart',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              context.go('/cart');
                            },
                          )
                          .animate(delay: (50 * index).ms)
                          .fade(duration: 400.ms, curve: Curves.easeOut)
                          .slideY(begin: 0.2, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? CafeColors.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? CafeColors.onSurface : CafeColors.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? CafeColors.surface : CafeColors.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? CafeColors.surface.withValues(alpha: 0.24)
                    : CafeColors.outline,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? CafeColors.surface : CafeColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  final VoidCallback onTap;
  final VoidCallback onReorder;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (order.status) {
      OrderStatus.pending => CafeColors.warning,
      OrderStatus.prep => CafeColors.warning,
      OrderStatus.ready => CafeColors.secondary,
      OrderStatus.served => CafeColors.primary,
      OrderStatus.paid => CafeColors.success,
    };

    final statusLabel = switch (order.status) {
      OrderStatus.pending => 'Pending',
      OrderStatus.prep => 'Preparing',
      OrderStatus.ready => 'Ready',
      OrderStatus.served => 'Served',
      OrderStatus.paid => 'Completed',
    };

    final statusIcon = switch (order.status) {
      OrderStatus.pending => Icons.hourglass_empty_rounded,
      OrderStatus.prep => Icons.coffee_maker_rounded,
      OrderStatus.ready => Icons.check_circle_outline_rounded,
      OrderStatus.served => Icons.thumb_up_alt_rounded,
      OrderStatus.paid => Icons.check_circle_rounded,
    };

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: DoubleBezelContainer(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.tableId.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items.length} items • ${_formatTime(order.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CafeColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Price
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: CafeColors.primary,
                            ),
                          ),
                          const Spacer(),
                          // Items summary
                          Text(
                            order.items
                                .map((i) => i.item.name)
                                .take(2)
                                .join(', '),
                            style: TextStyle(
                              fontSize: 11,
                              color: CafeColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Reorder button for completed orders
                      if (order.status == OrderStatus.paid) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: onReorder,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: CafeColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.replay_rounded,
                                  size: 16,
                                  color: CafeColors.onPrimaryContainer,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Reorder',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: CafeColors.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: CafeColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
