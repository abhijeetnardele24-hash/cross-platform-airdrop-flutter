import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/ios_theme.dart';

class PremiumLogo extends StatefulWidget {
  final double size;
  final bool animate;
  
  const PremiumLogo({
    super.key,
    this.size = 140,
    this.animate = true,
  });

  @override
  State<PremiumLogo> createState() => _PremiumLogoState();
}

class _PremiumLogoState extends State<PremiumLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.animate) {
      _rotationController = AnimationController(
        duration: const Duration(seconds: 20),
        vsync: this,
      )..repeat();

      _pulseController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      )..repeat(reverse: true);

      _rotationAnimation = Tween<double>(
        begin: 0,
        end: 2 * math.pi,
      ).animate(_rotationController);

      _pulseAnimation = Tween<double>(
        begin: 0.95,
        end: 1.05,
      ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _rotationController.dispose();
      _pulseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return _buildStaticLogo();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: _buildAnimatedLogo(),
        );
      },
    );
  }

  Widget _buildStaticLogo() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IOSTheme.systemBlue,
            IOSTheme.systemBlue.withOpacity(0.8),
            IOSTheme.systemPurple.withOpacity(0.6),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: IOSTheme.systemBlue.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _buildLogoContent(),
    );
  }

  Widget _buildAnimatedLogo() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IOSTheme.systemBlue,
            IOSTheme.systemBlue.withOpacity(0.8),
            IOSTheme.systemPurple.withOpacity(0.6),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: IOSTheme.systemBlue.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated outer ring
          Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: widget.size * 0.85,
              height: widget.size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
          ),
          
          // Counter-rotating inner ring
          Transform.rotate(
            angle: -_rotationAnimation.value * 0.5,
            child: Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
          
          // Logo content
          _buildLogoContent(),
          
          // Animated orbital dots
          ...List.generate(6, (index) {
            final angle = (index * math.pi * 2) / 6;
            return Transform.rotate(
              angle: angle + (_rotationAnimation.value * 2),
              child: Transform.translate(
                offset: Offset(widget.size * 0.35, 0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogoContent() {
    return Container(
      width: widget.size * 0.6,
      height: widget.size * 0.6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main share icon
          Icon(
            CupertinoIcons.share,
            size: widget.size * 0.3,
            color: Colors.white,
          ),
          
          // Subtle inner glow
          Container(
            width: widget.size * 0.4,
            height: widget.size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Alternative logo designs
class MinimalistLogo extends StatelessWidget {
  final double size;
  
  const MinimalistLogo({
    super.key,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: IOSTheme.systemBlue,
        boxShadow: [
          BoxShadow(
            color: IOSTheme.systemBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        CupertinoIcons.arrow_up_arrow_down_circle,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}

class GeometricLogo extends StatefulWidget {
  final double size;
  
  const GeometricLogo({
    super.key,
    this.size = 140,
  });

  @override
  State<GeometricLogo> createState() => _GeometricLogoState();
}

class _GeometricLogoState extends State<GeometricLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: GeometricLogoPainter(_animation.value),
        );
      },
    );
  }
}

class GeometricLogoPainter extends CustomPainter {
  final double animationValue;
  
  GeometricLogoPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Background circle
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [IOSTheme.systemBlue, IOSTheme.systemPurple],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Animated geometric shapes
    final shapePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Draw rotating triangles
    for (int i = 0; i < 3; i++) {
      final angle = (i * math.pi * 2 / 3) + (animationValue * math.pi * 2);
      final triangleRadius = radius * 0.4;
      
      final path = Path();
      for (int j = 0; j < 3; j++) {
        final vertexAngle = angle + (j * math.pi * 2 / 3);
        final x = center.dx + triangleRadius * math.cos(vertexAngle);
        final y = center.dy + triangleRadius * math.sin(vertexAngle);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, shapePaint);
    }
    
    // Center icon
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.2, iconPaint);
  }

  @override
  bool shouldRepaint(GeometricLogoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
