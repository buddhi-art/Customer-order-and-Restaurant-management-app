import 'package:flutter/material.dart';

/// Responsive breakpoint helpers for mobile-friendly layouts.
/// Usage: wrap stat rows/grids with ResponsiveRow to auto-stack on mobile.
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Breakpoints
  static const double mobile = 600;
  static const double tablet = 900;

  /// Returns true if screen width is mobile-sized (< 600px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Returns true if screen width is tablet-sized (600–900px)
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobile && w < tablet;
  }

  /// Returns true if screen width is desktop-sized (≥ 900px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  /// Returns cross-axis count for grids (2 on mobile, more on larger screens)
  static int gridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Returns padding appropriate for the screen size
  static EdgeInsets screenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
  }

  /// Returns the horizontal padding value
  static double horizontalPadding(BuildContext context) =>
      isMobile(context) ? 16 : 24;

  /// Returns whether stats should be in a single row or stacked
  static Axis statsAxis(BuildContext context) =>
      isMobile(context) ? Axis.vertical : Axis.horizontal;
}

/// A responsive row that wraps items into a column on mobile screens.
/// Use this to replace horizontal `Row` of stat cards / KPI cards.
class ResponsiveStatsRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveStatsRow({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: children
            .map(
              (child) => Padding(
                padding: EdgeInsets.only(bottom: runSpacing),
                child: child,
              ),
            )
            .toList(),
      );
    }

    // Tablet / desktop: side-by-side
    return Row(
      children: children
          .map(
            (child) => Padding(
              padding: EdgeInsets.only(right: spacing),
              child: Expanded(child: child),
            ),
          )
          .toList(),
    );
  }
}

/// A responsive 2-column layout that stacks on mobile.
/// For side-by-side panels like Charts + Alerts.
class ResponsiveTwoPanel extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double spacing;
  final int flexLeft;
  final int flexRight;

  const ResponsiveTwoPanel({
    super.key,
    required this.left,
    required this.right,
    this.spacing = 16,
    this.flexLeft = 3,
    this.flexRight = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          SizedBox(height: spacing),
          right,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: flexLeft, child: left),
        SizedBox(width: spacing),
        Expanded(flex: flexRight, child: right),
      ],
    );
  }
}
