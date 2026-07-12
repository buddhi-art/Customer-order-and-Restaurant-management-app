import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/menu_item.dart';
import '../theme/m3_theme.dart';
import '../animations/m3_animations.dart';
import 'responsive_widget.dart';

class CoffeeCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final int index;

  const CoffeeCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAdd,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return StaggeredFadeIn(
      index: index,
      slideOffset: const Offset(0, 0.08),
      child: isDesktop ? _buildGridCard(context) : _buildListCard(context),
    );
  }

  // ── Grid Card (Reference‑inspired layout) ──────────────────────────────
  // Image fills the top portion, then name, rating, price + add button below.
  // No description — the image and name do the talking.
  Widget _buildGridCard(BuildContext context) {
    return M3PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      scaleTo: 0.97,
      child: Container(
        decoration: BoxDecoration(
          color: CafeColors.surface,
          borderRadius: BorderRadius.circular(CafeColors.gridCardRadius),
          boxShadow: [
            BoxShadow(
              color: CafeColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image ──────────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Builder(
                builder: (context) {
                  final url = item.imageUrl.replaceAll('.jpeg', '.png');
                  return url.startsWith('assets/')
                      ? Image.asset(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.coffee,
                            size: 48,
                            color: CafeColors.onSurface,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.coffee,
                            size: 48,
                            color: CafeColors.onSurface,
                          ),
                          placeholder: (_, _) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CafeColors.primary,
                            ),
                          ),
                        );
                },
              ),
            ),

            // ── Info Strip ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row with inline rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Compact rating pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: CafeColors.ratingGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            CafeColors.innerRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: CafeColors.ratingGold,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CafeColors.ratingGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Price + Add button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: CafeColors.primary,
                        ),
                      ),
                      M3PressScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onAdd();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CafeColors.onSurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: CafeColors.surface,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List Card (horizontal compact) ─────────────────────────────────────
  Widget _buildListCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: M3PressScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        scaleTo: 0.98,
        child: Container(
          decoration: BoxDecoration(
            color: CafeColors.surface,
            borderRadius: BorderRadius.circular(CafeColors.cardRadiusCompact),
            boxShadow: [
              BoxShadow(
                color: CafeColors.shadowMedium,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: CafeColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(CafeColors.innerRadius),
                    border: Border.all(color: CafeColors.outline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Builder(
                    builder: (context) {
                      final url = item.imageUrl.replaceAll('.jpeg', '.png');
                      return url.startsWith('assets/')
                          ? Image.asset(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.coffee,
                                color: CafeColors.onSurfaceVariant,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(
                                Icons.coffee,
                                color: CafeColors.onSurfaceVariant,
                              ),
                              placeholder: (_, _) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: CafeColors.ratingGold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CafeColors.ratingGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Price & Add
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: CafeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    M3PressScale(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onAdd();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CafeColors.onSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: CafeColors.surface,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
