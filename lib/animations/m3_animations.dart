import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/cafe_colors.dart';

// ─── Premium Fluid Curves (No Bounce — Apple-like) ───────────────────────────

/// Heavy, cinematic ease — the signature curve for all motion.
/// Equivalent to cubic-bezier(0.32, 0.72, 0.0, 1.0).
const premiumFluidCurve = Cubic(0.32, 0.72, 0.0, 1.0);

/// Strong ease-out for UI interactions (Emil Kowalski)
const m3FadeCurve = Cubic(0.23, 1.0, 0.32, 1.0);

/// Strong ease-in-out for on-screen movement (Emil Kowalski)
const m3MorphCurve = Cubic(0.77, 0.0, 0.175, 1.0);

// ─── Declarative Animations (flutter_animate) ────────────────────────────────

/// A fade+slide entry animation using cinematic cubic-bezier curves.
/// GPU-composited via flutter_animate. No spring, no bounce.
class M3FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final Offset slideOffset;

  const M3FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = const Offset(0, 0.06),
  });

  @override
  Widget build(BuildContext context) {
    // Staggered delay capped to prevent excessively long waits
    final delay = (baseDelay * index).inMilliseconds;
    final cappedDelay = delay > 500 ? 500 : delay;

    return child
        .animate(delay: Duration(milliseconds: cappedDelay))
        .fade(duration: duration, curve: m3FadeCurve)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: duration,
          curve: premiumFluidCurve,
        )
        .slide(
          begin: slideOffset,
          end: Offset.zero,
          duration: duration,
          curve: premiumFluidCurve,
        );
  }
}

// ─── Reusable Animation Widgets (Smooth Scale) ───────────────────────────────

/// Smooth press-scale animation — no spring, no bounce.
/// Uses a heavy cubic-bezier for a premium, expensive feel.
class M3PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleTo;
  final bool blurOnPress;

  const M3PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleTo = 0.97,
    this.blurOnPress = true,
  });

  @override
  State<M3PressScale> createState() => _M3PressScaleState();
}

class _M3PressScaleState extends State<M3PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 250),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: m3FadeCurve,
      reverseCurve: premiumFluidCurve,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleTo).animate(curved);
    _blurAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scaledChild = Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
          if (widget.blurOnPress && _blurAnimation.value > 0) {
            return ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: scaledChild,
            );
          }
          return scaledChild;
        },
        child: widget.child,
      ),
    );
  }
}

// ─── Premium Morph Page Transition ───────────────────────────────────────────

/// Apple-like page transition: gentle fade + subtle slide from right.
/// Uses easeOutCubic for a fluid, linear deceleration feel.
/// The slide is only 3% of screen width so it feels organic, not jarring.
class PremiumMorphTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const PremiumMorphTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnim = CurvedAnimation(
      parent: animation,
      curve: m3FadeCurve,
      reverseCurve: m3FadeCurve,
    );
    final slideAnim = Tween<Offset>(
      begin: const Offset(0.03, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: premiumFluidCurve));

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(opacity: fadeAnim, child: child),
    );
  }
}

// ─── Staggered Fade-In Widget ────────────────────────────────────────────────

/// A widget that animates its child in with a staggered fade + slide-up effect.
class StaggeredFadeIn extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const StaggeredFadeIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = const Offset(0, 0.06),
  });

  @override
  Widget build(BuildContext context) {
    return M3FadeSlideIn(
      index: index,
      baseDelay: delay,
      duration: duration,
      slideOffset: slideOffset,
      child: child,
    );
  }
}

/// A simpler fade-in widget for single elements (no staggering).
class FadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset slideOffset;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.slideOffset = const Offset(0, 0.04),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fade(duration: duration, curve: m3FadeCurve)
        .slide(
          begin: slideOffset,
          end: Offset.zero,
          duration: duration,
          curve: premiumFluidCurve,
        );
  }
}

// ─── Ripple-Reveal (Button press) ────────────────────────────────────────────

/// Creates a material ripple reveal effect on tap.
class M3RippleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;

  const M3RippleButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = (borderRadius ?? BorderRadius.circular(16)) as BorderRadius;
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: CafeColors.shadowMedium,
        highlightColor: CafeColors.glassWhiteLight,
        child: child,
      ),
    );
  }
}
