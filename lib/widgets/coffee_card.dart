import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/menu_item.dart';
import '../theme/m3_theme.dart';
import '../animations/m3_animations.dart';
import 'responsive_widget.dart';
import '../ui/core/widgets/double_bezel_container.dart';
import '../ui/core/widgets/premium_cta_button.dart';

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

    // Apply staggered fade in for all cards in lists
    return StaggeredFadeIn(
      index: index,
      slideOffset: const Offset(0, 0.1),
      child: isDesktop ? _buildGridCard(context) : _buildListCard(context),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    return M3PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      scaleTo: 0.98,
      child: DoubleBezelContainer(
        outerRadius: 32,
        padding: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Builder(
                builder: (context) {
                  final url = item.imageUrl.replaceAll('.jpeg', '.png');
                  return url.startsWith('assets/')
                      ? Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.coffee, color: CafeColors.onSurface))
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Icon(Icons.coffee, color: CafeColors.onSurface),
                          placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description.isNotEmpty ? item.description : 'Balanced & smooth single origin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CafeColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: CafeColors.primary,
                          ),
                        ),
                        PremiumCtaButton(
                          text: 'Add',
                          trailingIcon: Icons.add_rounded,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onAdd();
                          },
                        ),
                      ],
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

  Widget _buildListCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: M3PressScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        scaleTo: 0.98,
        child: DoubleBezelContainer(
          outerRadius: 28,
          padding: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: CafeColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CafeColors.outline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Builder(
                    builder: (context) {
                      final url = item.imageUrl.replaceAll('.jpeg', '.png');
                      return url.startsWith('assets/')
                          ? Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.coffee, color: CafeColors.onSurfaceVariant))
                          : CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(Icons.coffee, color: CafeColors.onSurfaceVariant),
                              placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description.isNotEmpty ? item.description : 'Balanced & smooth single origin',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CafeColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 12),
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
