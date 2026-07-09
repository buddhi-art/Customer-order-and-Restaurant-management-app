import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/m3_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/order.dart';
import 'user_shell.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import '../../animations/m3_animations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final completedOrders = orders
        .where(
          (o) => o.status == OrderStatus.paid || o.status == OrderStatus.served,
        )
        .toList();
    final favorites = ref.watch(favoritesProvider);

    return UserShell(
      title: 'Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            DoubleBezelContainer(
              outerRadius: 32,
              padding: 6,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CafeColors.onSurface,
                      ),
                      child: Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: CafeColors.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coffee Lover',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: CafeColors.ratingGold,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Gold Member',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: CafeColors.ratingGold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit profile
                    M3PressScale(
                      onTap: () {
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: CafeColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                          border: Border.all(color: CafeColors.outline),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: CafeColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),

            // Stats Row
            Row(
              children: [
                _StatCard(
                  icon: Icons.coffee_rounded,
                  value: '${completedOrders.length}',
                  label: 'Orders',
                  color: CafeColors.primary,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  icon: Icons.favorite_rounded,
                  value: '${favorites.length}',
                  label: 'Favorites',
                  color: CafeColors.error,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  icon: Icons.card_giftcard_rounded,
                  value: points.toString(),
                  label: 'Points',
                  color: CafeColors.ratingGold,
                ),
              ],
            ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),

            // Loyalty Card
            _LoyaltyCard(points: points)
                .animate()
                .fade(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 48),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: -0.05, end: 0),
            const SizedBox(height: 24),
            Row(
              children: [
                _ActionTile(
                  icon: Icons.receipt_long_rounded,
                  label: 'History',
                  color: CafeColors.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/orders');
                  },
                ),
                const SizedBox(width: 16),
                _ActionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan Table',
                  color: CafeColors.error,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/scan');
                  },
                ),
                const SizedBox(width: 16),
                _ActionTile(
                  icon: Icons.support_agent_rounded,
                  label: 'Support',
                  color: CafeColors.success,
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 48),

            // Recent Orders Summary
            DoubleBezelContainer(
              outerRadius: 32,
              padding: 6,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Orders',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        M3PressScale(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/orders');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: CafeColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CafeColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: CafeColors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (completedOrders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: CafeColors.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  size: 32,
                                  color: CafeColors.outlineVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No orders yet',
                                style: TextStyle(
                                  color: CafeColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...completedOrders
                          .take(3)
                          .map(
                            (order) => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: CafeColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: CafeColors.outline),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      size: 20,
                                      color: CafeColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${order.items.length} items • ${order.tableId.toUpperCase()}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${order.totalAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: CafeColors.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: CafeColors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: CafeColors.outline),
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: CafeColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ).animate().fade(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  int get points {
    return 250; // Mock fallback
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DoubleBezelContainer(
        outerRadius: 24,
        padding: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: CafeColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  final int points;
  const _LoyaltyCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final nextReward = 500;
    final progress = (points % nextReward) / nextReward;

    return DoubleBezelContainer(
      outerRadius: 32,
      padding: 8,
      innerColor: CafeColors.onSurface,
      showInnerHighlight: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              CafeColors.onSurface,
              const Color(0xFF111111),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loyalty Rewards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CafeColors.surface,
                  ),
                ),
                Icon(
                  Icons.card_giftcard_rounded,
                  color: CafeColors.surface.withValues(alpha: 0.8),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '$points points',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: CafeColors.surface,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${nextReward - (points % nextReward)} points to next reward',
              style: TextStyle(
                fontSize: 14,
                color: CafeColors.surface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: CafeColors.surface.withValues(alpha: 0.1),
                color: CafeColors.ratingGold,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Free Coffee',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CafeColors.surface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '${nextReward - (points % nextReward)} pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CafeColors.surface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: M3PressScale(
        onTap: onTap,
        child: DoubleBezelContainer(
          outerRadius: 24,
          padding: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CafeColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CafeColors.outline),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
