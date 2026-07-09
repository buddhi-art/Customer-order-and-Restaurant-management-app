import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../animations/m3_animations.dart';
import 'cafe_colors.dart';

export 'cafe_colors.dart';

/// ─── Kalpa Café Premium Material 3 Theme ────────────────────────────────────
/// Logo-derived: Warm Cream White surface + Copper Bronze accent.
/// Uses Outfit for modern geometric headlines and Inter for neutral, highly legible body.
class M3Theme {
  M3Theme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: CafeColors.primary,
      onPrimary: CafeColors.onPrimary,
      primaryContainer: CafeColors.primaryContainer,
      onPrimaryContainer: CafeColors.onPrimaryContainer,
      secondary: CafeColors.secondary,
      onSecondary: CafeColors.onSecondary,
      secondaryContainer: CafeColors.secondaryContainer,
      onSecondaryContainer: CafeColors.onSecondaryContainer,
      tertiary: CafeColors.tertiary,
      onTertiary: CafeColors.onTertiary,
      tertiaryContainer: CafeColors.tertiaryContainer,
      onTertiaryContainer: CafeColors.onTertiaryContainer,
      error: CafeColors.error,
      onError: CafeColors.onError,
      errorContainer: CafeColors.errorContainer,
      onErrorContainer: CafeColors.onErrorContainer,
      surface: CafeColors.surface,
      onSurface: CafeColors.onSurface,
      surfaceContainerLow: CafeColors.surfaceContainerLow,
      surfaceContainer: CafeColors.surfaceContainer,
      surfaceContainerHigh: CafeColors.surfaceContainerHigh,
      outline: CafeColors.outline,
      outlineVariant: CafeColors.outlineVariant,
      inverseSurface: CafeColors.inverseSurface,
      inversePrimary: CafeColors.inversePrimary,
    );

    // ── Typography (Soft Structuralism) ──
    final headingFont = GoogleFonts.outfit;
    final bodyFont = GoogleFonts.plusJakartaSans;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CafeColors.surface,

      // ── Page Transitions: Apple-like fluid morph ──
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: _PremiumMorphPageTransitionsBuilder(),
        },
      ),

      // ── Text Theme ───────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: headingFont(
          fontSize: 64, // Massive
          fontWeight: FontWeight.w800,
          letterSpacing: -2.0,
          height: 1.05,
          color: CafeColors.onSurface,
        ),
        displayMedium: headingFont(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          height: 1.1,
          color: CafeColors.onSurface,
        ),
        displaySmall: headingFont(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.15,
          color: CafeColors.onSurface,
        ),
        headlineLarge: headingFont(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.2,
          color: CafeColors.onSurface,
        ),
        headlineMedium: headingFont(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
          color: CafeColors.onSurface,
        ),
        headlineSmall: headingFont(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.25,
          color: CafeColors.onSurface,
        ),
        titleLarge: bodyFont(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.3,
          color: CafeColors.onSurface,
        ),
        titleMedium: bodyFont(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
          color: CafeColors.onSurface,
        ),
        titleSmall: bodyFont(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
          color: CafeColors.onSurface,
        ),
        bodyLarge: bodyFont(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.6,
          color: CafeColors.onSurface,
        ),
        bodyMedium: bodyFont(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.6,
          color: CafeColors.onSurface,
        ),
        bodySmall: bodyFont(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.5,
          color: CafeColors.onSurfaceVariant,
        ),
        labelLarge: bodyFont(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          height: 1.4,
          color: CafeColors.onSurface,
        ),
        labelMedium: bodyFont(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          height: 1.4,
          color: CafeColors.onSurfaceVariant,
        ),
        labelSmall: bodyFont(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          height: 1.4,
          color: CafeColors.onSurfaceVariant,
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: CafeColors.surface,
        foregroundColor: CafeColors.onSurface,
        titleTextStyle: headingFont(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: CafeColors.onSurface,
        ),
        surfaceTintColor: CafeColors.surface,
      ),

      // SHAPE CONSISTENCY LOCK: Exaggerated Squircle 32px
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: CafeColors.outlineVariant, width: 1),
        ),
        color: CafeColors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: CafeColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: CafeColors.surfaceContainerHigh,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bodyFont(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: CafeColors.onSurface,
            );
          }
          return bodyFont(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: CafeColors.onSurfaceVariant,
          );
        }),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: CafeColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: CafeColors.surfaceContainerHigh,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bodyFont(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: CafeColors.onSurface,
            );
          }
          return bodyFont(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: CafeColors.onSurfaceVariant,
          );
        }),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CafeColors.onSurface,
        foregroundColor: CafeColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),

      chipTheme: ChipThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        labelStyle: bodyFont(fontSize: 14, fontWeight: FontWeight.w500),
        side: const BorderSide(color: CafeColors.outlineVariant),
        backgroundColor: CafeColors.surface,
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: CafeColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CafeColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),

      // SHAPE CONSISTENCY LOCK: Inputs = 12px soft
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CafeColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CafeColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CafeColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CafeColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CafeColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CafeColors.primary;
          }
          return CafeColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CafeColors.primaryContainer;
          }
          return CafeColors.outlineVariant;
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: CafeColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: CafeColors.inverseSurface,
        contentTextStyle: bodyFont(
          color: CafeColors.inverseOnSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // SHAPE CONSISTENCY LOCK: Buttons = Pill 100px
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          side: const BorderSide(color: CafeColors.outlineVariant),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: WidgetStatePropertyAll(
            bodyFont(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CafeColors.primary,
        linearTrackColor: CafeColors.outlineVariant,
      ),
    );
  }
}

/// ─── Premium Morph Page Transitions (Apple-like) ────────────────────────────
class _PremiumMorphPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return PremiumMorphTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
