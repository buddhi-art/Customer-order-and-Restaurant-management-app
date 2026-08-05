import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/m3_theme.dart';
import '../../animations/m3_animations.dart';
import '../../providers/cart_provider.dart';

class UserShell extends ConsumerWidget {
  final String title;
  final Widget body;

  const UserShell({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine current index based on title
    int currentIndex = 0;
    if (title == 'Cart') currentIndex = 1;
    if (title == 'Orders') currentIndex = 2;
    if (title == 'Profile') currentIndex = 3;

    final cartItems = ref.watch(cartProvider);
    final cartItemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: CafeColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: CafeColors.surface,
            border: Border(
              bottom: BorderSide(
                color: CafeColors.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: CafeColors.surface,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: CafeColors.outline),
                  ),
                  child: Image.asset('assets/logo.png', height: 28, width: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'THE DAILY GRIND',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Newsreader',
                    fontWeight: FontWeight.w600,
                    color: CafeColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: M3PressScale(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CafeColors.surface,
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(color: CafeColors.outline),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: CafeColors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: CafeColors.surface,
          border: Border(
            top: BorderSide(
              color: CafeColors.outline.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Cart',
                  isSelected: currentIndex == 1,
                  badgeCount: cartItemCount,
                  onTap: () => context.go('/cart'),
                ),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  isSelected: currentIndex == 2,
                  onTap: () => context.go('/orders'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isSelected: currentIndex == 3,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return M3PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? CafeColors.onSurface : CafeColors.onSurfaceVariant,
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: CafeColors.onSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: CafeColors.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? CafeColors.onSurface : CafeColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
