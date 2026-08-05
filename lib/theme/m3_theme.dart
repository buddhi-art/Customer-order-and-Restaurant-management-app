import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../animations/m3_animations.dart';
import 'cafe_colors.dart';

export 'cafe_colors.dart';

/// ─── Kalpa Café Minimalist Editorial Theme ───────────────────────────────────
/// Utilitarian minimalism: high contrast, strict macro-whitespace, bento grids,
/// and flat component architecture.
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

    // ── Typography (Editorial) ──
    final headingFont = GoogleFonts.newsreader;

    TextStyle bodyFont({
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: 'SF Pro Display',
        fontFamilyFallback: const [
          'Geist Sans',
          'Helvetica Neue',
          'sans-serif',
        ],
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }

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
          fontWeight: FontWeight.w600,
          letterSpacing: -1.5,
          height: 1.05,
          color: CafeColors.onSurface,
        ),
        displayMedium: headingFont(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.0,
          height: 1.1,
          color: CafeColors.onSurface,
        ),
        displaySmall: headingFont(
          fontSize: 40,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          height: 1.15,
          color: CafeColors.onSurface,
        ),
        headlineLarge: headingFont(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          height: 1.2,
          color: CafeColors.onSurface,
        ),
        headlineMedium: headingFont(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          height: 1.2,
          color: CafeColors.onSurface,
        ),
        headlineSmall: headingFont(
          fontSize: 24,
          fontWeight: FontWeight.w500,
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
          height: 1.6, // Generous line height for editorial feel
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
          letterSpacing: 0.5, // Less tracking than generic M3
          height: 1.4,
          color: CafeColors.onSurface,
        ),
        labelMedium: bodyFont(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.4,
          color: CafeColors.onSurfaceVariant,
        ),
        labelSmall: bodyFont(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
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
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: CafeColors.onSurface,
        ),
        surfaceTintColor: CafeColors.surface,
      ),

      // SHAPE CONSISTENCY LOCK: Bento Box 12px
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(8),
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
        hoverElevation: 6,
        focusElevation: 2,
        highlightElevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return CafeColors.onSurface.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.pressed)) {
              return CafeColors.onSurface.withValues(alpha: 0.12);
            }
            return null;
          }),
        ),
      ),

      chipTheme: ChipThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ), // Pill shaped for tags as per protocol
        labelStyle: bodyFont(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        side: BorderSide.none,
        backgroundColor: CafeColors.surfaceContainerHigh,
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: CafeColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CafeColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),

      // SHAPE CONSISTENCY LOCK: Inputs = 6px sharp
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CafeColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: CafeColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: CafeColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: CafeColors.onSurface, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
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
            return CafeColors.onSurface;
          }
          return CafeColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CafeColors.surfaceContainerHigh;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // SHAPE CONSISTENCY LOCK: Buttons = 6px slight radius
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: CafeColors.primary,
              foregroundColor: CafeColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
            ).copyWith(
              // Enhanced hover state for animation
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white.withValues(alpha: 0.15);
                }
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withValues(alpha: 0.25);
                }
                return null;
              }),
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) return 6.0;
                if (states.contains(WidgetState.pressed)) return 1.0;
                return 0.0;
              }),
            ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return 4.0;
            if (states.contains(WidgetState.pressed)) return 1.0;
            return 0.0;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.25);
            }
            return null;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: const BorderSide(color: CafeColors.outlineVariant),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return CafeColors.onSurface.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.pressed)) {
              return CafeColors.onSurface.withValues(alpha: 0.12);
            }
            return null;
          }),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
