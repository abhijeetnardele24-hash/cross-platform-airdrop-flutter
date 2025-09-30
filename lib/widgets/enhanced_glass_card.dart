import 'dart:ui';
import 'package:flutter/material.dart';

/// Enhanced glass morphism card with better blur effects and animations
class EnhancedGlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;
  final bool enableHoverEffect;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const EnhancedGlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.border,
    this.shadows,
    this.enableHoverEffect = false,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<EnhancedGlassCard> createState() => _EnhancedGlassCardState();
}

class _EnhancedGlassCardState extends State<EnhancedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? Colors.white.withOpacity(widget.opacity)
        : Colors.white.withOpacity(widget.opacity * 1.5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
            border: widget.border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
            boxShadow: widget.shadows ??
                [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                    spreadRadius: 0,
                  ),
                ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: Container(
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color ?? defaultColor,
                      (widget.color ?? defaultColor).withOpacity(0.5),
                    ],
                  ),
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(20),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated glass container with shimmer effect
class AnimatedGlassContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double blur;
  final double opacity;

  const AnimatedGlassContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
    this.blur = 10.0,
    this.opacity = 0.2,
  });

  @override
  State<AnimatedGlassContainer> createState() =>
      _AnimatedGlassContainerState();
}

class _AnimatedGlassContainerState extends State<AnimatedGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            EnhancedGlassCard(
              blur: widget.blur,
              opacity: widget.opacity,
              child: widget.child,
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: [
                        _shimmerAnimation.value - 0.3,
                        _shimmerAnimation.value,
                        _shimmerAnimation.value + 0.3,
                      ],
                    ).createShader(bounds);
                  },
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Frosted glass app bar
class FrostedGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final double blur;
  final double opacity;
  final Color? backgroundColor;

  const FrostedGlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.blur = 10.0,
    this.opacity = 0.8,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark
                    ? Colors.black.withOpacity(opacity)
                    : Colors.white.withOpacity(opacity)),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
