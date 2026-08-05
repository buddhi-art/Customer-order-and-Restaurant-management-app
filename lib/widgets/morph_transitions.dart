import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../animations/m3_animations.dart';

/// Uses the premium morph transition from m3_animations.
/// No bounce, no spring — pure Apple-like deceleration with easeOutCubic.
CustomTransitionPage<void> morphTransitionPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return PremiumMorphTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}
