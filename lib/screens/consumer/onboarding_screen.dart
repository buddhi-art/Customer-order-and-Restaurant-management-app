import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/cafe_colors.dart';
import '../../animations/m3_animations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CafeColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  // ── Logo ────────────────────────────────────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CafeColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: CafeColors.outline),
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 56,
                          width: 56,
                          semanticLabel: 'Kalpa Coffee logo',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Brand Name ──────────────────────────────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'कल्प',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: CafeColors.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── Tagline ─────────────────────────────────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 150),
                    child: Text(
                      'Handmade in light.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: CafeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Headline ─────────────────────────────────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 250),
                    child: Text(
                      'Experience the\nperfect brew.',
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Subhead ─────────────────────────────────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Join Kalpa and elevate your daily coffee ritual\nwith curated artisanal blends.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: CafeColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Value Pills (compact horizontal row) ────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 350),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _CompactPill(
                          icon: Icons.coffee_rounded,
                          label: 'Artisanal',
                        ),
                        _CompactPill(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Slow Brewed',
                        ),
                        _CompactPill(
                          icon: Icons.wb_sunny_rounded,
                          label: 'Feels Like Home',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── CTA Button ──────────────────────────────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 450),
                    child: SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        button: true,
                        label: 'Get Started',
                        child: M3PressScale(
                          onTap: () => context.push('/scan'),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: CafeColors.onSurface,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: CafeColors.onSurface.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Text(
                                    'Get Started',
                                    textAlign: TextAlign.center,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: CafeColors.surface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Colors.white10,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: CafeColors.surface,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Secondary Links ──────────────────────────────────────────
                  FadeInWidget(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 550),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Log in',
                          child: M3PressScale(
                            onTap: () => context.push('/login'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(
                                'Log in',
                                style: textTheme.titleSmall?.copyWith(
                                  color: CafeColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: const BoxDecoration(
                            color: CafeColors.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Admin Access',
                          child: M3PressScale(
                            onTap: () => context.push('/admin/login'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(
                                'Admin Access',
                                style: textTheme.titleSmall?.copyWith(
                                  color: CafeColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact, minimal pill for value propositions.
class _CompactPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CompactPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: CafeColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CafeColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CafeColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: CafeColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
