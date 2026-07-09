import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'responsive_widget.dart';

class WebHeroWidget extends StatelessWidget {
  const WebHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveUtils.isDesktop(context)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 48, right: 48, top: 80, bottom: 64),
      decoration: const BoxDecoration(
        color: AppColors.background, // Logo cream white hero color
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Text + CTA
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FOR THE DEEP ENTHUSIAST\nAND THE CURIOUS.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 64,
                        letterSpacing: -1.5,
                        height: 1.0,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 32),
                Text(
                  'Exploring the origins and artistry of the perfect pour. Discover our curated collection of single-origin roasts.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        letterSpacing: 0,
                        height: 1.4,
                      ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAction, // Copper bronze from logo
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SHOP COLLECTIONS',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 64),
          // Right side: Logo prominently displayed
          Expanded(
            flex: 1,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
