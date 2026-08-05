import 'package:flutter/material.dart';

class PremiumCtaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;

  const PremiumCtaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
  });

  @override
  State<PremiumCtaButton> createState() => _PremiumCtaButtonState();
}

class _PremiumCtaButtonState extends State<PremiumCtaButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _iconSlideAnimation;

  @override
  void initState() {
    super.initState();
    // Custom cubic-bezier mimicking physical tension
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 250),
    );
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.32, 0.72, 0, 1),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(curvedAnimation);
    _iconSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, -0.05), // slightly up and right
    ).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateState() {
    if (widget.isDisabled || widget.isLoading) {
      _controller.reverse();
      return;
    }
    if (_isPressed || _isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(PremiumCtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDisabled != oldWidget.isDisabled || widget.isLoading != oldWidget.isLoading) {
      _updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = widget.backgroundColor ?? colorScheme.onSurface;
    final fg = widget.foregroundColor ?? colorScheme.surface;
    
    final bool isInteractive = !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) {
        if (!isInteractive) return;
        setState(() => _isHovered = true);
        _updateState();
      },
      onExit: (_) {
        if (!isInteractive) return;
        setState(() => _isHovered = false);
        _updateState();
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!isInteractive) return;
          setState(() => _isPressed = true);
          _updateState();
        },
        onTapUp: (_) {
          if (!isInteractive) return;
          setState(() => _isPressed = false);
          _updateState();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          if (!isInteractive) return;
          setState(() => _isPressed = false);
          _updateState();
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: (widget.isDisabled || widget.isLoading) ? 0.6 : 1.0,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 6, top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.isFullWidth)
                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (widget.isLoading) ...[
                    const SizedBox(width: 16),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: fg.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: fg,
                          ),
                        ),
                      ),
                    ),
                  ] else if (widget.trailingIcon != null) ...[
                    const SizedBox(width: 16),
                    SlideTransition(
                      position: _iconSlideAnimation,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: fg.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            widget.trailingIcon,
                            size: 20,
                            color: fg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
