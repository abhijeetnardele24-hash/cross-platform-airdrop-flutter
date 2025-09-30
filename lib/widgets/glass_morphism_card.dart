import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GlassMorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final bool useNoiseTexture;

  const GlassMorphismCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.padding,
    this.borderRadius,
    this.border,
    this.useNoiseTexture = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Dynamic blur and opacity based on theme
    final effectiveBlur =
        isDark ? blur * 1.2 : blur; // Slightly more blur in dark mode
    final effectiveOpacity = isDark ? opacity * 0.8 : opacity;
    final backgroundColor = isDark
        ? Colors.black.withValues(alpha: effectiveOpacity)
        : Colors.white.withValues(alpha: effectiveOpacity);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.2);

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: border ??
            Border.all(
              color: borderColor,
              width: 1.5,
            ),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.black).withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          // Subtle inner shadow for depth
          BoxShadow(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    // Add noise texture for premium iOS feel
    if (useNoiseTexture) {
      cardContent = Stack(
        children: [
          // Noise overlay
          Positioned.fill(
            child: CustomPaint(
              painter: NoisePainter(isDark: isDark),
              size: Size.infinite,
            ),
          ),
          cardContent,
        ],
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: cardContent,
      ),
    );
  }
}

// Custom painter for subtle noise texture
class NoisePainter extends CustomPainter {
  final bool isDark;

  const NoisePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    final random = Random();
    const noiseSize = 2.0;
    final cols = (size.width / noiseSize).ceil();
    final rows = (size.height / noiseSize).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = col * noiseSize;
        final y = row * noiseSize;
        final opacity = random.nextDouble() * 0.5; // Subtle variation
        paint.color = (isDark ? Colors.white : Colors.black)
            .withValues(alpha: opacity * 0.02);
        canvas.drawRect(Rect.fromLTWH(x, y, noiseSize, noiseSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
