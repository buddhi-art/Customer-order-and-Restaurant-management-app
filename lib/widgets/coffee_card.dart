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
      child: isDesktop
          ? _buildGridCard(context)
          : _buildGridCard(context), // Enforce bento grid for mobile too
    );
  }

  // ── Grid Card (Flat Bento Box) ──────────────────────────────
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CafeColors.outline.withValues(alpha: 0.5)),
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
                            color: CafeColors.onSurfaceVariant,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.coffee,
                            size: 48,
                            color: CafeColors.onSurfaceVariant,
                          ),
                          placeholder: (_, _) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CafeColors.onSurface,
                            ),
                          ),
                        );
                },
              ),
            ),

            // ── Info Strip ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: CafeColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CafeColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: CafeColors.onSurface,
                        ),
                      ),
                      M3PressScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onAdd();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CafeColors.onSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              color: CafeColors.surface,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
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
}
