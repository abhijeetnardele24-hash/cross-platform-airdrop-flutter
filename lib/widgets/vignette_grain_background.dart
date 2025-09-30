import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class VignetteGrainBackground extends StatelessWidget {
  final Widget child;
  final Alignment vignetteCenter;
  final double vignetteRadius;
  final double grainOpacity;
  final int grainDensity; // points per 10k px

  const VignetteGrainBackground({
    super.key,
    required this.child,
    this.vignetteCenter = const Alignment(0.0, -0.3),
    this.vignetteRadius = 1.2,
    this.grainOpacity = 0.035,
    this.grainDensity = 6,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider?>();
    final effectiveOpacity = themeProvider?.grainOpacity ?? grainOpacity;

    return Stack(
      children: [
        // Vignette
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: vignetteCenter,
                radius: vignetteRadius,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.04),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        // Paper grain overlay
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GrainPainter(
                opacity: effectiveOpacity,
                densityPer10k: grainDensity,
              ),
            ),
          ),
        ),
        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;
  final int densityPer10k;

  const _GrainPainter({
    required this.opacity,
    required this.densityPer10k,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final area10k = (size.width * size.height) / 10000.0;
    final points = (area10k * densityPer10k).clamp(200, 3000).toInt();
    final rnd = Random(42 + size.width.toInt() + size.height.toInt());

    final paintLight = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final paintDark = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.9)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < points; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = (rnd.nextDouble() * 0.9) + 0.4; // 0.4..1.3 px
      canvas.drawCircle(Offset(x, y), r, i.isEven ? paintLight : paintDark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
