import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/order.dart';
import '../../theme/cafe_colors.dart';
import '../../animations/m3_animations.dart';
import '../../widgets/staggered_animations.dart';
import '../../widgets/responsive_widget.dart';
import '../../utils/security_layer.dart';
import 'user_shell.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const String _paymentMethod = 'Pay at Counter';
  bool isCheckingOut = false;
  String? _pendingOrderId;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    final totalAmount = ref.watch(
      cartProvider.select(
        (items) => items.fold<double>(0.0, (sum, i) => sum + i.totalPrice),
      ),
    );

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
              color: CafeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: CafeColors.outline.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: CafeColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Newsreader',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          M3PressScale(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: CafeColors.onSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Browse Menu',
                style: TextStyle(
                  color: CafeColors.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // ── Cart Item List ──
    Widget cartList = ListView.separated(
      padding: EdgeInsets.all(isDesktop ? 48.0 : 16.0),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: CafeColors.onError,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CafeColors.surface,
                border: Border.all(
                  color: CafeColors.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CafeColors.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${cartItem.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cartItem.size}, ${cartItem.milkType}',
                          style: TextStyle(
                            fontSize: 13,
                            color: CafeColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      M3PressScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(
                                cartItem.item,
                                cartItem.size,
                                cartItem.quantity - 1,
                              );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: CafeColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      M3PressScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(
                                cartItem.item,
                                cartItem.size,
                                cartItem.quantity + 1,
                              );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: CafeColors.onSurfaceVariant,
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
      },
    );

    // ── Summary Panel ──
    Widget summaryPanel = Container(
      decoration: BoxDecoration(
        color: CafeColors.surface,
        border: Border(
          top: BorderSide(color: CafeColors.outline.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(color: CafeColors.onSurfaceVariant),
                  ),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax (${(taxRate * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(color: CafeColors.onSurfaceVariant),
                  ),
                  Text(
                    '\$${tax.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: CafeColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$${grandTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontFamily: 'Newsreader',
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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

                              final settings = ref.read(settingsProvider).value;
                              if (settings == null) {
                                setState(() => isCheckingOut = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Unable to load cafe settings.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final isSecure =
                                  await SecurityLayer.verifyCheckoutSecurity(
                                    settings,
                                  );
                              if (!isSecure) {
                                if (context.mounted) {
                                  setState(() => isCheckingOut = false);
                                  final wifiName = await NetworkInfo()
                                      .getWifiName();
                                  final currentWifi =
                                      wifiName?.replaceAll('"', '') ??
                                      'Unknown';
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: CafeColors.surface,
                                      title: const Text(
                                        'Security Check Failed',
                                      ),
                                      content: Text(
                                        'You must be connected to ${settings.wifiSSID} or be inside ${settings.cafeName} to order.\n\n(Detected WiFi: $currentWifi)',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                              color: CafeColors.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return;
                              }

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
                                        'Could not place order. Please check your connection and try again.',
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: CafeColors.onSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: isCheckingOut
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: CafeColors.surface,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'CHECKOUT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: CafeColors.surface,
                                  ),
                                ),
                        ),
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

    return UserShell(
      title: 'Cart',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              'YOUR CART',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Newsreader',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${cartItems.length} ITEMS',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: CafeColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: cartItems.isEmpty ? emptyState : cartList),
          if (cartItems.isNotEmpty) summaryPanel,
        ],
      ),
    );
  }
}
