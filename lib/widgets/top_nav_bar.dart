import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import 'responsive_widget.dart';

class TopNavBarWidget extends ConsumerWidget {
  const TopNavBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ResponsiveUtils.isMobile(context)) {
      return const SizedBox.shrink(); // Use bottom nav on mobile
    }

    final cartItems = ref.watch(cartProvider);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      decoration: BoxDecoration(
        color: AppColors.background, // Solid cream white
        border: Border(
          bottom: BorderSide(
            color: AppColors.shadowDark.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Image.asset('assets/logo.png', height: 48, fit: BoxFit.contain),
          const SizedBox(width: 48),
          _navLink(context, 'Shop', true),
          const SizedBox(width: 32),
          _navLink(context, 'Our Story', false),
          const SizedBox(width: 32),
          _navLink(context, 'Wholesale', false),
          const SizedBox(width: 32),
          _navLink(context, 'Blog', false),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () => context.push('/cart'),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${cartItems.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(BuildContext context, String text, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 24,
            color: AppColors.textPrimary,
          ),
      ],
    );
  }
}
