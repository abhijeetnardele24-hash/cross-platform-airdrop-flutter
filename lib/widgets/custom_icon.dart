import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final bool animate;
  final Duration duration;
  final bool bounceOnTap;
  final VoidCallback? onTap;

  const CustomIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.animate = false,
    this.duration = const Duration(milliseconds: 600),
    this.bounceOnTap = false,
    this.onTap,
  });

  @override
  State<CustomIcon> createState() => _CustomIconState();
}

class _CustomIconState extends State<CustomIcon> with TickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _springAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    ));

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _springController.forward();
    }
  }

  @override
  void dispose() {
    _springController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.bounceOnTap) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final iconColor = widget.color ??
        (isDark ? CupertinoColors.white : CupertinoColors.black);

    Widget iconWidget = Icon(
      widget.icon,
      size: widget.size,
      color: iconColor,
    );

    // Spring animation for entry
    if (widget.animate) {
      iconWidget = AnimatedBuilder(
        animation: _springAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _springAnimation.value,
            child: child,
          );
        },
        child: iconWidget,
      );
    }

    // Bounce on tap
    if (widget.bounceOnTap || widget.onTap != null) {
      iconWidget = GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: child,
            );
          },
          child: iconWidget,
        ),
      );
    }

    return iconWidget;
  }
}
