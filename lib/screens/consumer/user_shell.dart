import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/m3_theme.dart';
import '../../animations/m3_animations.dart';

class UserShell extends StatelessWidget {
  final String title;
  final Widget body;

  const UserShell({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to scroll behind the floating nav
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: CafeColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CafeColors.outline),
              ),
              child: Image.asset('assets/logo.png', height: 28, width: 28),
            ),
            const SizedBox(width: 12),
            Text(
              'कल्प',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: CafeColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CafeColors.onSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CAFÉ',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: CafeColors.surface,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: M3PressScale(
              onTap: () {},
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CafeColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CafeColors.outline),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: CafeColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: CafeColors.onSurface.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: CafeColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
        surfaceTintColor: Colors.transparent,
        backgroundColor: CafeColors.surface.withValues(alpha: 0.9),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: _UserBottomNav(title: title),
    );
  }
}

class _UserBottomNav extends StatelessWidget {
  final String title;

  const _UserBottomNav({required this.title});

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    if (title == 'Orders') currentIndex = 1;
    if (title == 'Profile') currentIndex = 2;

    return Padding(
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: CafeColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: CafeColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: CafeColors.shadowMedium,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => context.go('/home'),
            ),
            _NavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Orders',
              isSelected: currentIndex == 1,
              onTap: () => context.go('/orders'),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: currentIndex == 2,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return M3PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.32, 0.72, 0, 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? CafeColors.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? CafeColors.onSurface
                  : CafeColors.onSurfaceVariant,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CafeColors.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
