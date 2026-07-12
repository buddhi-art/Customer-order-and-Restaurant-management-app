import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/order.dart';
import '../../theme/cafe_colors.dart';
import '../../theme/m3_theme.dart';
import '../../animations/m3_animations.dart';
import '../../widgets/staggered_animations.dart';
import '../../widgets/responsive_widget.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import '../../ui/core/widgets/premium_cta_button.dart';
import '../../utils/security_layer.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Premium cash-at-counter venue: all orders are settled in cash at the
  // counter. No online payment options.
  static const String _paymentMethod = 'Pay at Counter';
  bool isCheckingOut = false;

  /// Stable id reused across retries so a failed submit that is retried does
  /// not create a duplicate order. Cleared once an insert succeeds.
  String? _pendingOrderId;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    // Issue 13: use ref.watch with select so total reacts to cart changes
    final totalAmount = ref.watch(
      cartProvider.select(
        (items) => items.fold<double>(0.0, (sum, i) => sum + i.totalPrice),
      ),
    );

    // Issue 3: read tax rate from settings provider
    final settingsAsync = ref.watch(settingsProvider);
    final taxRate = settingsAsync.maybeWhen(
      data: (s) => s.taxRate > 0 ? s.taxRate : 0.13,
      orElse: () => 0.13,
    );
    final tax = totalAmount * taxRate;
    final grandTotal = totalAmount + tax;

    final isDesktop = ResponsiveUtils.isDesktop(context);

    // ── Empty State ──
    Widget emptyState = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CafeColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: CafeColors.outlineVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          PremiumCtaButton(
            text: 'Browse Menu',
            trailingIcon: Icons.restaurant_menu_rounded,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );

    // ── Cart Item List ──
    Widget cartList = ListView.separated(
      padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return StaggeredFadeIn(
          index: index,
          delay: const Duration(milliseconds: 50),
          slideOffset: const Offset(0, 0.1),
          child: Dismissible(
            key: ValueKey('${cartItem.item.id}_${cartItem.size}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              ref
                  .read(cartProvider.notifier)
                  .removeItem(cartItem.item, cartItem.size);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24.0),
              decoration: BoxDecoration(
                color: CafeColors.error,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: CafeColors.onError,
              ),
            ),
            child: DoubleBezelContainer(
              padding: 4,
              outerRadius: 24,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: CafeColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${cartItem.quantity}x',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.item.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          // Issue 18: show real milk type from CartItem
                          Text(
                            '${cartItem.size}, ${cartItem.milkType}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: CafeColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: CafeColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // ── Summary Panel ──
    Widget summaryPanel = DoubleBezelContainer(
      padding: 0,
      outerRadius: isDesktop ? 32 : 0,
      innerColor: isDesktop
          ? CafeColors.surfaceContainerLow
          : CafeColors.surface,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 48.0 : 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 48),
            ],
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CafeColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tax — label reflects actual rate from DB
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax (${(taxRate * 100).toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CafeColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${tax.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: CafeColors.outline),
            const SizedBox(height: 24),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '\$${grandTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: CafeColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Payment — cash at counter only (premium venue, no online payments)
            Text(
              'Payment',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CafeColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: CafeColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CafeColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 20,
                    color: CafeColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay at Counter',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Settle your bill in cash at the counter.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CafeColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: M3PressScale(
                onTap: isCheckingOut
                    ? null
                    : () async {
                        setState(() => isCheckingOut = true);
                        HapticFeedback.heavyImpact();

                        final tableId = ref.read(tableProvider);
                        if (tableId == null) {
                          setState(() => isCheckingOut = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please scan a table QR code first!',
                              ),
                            ),
                          );
                          context.push('/scan');
                          return;
                        }

                        final isSecure =
                            await SecurityLayer.verifyCheckoutSecurity();
                        // The abort must run unconditionally when the check
                        // fails — even if the widget was disposed during the
                        // async gap — otherwise an order could still be built
                        // and submitted. UI feedback stays guarded by mounted.
                        if (!isSecure) {
                          if (context.mounted) {
                            setState(() => isCheckingOut = false);
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: CafeColors.surface,
                                title: Text(
                                  'Security Check Failed',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                content: const Text(
                                  'You must be connected to Kalpa WiFi and be inside the cafe to order.',
                                ),
                                actions: [
                                  PremiumCtaButton(
                                    text: 'OK',
                                    trailingIcon: Icons.check,
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ],
                              ),
                            );
                          }
                          return;
                        }

                        // Reuse a single order id across retries so a failed
                        // submit that is retried does not create duplicates
                        // (paired with a future server-side unique guard).
                        _pendingOrderId ??= const Uuid().v4();
                        final newOrder = AppOrder(
                          id: _pendingOrderId!,
                          tableId: tableId,
                          items: cartItems,
                          totalAmount: grandTotal,
                          createdAt: DateTime.now(),
                          status: OrderStatus.pending,
                          paymentMethod: _paymentMethod,
                          paymentStatus: 'unpaid',
                        );

                        try {
                          await ref
                              .read(orderProvider.notifier)
                              .addOrder(newOrder);
                          ref.read(cartProvider.notifier).clearCart();
                          _pendingOrderId = null;
                          if (context.mounted) {
                            context.go('/order_status/${newOrder.id}');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not place order. Please check your '
                                  'connection and try again.',
                                ),
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isCheckingOut = false);
                          }
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: CafeColors.onSurface,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: CafeColors.onSurface.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isCheckingOut
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: CafeColors.surface,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Checkout • \$${grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: CafeColors.surface,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            if (!isDesktop)
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );

    Widget content;
    if (cartItems.isEmpty) {
      content = emptyState;
    } else {
      if (isDesktop) {
        content = ResponsiveTwoPanel(
          left: cartList,
          right: Padding(
            padding: const EdgeInsets.all(48.0),
            child: summaryPanel,
          ),
          flexLeft: 6,
          flexRight: 5,
          spacing: 0,
        );
      } else {
        content = Column(
          children: [
            Expanded(child: cartList),
            summaryPanel,
          ],
        );
      }
    }

    return Scaffold(
      backgroundColor: CafeColors.surface,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: M3PressScale(
                  onTap: () => context.pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CafeColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CafeColors.outline),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: CafeColors.onSurface,
                    ),
                  ),
                ),
              ),
              title: Text(
                'Checkout',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
      body: Column(children: [Expanded(child: content)]),
    );
  }
}
