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
import '../../widgets/responsive_widget.dart';
import '../../widgets/coffee_card.dart';
import 'user_shell.dart';

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

final uniqueCategoriesProvider = Provider<List<String>>((ref) {
  final menuItems = ref.watch(menuProvider);
  return {'All', ...menuItems.map((e) => e.category)}.toList();
});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'Coffee Lover';
    final tableId = ref.watch(tableProvider);
    final greeting = _timeGreeting();

    return UserShell(
      title: 'Home',
      body: CustomScrollView(
        slivers: [
          // Greeting & Notifications (Flattened, no glass)
          if (!isDesktop)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                            '$greeting $name',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: CafeColors.onSurfaceVariant),
                          ),
                          if (tableId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Table ${tableId.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: CafeColors.primary,
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
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 24,
                              color: CafeColors.onSurface,
                            ),
                            if (notifications.isNotEmpty)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: CafeColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    notifications.length > 99
                                        ? '99+'
                                        : '${notifications.length}',
                                    style: const TextStyle(
                                      color: CafeColors.onError,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
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

          // Editorial Hero Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 16),
              child: FadeInWidget(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CafeColors.onSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning ritual.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontFamily: 'Newsreader',
                              fontWeight: FontWeight.w400,
                              color: CafeColors.surface,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Experience artisanal coffee\nbrewed with passion.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CafeColors.surface.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      M3PressScale(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: CafeColors.surface.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: CafeColors.surface.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'Order Now',
                            style: TextStyle(
                              color: CafeColors.surface,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Categories (Flat border style)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: isDesktop ? 48 : 16, bottom: 24),
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
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? CafeColors.onSurface
                                      : CafeColors.outline.withValues(
                                          alpha: 0.5,
                                        ),
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
                                      ? FontWeight.w600
                                      : FontWeight.w500,
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

          // Coffee Grid (Bento style handled by CoffeeCard)
          SliverPadding(
            padding: EdgeInsets.only(
              left: isDesktop ? 48 : 16,
              right: isDesktop ? 48 : 16,
              bottom: 120,
            ),
            sliver: isDesktop
                ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.gridColumns(
                        context,
                        mobile: 2,
                        tablet: 3,
                        desktop: 4,
                      ),
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    }, childCount: ref.watch(filteredMenuProvider).length),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
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
                              behavior: SnackBarBehavior.floating,
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
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _showNotificationsSheet(
    BuildContext context,
    List<AppNotification> notifications,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CafeColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CafeColors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Updates',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Newsreader',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: CafeColors.outline.withValues(alpha: 0.5),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No new updates',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: CafeColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CafeColors.outline.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: CafeColors.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.message,
                                      style: TextStyle(
                                        color: CafeColors.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
