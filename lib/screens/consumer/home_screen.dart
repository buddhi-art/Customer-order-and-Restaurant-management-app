import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/table_provider.dart';
import '../../models/menu_item.dart';
import '../../models/notification.dart';
import '../../theme/m3_theme.dart';
import '../../animations/m3_animations.dart';
import '../../widgets/coffee_card.dart';
import '../../widgets/responsive_widget.dart';
import '../../ui/core/widgets/double_bezel_container.dart';

// ── Derived providers for filtered / categorized menu data (Issue 23) ──

class _SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void select(String category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<_SelectedCategoryNotifier, String>(
      _SelectedCategoryNotifier.new,
    );

class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<_SearchQueryNotifier, String>(
  _SearchQueryNotifier.new,
);

/// Computed once outside of build(): unique categories from the menu.
final uniqueCategoriesProvider = Provider<List<String>>((ref) {
  final menuItems = ref.watch(menuProvider);
  return {'All', ...menuItems.map((e) => e.category)}.toList();
});

/// Filtered menu items based on selected category and search query.
/// Matches against name AND description so a search for "caramel" or "syrup"
/// returns items with those ingredients/flavours. (Bug 4.7)
final filteredMenuProvider = Provider<List<MenuItem>>((ref) {
  final menuItems = ref.watch(menuProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return menuItems.where((item) {
    if (!item.isAvailable) return false;
    final matchesCategory =
        selectedCategory == 'All' ||
        item.category.toLowerCase() == selectedCategory.toLowerCase();
    final query = searchQuery.toLowerCase();
    final matchesSearch =
        item.name.toLowerCase().contains(query) ||
        item.description.toLowerCase().contains(query);
    return matchesCategory && matchesSearch;
  }).toList();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final notifications = ref.watch(notificationProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    // Issue 16: real user name from auth session
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'Coffee Lover';

    // Bug 4.2: show which table the customer is at
    final tableId = ref.watch(tableProvider);

    // Issue 17: time-based greeting
    final greeting = _timeGreeting();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Mobile Header
          if (!isDesktop)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                child: FadeInWidget(
                  duration: const Duration(milliseconds: 600),
                  slideOffset: const Offset(0, -0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: CafeColors.onSurfaceVariant),
                          ),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          if (tableId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CafeColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.table_restaurant_rounded,
                                      size: 14,
                                      color: CafeColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tableId.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: CafeColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      M3PressScale(
                        onTap: () =>
                            _showNotificationsSheet(context, notifications),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CafeColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: CafeColors.outline),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 24,
                                color: CafeColors.onSurface,
                              ),
                            ),
                            if (notifications.isNotEmpty)
                              Positioned(
                                top: -6,
                                right: -6,
                                child: _NotificationBadge(
                                  count: notifications.length,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (!isDesktop) const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 24,
                vertical: isDesktop ? 32 : 0,
              ),
              child: FadeInWidget(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CafeColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CafeColors.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: CafeColors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => ref
                              .read(searchQueryProvider.notifier)
                              .update(value),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search the menu...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: CafeColors.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: CafeColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Categories (Issue 23: watch provider instead of recomputing)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: isDesktop ? 48 : 24, bottom: 28),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: ref
                      .watch(uniqueCategoriesProvider)
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final selectedCategory = ref.watch(
                          selectedCategoryProvider,
                        );
                        final isSelected = selectedCategory == category;

                        return StaggeredFadeIn(
                          index: index,
                          delay: const Duration(milliseconds: 50),
                          slideOffset: const Offset(0.1, 0),
                          child: M3PressScale(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .select(category);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: const Cubic(0.32, 0.72, 0, 1),
                              margin: const EdgeInsets.only(right: 8.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? CafeColors.onSurface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: isSelected
                                      ? CafeColors.onSurface
                                      : CafeColors.outline,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? CafeColors.surface
                                      : CafeColors.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),
          ),

          // Coffee Grid/List (Issue 23: watch filteredMenuProvider)
          SliverPadding(
            padding: EdgeInsets.only(
              left: isDesktop ? 48 : 24,
              right: isDesktop ? 48 : 24,
              bottom: 120,
            ),
            sliver: isDesktop
                ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.gridColumns(
                        context,
                        mobile: 1,
                        tablet: 2,
                        desktop: 3,
                      ),
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final items = ref.watch(filteredMenuProvider);
                      final item = items[index];
                      return CoffeeCard(
                        item: item,
                        index: index,
                        onTap: () => context.push('/product/${item.id}'),
                        onAdd: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(cartProvider.notifier)
                              .addItem(item, 1, 'Medium');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    }, childCount: ref.watch(filteredMenuProvider).length),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final items = ref.watch(filteredMenuProvider);
                      final item = items[index];
                      return CoffeeCard(
                        item: item,
                        index: index,
                        onTap: () => context.push('/product/${item.id}'),
                        onAdd: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(cartProvider.notifier)
                              .addItem(item, 1, 'Medium');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    }, childCount: ref.watch(filteredMenuProvider).length),
                  ),
          ),
        ],
      ),
    );
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _showNotificationsSheet(
    BuildContext context,
    List<AppNotification> notifications,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: CafeColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              child: Text(
                'Updates',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const Divider(indent: 32, endIndent: 32),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_rounded,
                            size: 48,
                            color: CafeColors.outlineVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No new updates',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: CafeColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(32),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: DoubleBezelContainer(
                            padding: 6,
                            outerRadius: 24,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: CafeColors.surfaceContainerLow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.campaign_rounded,
                                      color: CafeColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.message,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color:
                                                    CafeColors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
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
  }
}

/// Notification badge widget
class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: CafeColors.error,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: CafeColors.onError,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
