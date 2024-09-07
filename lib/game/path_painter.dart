import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final Color pointColor;
  final Color lineColor;
  final double pointRadius;
  final double lineWidth;

  PathPainter({
    required this.points,
    this.pointColor = Colors.yellow,
    this.lineColor = Colors.yellow,
    this.pointRadius = 5.0,
    this.lineWidth = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // 绘制直线
    for (int i = 0; i < points.length-1 ; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // 绘制点
    final pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, pointRadius, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
