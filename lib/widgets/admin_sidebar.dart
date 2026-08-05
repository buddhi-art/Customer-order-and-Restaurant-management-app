import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'staggered_animations.dart';

class AdminSidebar extends StatelessWidget {
  final String activeRoute;

  const AdminSidebar({
    super.key,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.cardGradientStart.withValues(alpha: 0.85), 
                AppColors.cardDark.withValues(alpha: 0.85)
              ],
            ),
          ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInWidget(
            child: Text(
              'कल्प\nCAFÉ',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    color: AppColors.textOnDark,
                  ),
            ),
          ),
          const SizedBox(height: 60),
          StaggeredFadeIn(
            index: 0,
            slideOffset: const Offset(-20, 0),
            child: _buildNavItem(context, 'Dashboard', Icons.dashboard, '/admin'),
          ),
          StaggeredFadeIn(
            index: 1,
            slideOffset: const Offset(-20, 0),
            child: _buildNavItem(context, 'Menu', Icons.restaurant_menu, '/admin/menu'),
          ),
          StaggeredFadeIn(
            index: 2,
            slideOffset: const Offset(-20, 0),
            child: _buildNavItem(context, 'Tables', Icons.table_restaurant, '/admin/tables'),
          ),
          StaggeredFadeIn(
            index: 3,
            slideOffset: const Offset(-20, 0),
            child: _buildNavItem(context, 'Offers', Icons.local_offer, '/admin/offers'),
          ),
          StaggeredFadeIn(
            index: 4,
            slideOffset: const Offset(-20, 0),
            child: _buildNavItem(context, 'Members', Icons.people, '/admin/members'),
          ),
          const Spacer(),
          StaggeredFadeIn(
            index: 5,
            slideOffset: const Offset(-20, 0),
            child: M3PressScale(
              onTap: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (_) {
                  // Ignore network/auth errors; local session is cleared and
                  // we still route the user out.
                } finally {
                  if (context.mounted) context.go('/admin/login');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryAction.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.primaryAction),
                    SizedBox(width: 16),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.primaryAction,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route) {
    final isActive = activeRoute == route;
    return M3PressScale(
      onTap: () {
        if (!isActive) context.go(route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: m3FadeCurve,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryAction : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : AppColors.textOnDark.withValues(alpha: 0.7)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textOnDark.withValues(alpha: 0.7),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
