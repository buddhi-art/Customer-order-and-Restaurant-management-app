import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/m3_theme.dart' show CafeColors;
import '../../animations/m3_animations.dart';
import '../../widgets/responsive_widget.dart';

class AdminShell extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex;
  final Widget? floatingActionButton;

  static const _labels = [
    'Dashboard',
    'Orders',
    'Menu',
    'Tables',
    'Staff',
    'Analytics',
    'Inventory',
    'Members',
    'Expenses',
    'Offers',
    'Feedback',
    'Settings',
  ];

  static const _icons = [
    Icons.dashboard_rounded,
    Icons.receipt_long_rounded,
    Icons.restaurant_menu_rounded,
    Icons.table_restaurant_rounded,
    Icons.people_alt_rounded,
    Icons.insights_rounded,
    Icons.inventory_2_rounded,
    Icons.person_pin_rounded,
    Icons.money_off_rounded,
    Icons.campaign_rounded,
    Icons.reviews_rounded,
    Icons.settings_rounded,
  ];

  static const _routes = [
    '/admin',
    '/admin/orders',
    '/admin/menu',
    '/admin/tables',
    '/admin/staff',
    '/admin/analytics',
    '/admin/inventory',
    '/admin/members',
    '/admin/expenses',
    '/admin/offers',
    '/admin/feedback',
    '/admin/settings',
  ];

  const AdminShell({
    super.key,
    required this.title,
    required this.body,
    required this.selectedIndex,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    final drawerContent = Builder(
      builder: (innerContext) => SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 40, width: 40),
                      const SizedBox(width: 12),
                      Text(
                        'कल्प',
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: CafeColors.primary,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CafeColors.onSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ADMIN SYSTEM',
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
            ),
            const Divider(indent: 28, endIndent: 28),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _labels.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: M3PressScale(
                      onTap: () {
                        if (!isDesktop) {
                          Navigator.of(innerContext).pop(); // Close drawer
                        }
                        if (!isSelected) {
                          context.go(_routes[index]);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: m3FadeCurve,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CafeColors.surfaceContainerHigh
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _icons[index],
                              size: 20,
                              color: isSelected
                                  ? CafeColors.onSurface
                                  : CafeColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _labels[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? CafeColors.onSurface
                                    : CafeColors.onSurfaceVariant,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: CafeColors.surface,
      appBar: AppBar(
        title: Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CafeColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Supabase.instance.client.auth.currentUser?.email ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CafeColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                // Double-Bezel Logout Button
                M3PressScale(
                  onTap: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                    } catch (_) {
                      // Ignore network/auth errors; the local session is
                      // cleared and we still route the user out.
                    } finally {
                      if (context.mounted) context.go('/admin/login');
                    }
                  },
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
                        Icons.logout_rounded,
                        size: 18,
                        color: CafeColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: CafeColors.surface,
              elevation: 0,
              child: drawerContent,
            ),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: CafeColors.surface,
                    border: Border(
                      right: BorderSide(
                        color: CafeColors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: drawerContent,
                ),
                Expanded(child: body),
              ],
            )
          : body,
      floatingActionButton: floatingActionButton,
    );
  }
}
