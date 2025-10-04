import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Advanced slide transition with blur and scale effects
class AdvancedSlideTransition extends PageRouteBuilder {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final bool enableBlur;
  final bool enableScale;

  AdvancedSlideTransition({
    required this.child,
    this.direction = SlideDirection.rightToLeft,
    this.duration = const Duration(milliseconds: 400),
    this.enableBlur = true,
    this.enableScale = false,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              child,
              animation,
              secondaryAnimation,
              direction,
              enableBlur,
              enableScale,
            );
          },
        );

  static Widget _buildTransition(
    Widget child,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    SlideDirection direction,
    bool enableBlur,
    bool enableScale,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(direction),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    final scaleAnimation = Tween<double>(
      begin: enableScale ? 0.9 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    ));

    final blurAnimation = Tween<double>(
      begin: enableBlur ? 10.0 : 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    // Secondary animation for the previous page
    final secondarySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _getSecondaryOffset(direction),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInCubic,
    ));

    final secondaryScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOut,
    ));

    return Stack(
      children: [
        // Previous page with exit animation
        if (secondaryAnimation.value > 0)
          SlideTransition(
            position: secondarySlideAnimation,
            child: Transform.scale(
              scale: secondaryScaleAnimation.value,
              child: Container(
                color: Colors.black.withOpacity(secondaryAnimation.value * 0.3),
              ),
            ),
          ),
        
        // New page with entrance animation
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: enableBlur && blurAnimation.value > 0
                  ? BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blurAnimation.value,
                        sigmaY: blurAnimation.value,
                      ),
                      child: child,
                    )
                  : child,
            ),
          ),
        ),
      ],
    );
  }

  static Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.rightToLeft:
        return const Offset(1.0, 0.0);
      case SlideDirection.leftToRight:
        return const Offset(-1.0, 0.0);
      case SlideDirection.topToBottom:
        return const Offset(0.0, -1.0);
      case SlideDirection.bottomToTop:
        return const Offset(0.0, 1.0);
    }
  }

  static Offset _getSecondaryOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.rightToLeft:
        return const Offset(-0.3, 0.0);
      case SlideDirection.leftToRight:
        return const Offset(0.3, 0.0);
      case SlideDirection.topToBottom:
        return const Offset(0.0, 0.3);
      case SlideDirection.bottomToTop:
        return const Offset(0.0, -0.3);
    }
  }
}

enum SlideDirection { rightToLeft, leftToRight, topToBottom, bottomToTop }

// Morphing transition with shape changes
class MorphingTransition extends PageRouteBuilder {
  final Widget child;
  final Widget? heroWidget;
  final String? heroTag;
  final Duration duration;

  MorphingTransition({
    required this.child,
    this.heroWidget,
    this.heroTag,
    this.duration = const Duration(milliseconds: 600),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildMorphingTransition(
              child,
              animation,
              secondaryAnimation,
              heroWidget,
            );
          },
        );

