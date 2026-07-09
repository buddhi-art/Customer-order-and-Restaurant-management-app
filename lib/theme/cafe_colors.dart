import 'package:flutter/material.dart';

/// ─── Kalpa Café Premium Material 3 Color System ─────────────────────────────
/// Derived directly from the official Kalpa logo:
///   - Background: Warm cream white (#F5F0E8) — the hero color
///   - Brand mark: Copper/bronze (#9A6B3A) — primary accent
///   - Deep espresso (#2A1A0E) — text
class CafeColors {
  CafeColors._();

  // ── Primary: Warm Copper Bronze (from logo mark) ──
  static const Color primary = Color(0xFF9A6B3A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFBF8A54);
  static const Color onPrimaryContainer = Color(0xFF2A1A0E);

  // ── Secondary: Deep Espresso (text & structure) ──
  static const Color secondary = Color(0xFF2A1A0E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD4CBC0);
  static const Color onSecondaryContainer = Color(0xFF2A1A0E);

  // ── Tertiary: Leaf/sage green (from logo leaf detail) ──
  static const Color tertiary = Color(0xFF7D8F79);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFD6E4D2);
  static const Color onTertiaryContainer = Color(0xFF1E2B1C);

  // ── Error ──
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // ── Surfaces: Warm Cream (Soft Structuralism) ──
  static const Color surface = Color(0xFFFCFAF0);
  static const Color onSurface = Color(0xFF1F1B16);
  static const Color surfaceVariant = Color(0xFFF3EFE1);
  static const Color onSurfaceVariant = Color(0xFF5A5248);

  static const Color outline = Color(0xFFE8E2D2);
  static const Color outlineVariant = Color(0xFFF2ECE0);

  static const Color surfaceContainerLow = Color(0xFFFDFCF6);
  static const Color surfaceContainer = Color(0xFFF7F4E8);
  static const Color surfaceContainerHigh = Color(0xFFEBE6D8);

  static const Color inverseSurface = Color(0xFF0A0A0A);
  static const Color inverseOnSurface = Color(0xFFFFFFFF);
  static const Color inversePrimary = Color(0xFFEFEFEF);

  // ── Semantic ──
  static const Color success = Color(0xFF2E8555);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD9F2E6);
  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFEF3C7);

  // ── Brand Tokens ──
  static const Color ratingGold = Color(0xFFEAB308);
  static const Color creamWhite = Color(0xFFFCFAF0);
  static const Color copperBronze = Color(0xFF9A6B3A);
  static const Color espressoDark = Color(0xFF1F1B16);
  static const Color caramelLight = Color(0xFFF7F4E8);

  // ── Coffee Card Default (warm brown gradient base) ──
  static const Color cardBrown = Color(0xFF5C3318);
  static const Color cardBrownDark = Color(0xFF3D2010);

  // ── Glass / Frost Effect ──
  static Color glassWhite = Colors.white.withValues(alpha: 0.18);
  static Color glassWhiteLight = Colors.white.withValues(alpha: 0.10);

  // ── Shadows (warm-tinted) ──
  static Color shadowLight = const Color(0xFF2A1A0E).withValues(alpha: 0.04);
  static Color shadowMedium = const Color(0xFF2A1A0E).withValues(alpha: 0.08);
  static Color shadowDark = const Color(0xFF2A1A0E).withValues(alpha: 0.12);
  static Color shadowDeep = const Color(0xFF2A1A0E).withValues(alpha: 0.20);
}
