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
    this.outerRadius = 12.0, // Default to crisp radius
    this.padding = 0.0,      // Strip outer gap by default
    this.innerColor,
    this.showInnerHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // In minimalist UI, we strip the double bezel and return a crisp flat container.
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding > 0 ? EdgeInsets.all(padding) : null,
      decoration: BoxDecoration(
        color: innerColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(12), // Strict 12px for bento box
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