  static Widget _buildMorphingTransition(
    Widget child,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? heroWidget,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
    ));

    final rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background fade
        FadeTransition(
          opacity: animation,
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        
        // Morphing content
        Transform.scale(
          scale: scaleAnimation.value,
          child: Transform.rotate(
            angle: (1 - rotationAnimation.value) * math.pi * 0.1,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

// Liquid transition with wave effects
class LiquidTransition extends PageRouteBuilder {
  final Widget child;
  final Color color;
  final Duration duration;
  final LiquidDirection direction;

  LiquidTransition({
    required this.child,
    this.color = Colors.blue,
    this.duration = const Duration(milliseconds: 800),
    this.direction = LiquidDirection.bottomToTop,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildLiquidTransition(
              child,
              animation,
              color,
              direction,
            );
          },
        );

  static Widget _buildLiquidTransition(
    Widget child,
    Animation<double> animation,
    Color color,
    LiquidDirection direction,
  ) {
    return Stack(
      children: [
        // Liquid wave effect
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return CustomPaint(
              painter: LiquidPainter(
                progress: animation.value,
                color: color,
                direction: direction,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Content with reveal animation
        ClipPath(
          clipper: LiquidClipper(
            progress: animation.value,
            direction: direction,
          ),
          child: child,
        ),
      ],
    );
  }
}

enum LiquidDirection { bottomToTop, topToBottom, leftToRight, rightToLeft }

class LiquidPainter extends CustomPainter {
  final double progress;
  final Color color;
  final LiquidDirection direction;

  LiquidPainter({
    required this.progress,
    required this.color,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    switch (direction) {
      case LiquidDirection.bottomToTop:
        _paintBottomToTop(path, size);
        break;
      case LiquidDirection.topToBottom:
        _paintTopToBottom(path, size);
        break;
      case LiquidDirection.leftToRight:
        _paintLeftToRight(path, size);
        break;
      case LiquidDirection.rightToLeft:
        _paintRightToLeft(path, size);
        break;
    }

    canvas.drawPath(path, paint);
  }

  void _paintBottomToTop(Path path, Size size) {
    final waveHeight = size.height * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height - waveHeight + 
                 waveAmplitude * math.sin((x / size.width) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
  }

  void _paintTopToBottom(Path path, Size size) {
    final waveHeight = size.height * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(0, 0);
    
    for (double x = 0; x <= size.width; x += 5) {
      final y = waveHeight + 
                 waveAmplitude * math.sin((x / size.width) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
  }

  void _paintLeftToRight(Path path, Size size) {
    final waveWidth = size.width * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(0, 0);
    
    for (double y = 0; y <= size.height; y += 5) {
      final x = waveWidth + 
                 waveAmplitude * math.sin((y / size.height) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
  }

  void _paintRightToLeft(Path path, Size size) {
    final waveWidth = size.width * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(size.width, 0);
    
    for (double y = 0; y <= size.height; y += 5) {
      final x = size.width - waveWidth + 
                 waveAmplitude * math.sin((y / size.height) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LiquidClipper extends CustomClipper<Path> {
  final double progress;
  final LiquidDirection direction;

  LiquidClipper({
    required this.progress,
    required this.direction,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    
    switch (direction) {
      case LiquidDirection.bottomToTop:
        _clipBottomToTop(path, size);
        break;
      case LiquidDirection.topToBottom:
        _clipTopToBottom(path, size);
        break;
      case LiquidDirection.leftToRight:
        _clipLeftToRight(path, size);
        break;
      case LiquidDirection.rightToLeft:
        _clipRightToLeft(path, size);
        break;
    }

    return path;
  }

  void _clipBottomToTop(Path path, Size size) {
    final waveHeight = size.height * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(0, size.height - waveHeight);
    
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height - waveHeight + 
                 waveAmplitude * math.sin((x / size.width) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
  }

  void _clipTopToBottom(Path path, Size size) {
    final waveHeight = size.height * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(0, waveHeight);
    
    for (double x = 0; x <= size.width; x += 5) {
      final y = waveHeight + 
                 waveAmplitude * math.sin((x / size.width) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
  }

  void _clipLeftToRight(Path path, Size size) {
    final waveWidth = size.width * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(waveWidth, 0);
    
    for (double y = 0; y <= size.height; y += 5) {
      final x = waveWidth + 
                 waveAmplitude * math.sin((y / size.height) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
  }

  void _clipRightToLeft(Path path, Size size) {
    final waveWidth = size.width * progress;
    final waveAmplitude = 20.0 * (1 - progress);
    
    path.moveTo(size.width - waveWidth, 0);
    
    for (double y = 0; y <= size.height; y += 5) {
      final x = size.width - waveWidth + 
                 waveAmplitude * math.sin((y / size.height) * 2 * math.pi + progress * 4 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

// Circular reveal transition
class CircularRevealTransition extends PageRouteBuilder {
  final Widget child;
  final Offset? centerOffset;
  final Duration duration;

  CircularRevealTransition({
    required this.child,
    this.centerOffset,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildCircularReveal(child, animation, centerOffset);
          },
        );

  static Widget _buildCircularReveal(
    Widget child,
    Animation<double> animation,
    Offset? centerOffset,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ClipPath(
          clipper: CircularRevealClipper(
            progress: animation.value,
            centerOffset: centerOffset,
          ),
          child: child,
        );
      },
    );
  }
}

class CircularRevealClipper extends CustomClipper<Path> {
  final double progress;
  final Offset? centerOffset;

  CircularRevealClipper({
    required this.progress,
    this.centerOffset,
  });

  @override
  Path getClip(Size size) {
    final center = centerOffset ?? Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );
    final radius = maxRadius * progress;

    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

// Utility class for easy transition usage
class TransitionHelper {
  static PageRouteBuilder slideRoute({
    required Widget child,
    SlideDirection direction = SlideDirection.rightToLeft,
    Duration duration = const Duration(milliseconds: 400),
    bool enableBlur = true,
    bool enableScale = false,
  }) {
    return AdvancedSlideTransition(
      child: child,
      direction: direction,
      duration: duration,
      enableBlur: enableBlur,
      enableScale: enableScale,
    );
  }

  static PageRouteBuilder morphRoute({
    required Widget child,
    Widget? heroWidget,
    String? heroTag,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return MorphingTransition(
      child: child,
      heroWidget: heroWidget,
      heroTag: heroTag,
      duration: duration,
    );
  }

  static PageRouteBuilder liquidRoute({
    required Widget child,
    Color color = Colors.blue,
    Duration duration = const Duration(milliseconds: 800),
    LiquidDirection direction = LiquidDirection.bottomToTop,
  }) {
    return LiquidTransition(
      child: child,
      color: color,
      duration: duration,
      direction: direction,
    );
  }

  static PageRouteBuilder circularRevealRoute({
    required Widget child,
    Offset? centerOffset,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return CircularRevealTransition(
      child: child,
      centerOffset: centerOffset,
      duration: duration,
    );
  }
}
