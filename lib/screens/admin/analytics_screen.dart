import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/m3_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../widgets/responsive_widget.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import 'admin_shell.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

enum _DateRange { today, week, month, all }

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  _DateRange _selectedRange = _DateRange.week;
  late AnimationController _animationController;
  late List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _staggeredAnimations = List.generate(8, (i) {
      return CurvedAnimation(
        parent: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              i * 0.12,
              0.6 + i * 0.05,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        curve: Curves.easeOutCubic,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final filteredOrders = _filterOrdersByRange(orders);
    final completed = filteredOrders
        .where(
          (o) => o.status == OrderStatus.paid || o.status == OrderStatus.served,
        )
        .toList();

    final totalRevenue = completed.fold<double>(
      0,
      (sum, o) => sum + o.totalAmount,
    );
    final totalOrders = filteredOrders.length;
    final averageOrderValue = completed.isNotEmpty
        ? totalRevenue / completed.length
        : 0.0;

    final uniqueTables = <String>{};
    for (final o in filteredOrders) {
      if (o.status != OrderStatus.paid) {
        uniqueTables.add(o.tableId);
      }
    }
    final isMobile = ResponsiveUtils.isMobile(context);
    final kpiSpacing = isMobile ? 12.0 : 16.0;

    return AdminShell(
      title: 'Analytics',
      selectedIndex: 5,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        children: [
          // Header
          FadeTransition(
            opacity: _staggeredAnimations[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics & Insights',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your café\'s performance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Date Range Selector
          FadeTransition(
            opacity: _staggeredAnimations[1],
            child: _DateRangeSelector(
              selected: _selectedRange,
              onChanged: (range) {
                setState(() {
                  _selectedRange = range;
                  _animationController.reset();
                  _animationController.forward();
                });
              },
            ),
          ),
          const SizedBox(height: 28),

          // KPI Row — wrap in RepaintBoundary to isolate from charts
          RepaintBoundary(
            child: FadeTransition(
              opacity: _staggeredAnimations[2],
              child: isMobile
                  ? Wrap(
                      spacing: kpiSpacing,
                      runSpacing: kpiSpacing,
                      children: [
                        SizedBox(
                          width:
                              (MediaQuery.of(context).size.width -
                                  16 * 2 -
                                  kpiSpacing) /
                              2,
                          child: _KpiCard(
                            icon: Icons.attach_money_rounded,
                            label: 'Total Revenue',
                            value: '\$${totalRevenue.toStringAsFixed(0)}',
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(
                          width:
                              (MediaQuery.of(context).size.width -
                                  16 * 2 -
                                  kpiSpacing) /
                              2,
                          child: _KpiCard(
                            icon: Icons.receipt_long_rounded,
                            label: 'Total Orders',
                            value: '$totalOrders',
                            color: colorScheme.tertiary,
                          ),
                        ),
                        SizedBox(
                          width:
                              (MediaQuery.of(context).size.width -
                                  16 * 2 -
                                  kpiSpacing) /
                              2,
                          child: _KpiCard(
                            icon: Icons.shopping_cart_rounded,
                            label: 'Avg. Order Value',
                            value: '\$${averageOrderValue.toStringAsFixed(2)}',
                            color: CafeColors.warning,
                          ),
                        ),
                        SizedBox(
                          width:
                              (MediaQuery.of(context).size.width -
                                  16 * 2 -
                                  kpiSpacing) /
                              2,
                          child: _KpiCard(
                            icon: Icons.table_restaurant_rounded,
                            label: 'Active Tables',
                            value: '${uniqueTables.length}',
                            color: CafeColors.success,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            icon: Icons.attach_money_rounded,
                            label: 'Total Revenue',
                            value: '\$${totalRevenue.toStringAsFixed(0)}',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _KpiCard(
                            icon: Icons.receipt_long_rounded,
                            label: 'Total Orders',
                            value: '$totalOrders',
                            color: colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _KpiCard(
                            icon: Icons.shopping_cart_rounded,
                            label: 'Avg. Order Value',
                            value: '\$${averageOrderValue.toStringAsFixed(2)}',
                            color: CafeColors.warning,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _KpiCard(
                            icon: Icons.table_restaurant_rounded,
                            label: 'Active Tables',
                            value: '${uniqueTables.length}',
                            color: CafeColors.success,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 28),

          // Revenue Trend Chart — isolated in its own RepaintBoundary
          RepaintBoundary(
            child: FadeTransition(
              opacity: _staggeredAnimations[3],
              child: _ChartCard(
                title: 'Revenue Trend',
                subtitle: _rangeSubtitle(),
                height: 320,
                child: _RevenueTrendChart(
                  orders: completed,
                  range: _selectedRange,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Popular Items & Hourly Heatmap
          RepaintBoundary(
            child: FadeTransition(
              opacity: _staggeredAnimations[4],
              child: _ChartCard(
                title: 'Popular Items',
                subtitle: 'Most ordered menu items',
                height: 380,
                child: _PopularItemsChart(orders: filteredOrders),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hourly Distribution
          RepaintBoundary(
            child: FadeTransition(
              opacity: _staggeredAnimations[5],
              child: _ChartCard(
                title: 'Hourly Distribution',
                subtitle: 'Orders by hour of day',
                height: 380,
                child: _HourlyHeatmapChart(orders: filteredOrders),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Order Status Distribution
          RepaintBoundary(
            child: FadeTransition(
              opacity: _staggeredAnimations[6],
              child: _ChartCard(
                title: 'Order Status Distribution',
                subtitle: 'Current breakdown of all orders',
                height: 320,
                child: _StatusDistributionChart(orders: filteredOrders),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Summary Section
          RepaintBoundary(
            child: FadeTransition(
              opacity: _staggeredAnimations[7],
              child: _SummarySection(
                orders: filteredOrders,
                revenue: totalRevenue,
                colorScheme: colorScheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<AppOrder> _filterOrdersByRange(List<AppOrder> orders) {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _DateRange.today:
        return orders
            .where(
              (o) =>
                  o.createdAt.year == now.year &&
                  o.createdAt.month == now.month &&
                  o.createdAt.day == now.day,
            )
            .toList();
      case _DateRange.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return orders.where((o) => o.createdAt.isAfter(weekAgo)).toList();
      case _DateRange.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        return orders.where((o) => o.createdAt.isAfter(monthAgo)).toList();
      case _DateRange.all:
        return orders;
    }
  }

  String _rangeSubtitle() {
    switch (_selectedRange) {
      case _DateRange.today:
        return 'Hourly breakdown for today';
      case _DateRange.week:
        return 'Daily revenue for the last 7 days';
      case _DateRange.month:
        return 'Daily revenue for the last 30 days';
      case _DateRange.all:
        return 'All-time daily revenue';
    }
  }
}

// ─── Date Range Selector ──────────────────────────────────────────────────────

class _DateRangeSelector extends StatelessWidget {
  final _DateRange selected;
  final ValueChanged<_DateRange> onChanged;

  const _DateRangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SegmentedButton<_DateRange>(
        segments: const [
          ButtonSegment(value: _DateRange.today, label: Text('Today')),
          ButtonSegment(value: _DateRange.week, label: Text('7D')),
          ButtonSegment(value: _DateRange.month, label: Text('30D')),
          ButtonSegment(value: _DateRange.all, label: Text('All')),
        ],
        selected: {selected},
        onSelectionChanged: (v) => onChanged(v.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.labelMedium,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// ─── KPI Card ─────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DoubleBezelContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chart Card ───────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DoubleBezelContainer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(height: height - 100, child: child),
          ],
        ),
      ),
    );
  }
}

// ─── Revenue Trend Chart ──────────────────────────────────────────────────────

class _RevenueTrendChart extends StatelessWidget {
  final List<AppOrder> orders;
  final _DateRange range;

  const _RevenueTrendChart({required this.orders, required this.range});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (labels, dailyRevenue) = _computeDailyRevenue();

    if (dailyRevenue.isEmpty) {
      return _emptyChart(context, 'No revenue data for this period');
    }

    final maxY = dailyRevenue.reduce((a, b) => a > b ? a : b);
    final ceiling = maxY > 0 ? (maxY * 1.3).ceilToDouble() : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: ceiling,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipColor: (_) => colorScheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '\$${rod.toY.toStringAsFixed(0)}',
                TextStyle(
                  color: colorScheme.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  final show = labels.length > 14
                      ? idx % 5 == 0 || idx == labels.length - 1
                      : true;
                  if (!show) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
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
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
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
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(dailyRevenue.length, (i) {
          final isMax = dailyRevenue[i] == maxY && maxY > 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dailyRevenue[i],
                color: colorScheme.primary,
                width: labels.length > 14 ? 10 : 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                gradient: isMax
                    ? LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
              ),
            ],
          );
        }),
      ),
    );
  }

  (List<String>, List<double>) _computeDailyRevenue() {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthDayNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    switch (range) {
      case _DateRange.today:
        // Hourly buckets for today
        final hourlyRevenue = List.filled(24, 0.0);
        for (final o in orders) {
          final hour = o.createdAt.hour;
          hourlyRevenue[hour] += o.totalAmount;
        }
        final labels = List.generate(
          24,
          (i) => '${i.toString().padLeft(2, '0')}:00',
        );
        return (labels, hourlyRevenue.reversed.toList());

      case _DateRange.week:
        final dailyRevenue = List.filled(7, 0.0);
        for (final o in orders) {
          final diff = now.difference(o.createdAt).inDays;
          if (diff >= 0 && diff < 7) {
            dailyRevenue[6 - diff] += o.totalAmount;
          }
        }
        // Get actual day names
        final labels = List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          return dayNames[day.weekday - 1];
        });
        return (labels, dailyRevenue);

      case _DateRange.month:
        final dailyRevenue = List.filled(30, 0.0);
        for (final o in orders) {
          final diff = now.difference(o.createdAt).inDays;
          if (diff >= 0 && diff < 30) {
            dailyRevenue[29 - diff] += o.totalAmount;
          }
        }
        final labels = List.generate(30, (i) {
          final day = now.subtract(Duration(days: 29 - i));
          return '${day.day}';
        });
        return (labels, dailyRevenue);

      case _DateRange.all:
        // Group by month
        final months = <String, double>{};
        for (final o in orders) {
          final key =
              '${monthDayNames[o.createdAt.month - 1]} ${o.createdAt.year}';
          months.update(
            key,
            (v) => v + o.totalAmount,
            ifAbsent: () => o.totalAmount,
          );
        }
        final entries = months.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final labels = entries.map((e) => e.key).toList();
        final values = entries.map((e) => e.value).toList();
        return (labels, values);
    }
  }
}

// ─── Popular Items Chart ──────────────────────────────────────────────────────

class _PopularItemsChart extends StatelessWidget {
  final List<AppOrder> orders;

  const _PopularItemsChart({required this.orders});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Count item occurrences
    final itemCounts = <String, int>{};
    for (final o in orders) {
      for (final item in o.items) {
        final name = item.item.name;
        itemCounts.update(
          name,
          (v) => v + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }
    }

    if (itemCounts.isEmpty) {
      return _emptyChart(context, 'No order data available');
    }

    // Sort by count descending and take top 8
    final sortedItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topItems = sortedItems.take(8).toList();
    final othersCount = sortedItems
        .skip(8)
        .fold<int>(0, (sum, e) => sum + e.value);
    final totalCount = sortedItems.fold<int>(0, (sum, e) => sum + e.value);

    if (othersCount > 0) {
      topItems.add(MapEntry('Others', othersCount));
    }

    final chartColors = [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
      CafeColors.success,
      CafeColors.warning,
      colorScheme.error,
      colorScheme.primary.withValues(alpha: 0.6),
      colorScheme.tertiary.withValues(alpha: 0.6),
      colorScheme.outline,
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: List.generate(topItems.length, (i) {
                final percentage = (topItems[i].value / totalCount * 100);
                return PieChartSectionData(
                  value: topItems[i].value.toDouble(),
                  color: chartColors[i % chartColors.length],
                  title: percentage >= 5 ? '${percentage.round()}%' : '',
                  radius: 36,
                  titleStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color:
                        chartColors[i % chartColors.length].computeLuminance() >
                            0.5
                        ? Colors.black87
                        : Colors.white,
                  ),
                );
              }),
              centerSpaceRadius: 28,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 120),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: List.generate(topItems.length, (i) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: chartColors[i % chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${topItems[i].key} (${topItems[i].value})',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hourly Heatmap Chart ─────────────────────────────────────────────────────

class _HourlyHeatmapChart extends StatelessWidget {
  final List<AppOrder> orders;

  const _HourlyHeatmapChart({required this.orders});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hourlyCounts = List.filled(24, 0);
    for (final o in orders) {
      final hour = o.createdAt.hour;
      hourlyCounts[hour]++;
    }

    final maxCount = hourlyCounts.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) {
      return _emptyChart(context, 'No orders for this period');
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCount * 1.3,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipColor: (_) => colorScheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} orders at ${group.x.toString().padLeft(2, '0')}:00',
                TextStyle(
                  color: colorScheme.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < 24 && idx % 3 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      idx.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 9,
                        color: colorScheme.onSurfaceVariant,
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
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
              interval: maxCount > 0
                  ? (maxCount / 3).ceilToDouble().clamp(1, double.infinity)
                  : 1,
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
          horizontalInterval: maxCount > 0
              ? (maxCount / 3).ceilToDouble().clamp(1, double.infinity)
              : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(24, (i) {
          final intensity = maxCount > 0 ? hourlyCounts[i] / maxCount : 0.0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: hourlyCounts[i].toDouble(),
                color: Color.lerp(
                  colorScheme.surfaceContainerHighest,
                  colorScheme.primary,
                  intensity,
                )!,
                width: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Status Distribution Chart ────────────────────────────────────────────────

class _StatusDistributionChart extends StatelessWidget {
  final List<AppOrder> orders;

  const _StatusDistributionChart({required this.orders});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final pending = orders.where((o) => o.status == OrderStatus.pending).length;
    final prep = orders.where((o) => o.status == OrderStatus.prep).length;
    final ready = orders.where((o) => o.status == OrderStatus.ready).length;
    final served = orders.where((o) => o.status == OrderStatus.served).length;
    final paid = orders.where((o) => o.status == OrderStatus.paid).length;

    final total = pending + prep + ready + served + paid;
    if (total == 0) {
      return _emptyChart(context, 'No orders yet');
    }

    final statusColors = {
      'Pending': colorScheme.tertiary,
      'Prep': CafeColors.warning,
      'Ready': colorScheme.secondary,
      'Served': colorScheme.primary,
      'Paid': CafeColors.success,
    };

    final counts = {
      'Pending': pending,
      'Prep': prep,
      'Ready': ready,
      'Served': served,
      'Paid': paid,
    };

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: counts.entries.map((entry) {
                final pct = total > 0 ? (entry.value / total * 100) : 0.0;
                return PieChartSectionData(
                  value: entry.value.toDouble(),
                  color: statusColors[entry.key]!,
                  title: pct >= 5 ? '${pct.round()}%' : '',
                  radius: 36,
                  titleStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColors[entry.key]!.computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 32,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: counts.entries.map((entry) {
            final color = statusColors[entry.key]!;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${entry.key} (${entry.value})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Summary Section ──────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final List<AppOrder> orders;
  final double revenue;
  final ColorScheme colorScheme;

  const _SummarySection({
    required this.orders,
    required this.revenue,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final paid = orders.where((o) => o.status == OrderStatus.paid).length;
    final pendingCount = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final cancelled = 0; // No cancelled status in model, just for placeholder

    return DoubleBezelContainer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Responsive: 2×2 on mobile, 4-column row on desktop
            Builder(
              builder: (context) {
                final isMobile = ResponsiveUtils.isMobile(context);
                return isMobile
                    ? Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width -
                                    16 * 2 -
                                    12) /
                                2,
                            child: _SummaryItem(
                              icon: Icons.check_circle_rounded,
                              label: 'Completed',
                              value: '$paid',
                              color: CafeColors.success,
                            ),
                          ),
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width -
                                    16 * 2 -
                                    12) /
                                2,
                            child: _SummaryItem(
                              icon: Icons.hourglass_empty_rounded,
                              label: 'Pending',
                              value: '$pendingCount',
                              color: colorScheme.tertiary,
                            ),
                          ),
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width -
                                    16 * 2 -
                                    12) /
                                2,
                            child: _SummaryItem(
                              icon: Icons.cancel_rounded,
                              label: 'Cancelled',
                              value: '$cancelled',
                              color: colorScheme.error,
                            ),
                          ),
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width -
                                    16 * 2 -
                                    12) /
                                2,
                            child: _SummaryItem(
                              icon: Icons.percent_rounded,
                              label: 'Completion Rate',
                              value: orders.isNotEmpty
                                  ? '${(paid / orders.length * 100).round()}%'
                                  : '0%',
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _SummaryItem(
                            icon: Icons.check_circle_rounded,
                            label: 'Completed',
                            value: '$paid',
                            color: CafeColors.success,
                          ),
                          _SummaryItem(
                            icon: Icons.hourglass_empty_rounded,
                            label: 'Pending',
                            value: '$pendingCount',
                            color: colorScheme.tertiary,
                          ),
                          _SummaryItem(
                            icon: Icons.cancel_rounded,
                            label: 'Cancelled',
                            value: '$cancelled',
                            color: colorScheme.error,
                          ),
                          _SummaryItem(
                            icon: Icons.percent_rounded,
                            label: 'Completion Rate',
                            value: orders.isNotEmpty
                                ? '${(paid / orders.length * 100).round()}%'
                                : '0%',
                            color: colorScheme.primary,
                          ),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

Widget _emptyChart(BuildContext context, String message) {
  final colorScheme = Theme.of(context).colorScheme;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bar_chart_rounded,
          size: 40,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 8),
        Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
      ],
    ),
  );
}
