import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../theme/cafe_colors.dart';
import '../../widgets/staggered_animations.dart';
import '../../widgets/responsive_widget.dart';
import '../../widgets/top_nav_bar.dart';

class OrderStatusScreen extends ConsumerWidget {
  final String orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final order = orders.where((o) => o.id == orderId).firstOrNull;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: CafeColors.surface,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: CafeColors.surface,
              leading: GestureDetector(
                onTap: () => context.go('/home'),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: CafeColors.onSurface,
                ),
              ),
              title: Text(
                'Order Status',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: CafeColors.onSurface),
              ),
              centerTitle: true,
            ),
      body: order == null
          ? const Center(child: Text('Order not found'))
          : Column(
              children: [
                if (isDesktop) const TopNavBarWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isDesktop) const SizedBox(height: 48),
                            if (isDesktop)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () => context.go('/home'),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.arrow_back_ios_new,
                                          size: 16,
                                          color: CafeColors.onSurface,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Back to Menu',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Hero Image
                            FadeInWidget(
                              duration: const Duration(milliseconds: 600),
                              child: Container(
                                height: isDesktop ? 350 : 250,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: CafeColors.primaryContainer,
                                  image: const DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&q=80&w=800',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // Table Header
                            FadeInWidget(
                              duration: const Duration(milliseconds: 600),
                              delay: const Duration(milliseconds: 100),
                              slideOffset: const Offset(0, 10),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Table ${order.tableId.replaceAll('table_', '').toUpperCase()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(fontSize: 32),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getStatusMessage(order.status),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: CafeColors.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Progress Tracker
                            FadeInWidget(
                              duration: const Duration(milliseconds: 600),
                              delay: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                ),
                                child: _buildProgressTracker(
                                  context,
                                  _getStepIndex(order.status),
                                ),
                              ),
                            ),
                            const SizedBox(height: 64),

                            // Order Summary
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                              ),
                              child: FadeInWidget(
                                duration: const Duration(milliseconds: 600),
                                delay: const Duration(milliseconds: 300),
                                slideOffset: const Offset(0, 10),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: CafeColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: CafeColors.outline,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order Summary',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.displaySmall,
                                      ),
                                      const SizedBox(height: 24),
                                      ...order.items.map((cartItem) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${cartItem.quantity}x',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  cartItem.item.name,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge,
                                                ),
                                              ),
                                              Text(
                                                '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const Divider(
                                        height: 48,
                                        color: CafeColors.outline,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Paid',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.displaySmall,
                                          ),
                                          Text(
                                            '\$${order.totalAmount.toStringAsFixed(2)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.displaySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 64),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  int _getStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.prep:
        return 1;
      case OrderStatus.ready:
      case OrderStatus.served:
      case OrderStatus.paid:
        return 2;
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Waiting for barista to accept...';
      case OrderStatus.prep:
        return 'Your order is being prepared.';
      case OrderStatus.ready:
        return 'Ready! We will bring it to you.';
      case OrderStatus.served:
        return 'Served. Enjoy your coffee!';
      case OrderStatus.paid:
        return 'Paid. Have a great day!';
    }
  }

  Widget _buildProgressTracker(BuildContext context, int currentStep) {
    final steps = ['Placed', 'Preparing', 'Ready'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 != 0) {
          // Connector line
          int stepIndex = index ~/ 2;
          bool isCompleted = currentStep > stepIndex;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: isCompleted ? CafeColors.onSurface : CafeColors.outline,
            ),
          );
        } else {
          // Node
          int stepIndex = index ~/ 2;
          bool isCompleted = currentStep >= stepIndex;
          bool isActive = currentStep == stepIndex;

          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? CafeColors.onSurface : Colors.white,
                  border: Border.all(
                    color: isCompleted
                        ? CafeColors.onSurface
                        : CafeColors.outline,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: CafeColors.surface,
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                steps[stepIndex],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isCompleted
                      ? CafeColors.onSurface
                      : CafeColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
