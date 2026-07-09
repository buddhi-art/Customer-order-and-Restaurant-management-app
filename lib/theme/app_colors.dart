import 'package:flutter/material.dart';
import 'cafe_colors.dart';

/// Legacy AppColors — maps to CafeColors for backward compatibility.
/// All new code should import CafeColors directly from cafe_colors.dart.
class AppColors {
  // Backgrounds
  static const Color background = CafeColors.surface;
  static const Color cardDark = CafeColors.surfaceContainerHigh;
  static const Color cardMedium = CafeColors.surfaceContainer;

  // Accent / Action
  static const Color primaryAction = CafeColors.primary;
  static const Color primaryLight = CafeColors.primaryContainer;
  static const Color primaryDark = CafeColors.inversePrimary;

  // Text
  static const Color textPrimary = CafeColors.onSurface;
  static const Color textSecondary = CafeColors.onSurfaceVariant;
  static const Color textOnDark = CafeColors.onPrimary;

  // Shadows
  static const Color shadowLight = CafeColors.surfaceContainerLow;
  static const Color shadowDark = CafeColors.outlineVariant;

  // Accents
  static const Color ratingPill = CafeColors.ratingGold;
  static const Color bottomNav = CafeColors.surface;
  static const Color searchIcon = CafeColors.primary;

  // Card gradient
  static const Color cardGradientStart = CafeColors.primary;
  static const Color cardGradientEnd = CafeColors.primaryContainer;

  // Success / Error
  static const Color success = CafeColors.success;
  static const Color error = CafeColors.error;
}
