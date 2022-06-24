import 'package:flutter/material.dart';

/// 绘制点
class PointPainter {
  static void draw({
    required Canvas canvas,
    required Paint paint,
    required Offset offset,
    required double radius,
    Color? fill,
    Color? stroke,
    double? strokeWidthPx,
  }) {
    if (fill != null) {
      paint.color = fill;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(offset.dx, offset.dy), radius, paint);
    }
    if (stroke != null && strokeWidthPx != null && strokeWidthPx > 0.0) {
      paint.color = stroke;
      paint.strokeWidth = strokeWidthPx;
      paint.strokeJoin = StrokeJoin.bevel;
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(
        Offset(offset.dx, offset.dy),
        radius,
        paint,
      );
    }
  }
}
