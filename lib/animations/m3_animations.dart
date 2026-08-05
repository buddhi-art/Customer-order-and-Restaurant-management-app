import 'package:flutter/material.dart';

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

  const M3PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleTo = 0.97,
  });

  @override
  State<M3PressScale> createState() => _M3PressScaleState();
}

class _M3PressScaleState extends State<M3PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  bool _isHovered = false;

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

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleTo,
    ).animate(curved);
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null || widget.onLongPress != null 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
      ).animate(target: _isHovered ? 1 : 0).scaleXY(
        end: 1.02, 
        duration: const Duration(milliseconds: 150), 
        curve: Curves.easeOutCubic,
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
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slideAnim = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: premiumFluidCurve));
    final scaleAnim = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: premiumFluidCurve));

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim, 
        child: ScaleTransition(
          scale: scaleAnim,
          child: child,
        ),
      ),
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
