import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../theme/m3_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/order.dart';
import '../../widgets/responsive_widget.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import '../../ui/core/widgets/premium_cta_button.dart';
import 'admin_shell.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final inventory = ref.watch(inventoryProvider);
    final isMobile = ResponsiveUtils.isMobile(context);

    final pending = orders
        .where((o) => o.status == OrderStatus.pending)
        .toList();
    final prep = orders.where((o) => o.status == OrderStatus.prep).toList();
    final ready = orders.where((o) => o.status == OrderStatus.ready).toList();
    final completed = orders
        .where((o) => o.status == OrderStatus.paid)
        .toList();
    final revenue = completed.fold<double>(0, (sum, o) => sum + o.totalAmount);

    final itemCounts = <String, int>{};
    for (final o in orders) {
      for (final item in o.items) {
        itemCounts.update(
          item.item.name,
          (v) => v + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }
    }
    final topItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final lowStockItems = inventory.where((i) => i.isLow).toList();

    return AdminShell(
      title: 'Dashboard',
      selectedIndex: 0,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 64,
          vertical: isMobile ? 48 : 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      'Good ${_greeting()},\nAdmin.',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                    )
                    .animate()
                    .fade(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                Text(
                      'Here\'s what\'s happening at कल्प today.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: CafeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
            const SizedBox(height: 64),

            // Low Stock Alert
            if (lowStockItems.isNotEmpty)
              Container(
                    margin: const EdgeInsets.only(bottom: 64),
                    child: DoubleBezelContainer(
                      outerRadius: 32,
                      padding: 6,
                      innerColor: CafeColors.error.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: CafeColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                color: CafeColors.error,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${lowStockItems.length} items running low',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: CafeColors.error,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lowStockItems
                                        .take(3)
                                        .map((i) => i.name)
                                        .join(', '),
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: CafeColors.error.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            PremiumCtaButton(
                              text: 'View',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                context.go('/admin/inventory');
                              },
                              backgroundColor: CafeColors.error,
                              foregroundColor: CafeColors.surface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fade(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

            // KPI Cards — varied layouts to break the hero-metric template
            LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 600;
                    final inProgress = prep.length + ready.length;

                    if (isCompact) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: _KpiStatRow(
                              icon: Icons.receipt_long_rounded,
                              label: 'Orders',
                              value: '${orders.length}',
                              color: CafeColors.primary,
                              onTap: () => context.go('/admin/orders'),
                            ),
                          ),
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: _KpiStatRow(
                              icon: Icons.check_circle_rounded,
                              label: 'Done',
                              value: '${completed.length}',
                              color: CafeColors.success,
                              onTap: () => context.go('/admin/orders'),
                            ),
                          ),
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: _KpiFeaturedNumber(
                              label: 'In Progress',
                              value: '$inProgress',
                              color: CafeColors.warning,
                              badge: '${pending.length} pending',
                              onTap: () => context.go('/admin/orders'),
                            ),
                          ),
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: _KpiRevenueCard(
                              revenue: revenue,
                              onTap: () => context.go('/admin/analytics'),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _KpiStatRow(
                            icon: Icons.receipt_long_rounded,
                            label: 'Total Orders',
                            value: '${orders.length}',
                            color: CafeColors.primary,
                            onTap: () => context.go('/admin/orders'),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _KpiFeaturedNumber(
                            label: 'In Progress',
                            value: '$inProgress',
                            color: CafeColors.warning,
                            badge: '${pending.length} pending',
                            onTap: () => context.go('/admin/orders'),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _KpiStatRow(
                            icon: Icons.check_circle_rounded,
                            label: 'Completed',
                            value: '${completed.length}',
                            color: CafeColors.success,
                            onTap: () => context.go('/admin/orders'),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _KpiRevenueCard(
                            revenue: revenue,
                            onTap: () => context.go('/admin/analytics'),
                          ),
                        ),
                      ],
                    );
                  },
                )
                .animate()
                .fade(duration: 600.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 64),

            // Top Selling + Low Stock
            ResponsiveTwoPanel(
                  flexLeft: 3,
                  flexRight: 2,
                  left: _DashboardCard(
                    title: 'Top Selling Items',
                    child: topItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                'No orders yet',
                                style: TextStyle(
                                  color: CafeColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: topItems
                                .take(6)
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final i = entry.key;
                                  final e = entry.value;
                                  final maxCount = topItems.first.value;
                                  final ratio = maxCount > 0
                                      ? e.value / maxCount
                                      : 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: i < 3
                                                  ? CafeColors.primary
                                                  : CafeColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            e.key,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: ratio,
                                              color: i == 0
                                                  ? CafeColors.primary
                                                  : CafeColors.primary
                                                        .withValues(
                                                          alpha: 0.5 - i * 0.07,
                                                        ),
                                              backgroundColor: CafeColors
                                                  .surfaceContainerHigh,
                                              minHeight: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        SizedBox(
                                          width: 48,
                                          child: Text(
                                            '${e.value}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: CafeColors.onSurface,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                  ),
                  right: _DashboardCard(
                    title: 'Low Stock Alerts',
                    onTap: () => context.go('/admin/inventory'),
                    child: lowStockItems.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 64,
                                    color: CafeColors.success,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'All stocked up!',
                                    style: TextStyle(
                                      color: CafeColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: lowStockItems
                                .take(5)
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: CafeColors.error.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${item.currentStock.toInt()}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                                color: CafeColors.error,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'min: ${item.minStock.toInt()} ${item.unit}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: CafeColors
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                )
                .animate()
                .fade(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 64),

            // Charts
            ResponsiveTwoPanel(
                  flexLeft: 3,
                  flexRight: 2,
                  left: _ChartCard(
                    title: 'Weekly Revenue',
                    height: 380,
                    child: _RevenueChart(completed),
                  ),
                  right: _ChartCard(
                    title: 'Order Status',
                    height: 380,
                    child: _StatusPieChart(
                      pending.length,
                      prep.length,
                      ready.length,
                      completed.length,
                    ),
                  ),
                )
                .animate()
                .fade(duration: 600.ms, delay: 500.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 64),

            // Recent Orders
            _RecentOrdersCard(orders: orders, context: context)
                .animate()
                .fade(duration: 600.ms, delay: 700.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ═══════════════════════════════════════════
// Reusable Card Widgets
// ═══════════════════════════════════════════

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  const _DashboardCard({required this.title, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DoubleBezelContainer(
      outerRadius: 32,
      padding: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Horizontal stat row: icon | label | value ──
class _KpiStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const _KpiStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DoubleBezelContainer(
      outerRadius: 28,
      padding: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CafeColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: CafeColors.onSurface,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Featured number card: bold value + small badge ──
class _KpiFeaturedNumber extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;
  const _KpiFeaturedNumber({
    required this.label,
    required this.value,
    required this.color,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DoubleBezelContainer(
      outerRadius: 28,
      padding: 4,
      innerColor: color.withValues(alpha: 0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: CafeColors.onSurface,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CafeColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Revenue card: value + accent bar visual ──
class _KpiRevenueCard extends StatelessWidget {
  final double revenue;
  final VoidCallback? onTap;
  const _KpiRevenueCard({required this.revenue, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DoubleBezelContainer(
      outerRadius: 28,
      padding: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CafeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${revenue.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: CafeColors.onSurface,
                            letterSpacing: -1,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Accent bar — fills proportionally (capped at 4 segments)
                    LayoutBuilder(
                      builder: (context, barConstraints) {
                        final segments = 10;
                        final filled = (revenue > 0)
                            ? ((revenue / (revenue + 200)).clamp(0.08, 1.0) *
                                      segments)
                                  .round()
                            : 0;
                        return Row(
                          children: List.generate(segments, (i) {
                            final active = i < filled;
                            final hue = active
                                ? CafeColors.primary
                                : CafeColors.outline;
                            return Container(
                              width:
                                  (barConstraints.maxWidth -
                                      (segments - 1) * 4) /
                                  segments,
                              height: 4,
                              decoration: BoxDecoration(
                                color: hue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              margin: EdgeInsets.only(
                                right: i < segments - 1 ? 4 : 0,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final double height;
  final Widget child;
  const _ChartCard({
    required this.title,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DoubleBezelContainer(
      outerRadius: 32,
      padding: 4,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last 7 days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CafeColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(height: height - 120, child: child),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Charts
// ═══════════════════════════════════════════

class _RevenueChart extends StatelessWidget {
  final List<AppOrder> completed;
  const _RevenueChart(this.completed);

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final dailyRevenue = List.filled(7, 0.0);

    for (final order in completed) {
      final diff = today.difference(order.createdAt).inDays;
      if (diff >= 0 && diff < 7) dailyRevenue[6 - diff] += order.totalAmount;
    }

    final maxY = dailyRevenue.isNotEmpty
        ? dailyRevenue.reduce((a, b) => a > b ? a : b)
        : 100.0;
    final ceiling = maxY > 0 ? (maxY * 1.3).ceilToDouble() : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: ceiling,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(12),
            getTooltipColor: (_) => CafeColors.onSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '\$${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                    color: CafeColors.surface,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < 7) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      dayNames[idx],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CafeColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toInt()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CafeColors.onSurfaceVariant,
                ),
              ),
              interval: ceiling > 0 ? (ceiling / 4).ceilToDouble() : 25,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ceiling > 0 ? (ceiling / 4).ceilToDouble() : 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: CafeColors.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dailyRevenue[i],
                color: CafeColors.primary,
                width: 32,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  final int pending, prep, ready, completed;
  const _StatusPieChart(this.pending, this.prep, this.ready, this.completed);

  @override
  Widget build(BuildContext context) {
    final total = pending + prep + ready + completed;
    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee_rounded,
              size: 64,
              color: CafeColors.onSurfaceVariant.withValues(alpha: 0.3),
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
      );
    }

    final sections = [
      if (pending > 0)
        PieChartSectionData(
          value: pending.toDouble(),
          color: CafeColors.onSurface,
          title: '${(pending / total * 100).round()}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: CafeColors.surface,
          ),
        ),
      if (prep > 0)
        PieChartSectionData(
          value: prep.toDouble(),
          color: CafeColors.warning,
          title: '${(prep / total * 100).round()}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: CafeColors.surface,
          ),
        ),
      if (ready > 0)
        PieChartSectionData(
          value: ready.toDouble(),
          color: CafeColors.primary,
          title: '${(ready / total * 100).round()}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: CafeColors.surface,
          ),
        ),
      if (completed > 0)
        PieChartSectionData(
          value: completed.toDouble(),
          color: CafeColors.success,
          title: '${(completed / total * 100).round()}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: CafeColors.surface,
          ),
        ),
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 4,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            _legendItem(CafeColors.onSurface, 'Pending', pending),
            _legendItem(CafeColors.warning, 'Prep', prep),
            _legendItem(CafeColors.primary, 'Ready', ready),
            _legendItem(CafeColors.success, 'Done', completed),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label, int count) {
    if (count == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: CafeColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// Recent Orders
// ═══════════════════════════════════════════

class _RecentOrdersCard extends StatelessWidget {
  final List<AppOrder> orders;
  final BuildContext context;
  const _RecentOrdersCard({required this.orders, required this.context});

  @override
  Widget build(BuildContext context) {
    final recent = orders.take(5).toList();
    return DoubleBezelContainer(
      outerRadius: 32,
      padding: 4,
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
                PremiumCtaButton(
                  text: 'View All',
                  onPressed: () => context.go('/admin/orders'),
                  backgroundColor: CafeColors.surfaceContainerLow,
                  foregroundColor: CafeColors.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(
                      color: CafeColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              ...recent.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _statusColor(
                            order.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _statusIcon(order.status),
                          color: _statusColor(order.status),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Table ${order.tableId.replaceAll('table_', '').toUpperCase()}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.items.length} items • ${_timeAgo(order.createdAt)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: CafeColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            order.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _statusColor(order.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) => switch (s) {
    OrderStatus.pending => CafeColors.onSurface,
    OrderStatus.prep => CafeColors.warning,
    OrderStatus.ready => CafeColors.primary,
    OrderStatus.served => CafeColors.success,
    OrderStatus.paid => CafeColors.success,
  };
  IconData _statusIcon(OrderStatus s) => switch (s) {
    OrderStatus.pending => Icons.hourglass_empty_rounded,
    OrderStatus.prep => Icons.local_fire_department_rounded,
    OrderStatus.ready => Icons.check_circle_outline_rounded,
    OrderStatus.served => Icons.room_service_rounded,
    OrderStatus.paid => Icons.paid_rounded,
  };
  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
