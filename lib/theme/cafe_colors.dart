import 'package:flutter/material.dart';

/// ─── Kalpa Café Premium Minimalist Color System ─────────────────────────────
/// Derived from minimalist-ui directives:
///   - Background: Pure white (#FFFFFF)
///   - Primary Surface: Warm off-white (#F9F9F8)
///   - Borders: Ultra-light gray (#EAEAEA)
///   - Accents: Desaturated washed-out pastels
class CafeColors {
  CafeColors._();

  // ── Primary: Off-Black (Primary Actions) ──
  static const Color primary = Color(0xFF111111);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF333333);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  // ── Secondary: Charcoal/Gray ──
  static const Color secondary = Color(0xFF787774);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEAEAEA);
  static const Color onSecondaryContainer = Color(0xFF111111);

  // ── Tertiary: Muted ──
  static const Color tertiary = Color(0xFF999999);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFF7F6F3);
  static const Color onTertiaryContainer = Color(0xFF111111);

  // ── Error ──
  static const Color error = Color(0xFF9F2F2D); // Text of pale red
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFDEBEC); // Pale red
  static const Color onErrorContainer = Color(0xFF9F2F2D);

  // ── Surfaces: Pure White & Bone ──
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111111);
  static const Color surfaceVariant = Color(0xFFFBFBFA);
  static const Color onSurfaceVariant = Color(0xFF787774);

  static const Color outline = Color(0xFFEAEAEA);
  static const Color outlineVariant = Color(0xFFEAEAEA);

  static const Color surfaceContainerLow = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF9F9F8);
  static const Color surfaceContainerHigh = Color(0xFFF7F6F3);

  static const Color inverseSurface = Color(0xFF111111);
  static const Color inverseOnSurface = Color(0xFFFFFFFF);
  static const Color inversePrimary = Color(0xFFEAEAEA);

  // ── Semantic Pastels (Minimalist) ──
  static const Color success = Color(0xFF346538);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFEDF3EC); // Pale green

  static const Color warning = Color(0xFF956400);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFBF3DB); // Pale yellow

  // Additional Pastel: Pale Blue
  static const Color info = Color(0xFF1F6C9F);
  static const Color infoContainer = Color(0xFFE1F3FE);

  // ── Brand Tokens ──
  static const Color ratingGold = Color(0xFF956400); // Muted gold
  static const Color creamWhite = Color(0xFFFBFBFA);
  static const Color copperBronze = Color(0xFF787774); // Now muted gray
  static const Color espressoDark = Color(0xFF111111);
  static const Color caramelLight = Color(0xFFF9F9F8);

  // ── Coffee Card Default (flattened) ──
  static const Color cardBrown = Color(0xFFF7F6F3);
  static const Color cardBrownDark = Color(0xFFEAEAEA);

  // ── Shape Tokens (Minimalist UI constraint: crisp, small radius) ──
  static const double cardRadiusCompact = 8.0;
  static const double gridCardRadius = 12.0;
  static const double innerRadius = 4.0;

  // ── Glass / Frost Effect ──
  static Color glassWhite = Colors.white.withValues(alpha: 0.8);
  static Color glassWhiteLight = Colors.white.withValues(alpha: 0.6);

  // ── Shadows (Almost non-existent) ──
  static Color shadowLight = const Color(0xFF000000).withValues(alpha: 0.02);
  static Color shadowMedium = const Color(0xFF000000).withValues(alpha: 0.04);
  static Color shadowDark = const Color(0xFF000000).withValues(alpha: 0.06);
  static Color shadowDeep = const Color(0xFF000000).withValues(alpha: 0.08);
}
