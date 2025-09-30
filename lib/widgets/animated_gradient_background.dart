import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final bool animate;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 4),
    this.animate = true,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      )..repeat(reverse: true);

      _colorAnimation = ColorTween(
        begin: widget.colors[0],
        end: widget.colors.length > 1 ? widget.colors[1] : widget.colors[0],
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value ?? widget.colors[0],
                widget.colors.length > 1 ? widget.colors[1] : widget.colors[0],
                widget.colors.length > 2 ? widget.colors[2] : widget.colors[0],
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
