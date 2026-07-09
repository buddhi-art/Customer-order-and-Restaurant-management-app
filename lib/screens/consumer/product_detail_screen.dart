import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/menu_item.dart';
import '../../theme/cafe_colors.dart';
import '../../widgets/staggered_animations.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String selectedSize = 'Medium';
  String selectedMilkType = 'Whole Milk';
  int quantity = 1;
  final sizes = ['Small', 'Medium', 'Large'];
  final milkTypes = ['Whole Milk', 'Oat Milk', 'Almond Milk', 'Skim Milk'];

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuProvider);
    final itemIndex = menuItems.indexWhere(
      (element) => element.id == widget.id,
    );

    if (itemIndex == -1) {
      return Scaffold(
        backgroundColor: CafeColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: CafeColors.onSurface,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Item not found',
            style: TextStyle(
              color: CafeColors.onSurfaceVariant,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final item = menuItems[itemIndex];
    final isFav = ref.watch(favoritesProvider).contains(item.id);

    return Scaffold(
      backgroundColor: CafeColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  M3PressScale(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CafeColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CafeColors.outline),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: CafeColors.onSurface,
                      ),
                    ),
                  ),
                  M3PressScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(item.id);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CafeColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CafeColors.outline),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFav
                            ? CafeColors.error
                            : CafeColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Hero image ──
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.32,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Hero(
                  tag: 'coffee_image_${item.id}',
                  child: Builder(
                    builder: (context) {
                      final url = item.imageUrl.replaceAll('.jpeg', '.png');
                      final imgWidget = url.startsWith('assets/')
                          ? Image.asset(
                              url,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.coffee,
                                    size: 80,
                                    color: CafeColors.onSurfaceVariant
                                        .withValues(alpha: 0.3),
                                  ),
                            )
                          : CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.contain,
                              memCacheWidth: 400,
                              memCacheHeight: 400,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: CafeColors.primary,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.coffee,
                                size: 80,
                                color: CafeColors.onSurfaceVariant.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            );

                      return Center(child: imgWidget);
                    },
                  ),
                ),
              ),
            ),

            // ── Details Section ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontSize: 32,
                                  color: CafeColors.onSurface,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: CafeColors.ratingGold.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: CafeColors.ratingGold.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: CafeColors.ratingGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.rating.toString(),
                                style: const TextStyle(
                                  color: CafeColors.ratingGold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // About card
                    DoubleBezelContainer(
                          outerRadius: 28,
                          padding: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: CafeColors.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.description,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: CafeColors.onSurfaceVariant,
                                        height: 1.6,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),

                    // ── Size Selector ──
                    Text(
                      'Coffee Size',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: CafeColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: sizes.map((size) {
                        final isSelected = selectedSize == size;
                        return Expanded(
                          child: M3PressScale(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => selectedSize = size);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? CafeColors.onSurface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: isSelected
                                      ? CafeColors.onSurface
                                      : CafeColors.outline,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected
                                          ? CafeColors.surface
                                          : CafeColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_calculateVolume(item)}ml',
                                    style: TextStyle(
                                      color: isSelected
                                          ? CafeColors.surface.withValues(
                                              alpha: 0.7,
                                            )
                                          : CafeColors.onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Milk Type Selector ──
                    Text(
                      'Milk Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: CafeColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: milkTypes.map((milk) {
                          final isSelected = selectedMilkType == milk;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: M3PressScale(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => selectedMilkType = milk);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
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
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  milk,
                                  style: TextStyle(
                                    color: isSelected
                                        ? CafeColors.surface
                                        : CafeColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Price + Quantity ──
                    Row(
                      children: [
                        // Price pill
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: CafeColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: CafeColors.outline),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '\$ ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: CafeColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Quantity selector
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: CafeColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: CafeColors.outline),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                M3PressScale(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: CafeColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: CafeColors.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    color: CafeColors.onSurface,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                M3PressScale(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => quantity++);
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: CafeColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: CafeColors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Add to Cart button ──
                    M3PressScale(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(cartProvider.notifier)
                            .addItem(
                              item,
                              quantity,
                              selectedSize,
                              milkType: selectedMilkType,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$quantity ${item.name} added to cart!',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: CafeColors.onSurface,
                          ),
                        );
                        context.pop();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: CafeColors.onSurface,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: CafeColors.shadowMedium,
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: CafeColors.surface,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateVolume(MenuItem item) {
    if (selectedSize == 'Small') return (item.volumeMl * 0.75).round();
    if (selectedSize == 'Large') return (item.volumeMl * 1.5).round();
    return item.volumeMl;
  }
}
