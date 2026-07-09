import 'package:flutter/material.dart';

class DoubleBezelContainer extends StatelessWidget {
  final Widget child;
  final double outerRadius;
  final double padding;
  final Color? innerColor;
  final bool showInnerHighlight;

  const DoubleBezelContainer({
    super.key,
    required this.child,
    this.outerRadius = 32.0,
    this.padding = 6.0,
    this.innerColor,
    this.showInnerHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final innerRadius = outerRadius - padding;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05) 
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: innerColor ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(innerRadius),
          boxShadow: showInnerHighlight ? [
            // Inner top highlight simulation using a slight drop shadow pointing down 
            // from the inside, or just a subtle border.
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.6),
              offset: const Offset(0, 1),
              blurRadius: 1,
              spreadRadius: -1,
            ),
          ] : null,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
