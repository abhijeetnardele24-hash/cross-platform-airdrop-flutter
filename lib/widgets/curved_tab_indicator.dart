import 'package:flutter/material.dart';

class CurvedTabIndicator extends Decoration {
  final Color color;
  final double curveHeight;

  const CurvedTabIndicator({required this.color, this.curveHeight = 16});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CurvedPainter(color: color, curveHeight: curveHeight);
  }
}

class _CurvedPainter extends BoxPainter {
  final Color color;
  final double curveHeight;

  _CurvedPainter({required this.color, required this.curveHeight});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()..color = color;
    final double width = configuration.size!.width;
    final double height = configuration.size!.height;

    final Path path = Path()
      ..moveTo(offset.dx, offset.dy + height)
      ..quadraticBezierTo(
        offset.dx + width / 2,
        offset.dy + height - curveHeight,
        offset.dx + width,
        offset.dy + height,
      )
      ..lineTo(offset.dx + width, offset.dy)
      ..lineTo(offset.dx, offset.dy)
      ..close();

    canvas.drawPath(path, paint);
  }
}

// This painter can be used to draw a curved background for selected tabs
class CurvedTabPainter extends CustomPainter {
  final Color color;
  final double curveHeight;
  CurvedTabPainter({required this.color, this.curveHeight = 16});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, size.height - curveHeight, size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
