import 'dart:math';

import 'package:flutter/material.dart';

/// 绘制线段：折线、曲线
class LinePainter {
  /// 绘制
  static void draw({
    required Canvas canvas,
    required Paint paint,
    required List<Offset> points,
    Rectangle<num>? clipBounds,
    bool? roundEndCaps,
    Color? color,
    double? strokeWidthPx,
    List<int>? dashPattern,
    Shader? shader,
    bool isCurved = false,
  }) {
    if (points.isEmpty) {
      return;
    }
    // 将剪辑边界应用为剪辑区域
    if (clipBounds != null) {
      canvas
        ..save()
        ..clipRect(
          Rect.fromLTWH(
            clipBounds.left.toDouble(),
            clipBounds.top.toDouble(),
            clipBounds.width.toDouble(),
            clipBounds.height.toDouble(),
          ),
        );
    }
    paint.shader = shader;

    /// 如果只有一个坐标，则绘制一个圆点
    if (points.length == 1) {
      final point = points.first;
      paint.style = PaintingStyle.fill;
      if (strokeWidthPx != null) {
        paint.strokeWidth = strokeWidthPx;
      }
      paint.strokeJoin = StrokeJoin.round;
      if (color != null) {
        paint.color = color;
      }
      canvas.drawCircle(Offset(point.dx, point.dy), strokeWidthPx ?? 0, paint);
    } else {
      if (strokeWidthPx != null) {
        paint.strokeWidth = strokeWidthPx;
      }
      paint.strokeJoin = StrokeJoin.round;
      paint.style = PaintingStyle.stroke;

      if (color != null) {
        paint.color = color;
      }

      if (dashPattern?.isEmpty ?? true) {
        if (roundEndCaps == true) {
          paint.strokeCap = StrokeCap.round;
        }
        _drawSolidLine(canvas, paint, points, isCurved: isCurved);
      } else {
        _drawDashedLine(canvas, paint, points, dashPattern!);
      }
    }

    if (clipBounds != null) {
      canvas.restore();
    }
  }

  /// 绘制实线
  static void _drawSolidLine(
    Canvas canvas,
    Paint paint,
    List<Offset> points, {
    bool isCurved = false,
  }) {
    // final path = Path()..moveTo(points.first.dx, points.first.dy);
    // for (var point in points) {
    //   path.lineTo(point.dx, point.dy);
    // }
    // canvas.drawPath(path, paint);

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length; i++) {
      double x = points[i].dx;
      double y = points[i].dy;
      if (i == 0) {
        path.moveTo(x, y);
      } else if (isCurved) {
        //曲线
        double x0 = points[i - 1].dx;
        double y0 = points[i - 1].dy;
        path.cubicTo((x0 + x) / 2, y0, (x0 + x) / 2, y, x, y);
      } else {
        //折线
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  /// 绘制虚线
  static void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    List<Offset> points,
    List<int> dashPattern,
  ) {
    final localDashPattern = List.from(dashPattern);

    // If an odd number of parts are defined, repeat the pattern to get an even
    // number.
    if (dashPattern.length % 2 == 1) {
      localDashPattern.addAll(dashPattern);
    }

    // Stores the previous point in the series.
    var previousSeriesPoint = points.first;

    var remainder = 0;
    var solid = true;
    var dashPatternIndex = 0;

    // Gets the next segment in the dash pattern, looping back to the
    // beginning once the end has been reached.
    getNextDashPatternSegment() {
      final dashSegment = localDashPattern[dashPatternIndex];
      dashPatternIndex = (dashPatternIndex + 1) % localDashPattern.length;
      return dashSegment;
    }

    // Array of points that is used to draw a connecting path when only a
    // partial dash pattern segment can be drawn in the remaining length of a
    // line segment (between two defined points in the shape).
    List<Offset>? remainderPoints;

    // Draw the path through all the rest of the points in the series.
    for (var pointIndex = 1; pointIndex < points.length; pointIndex++) {
      // Stores the current point in the series.
      final seriesPoint = points[pointIndex];

      if (previousSeriesPoint == seriesPoint) {
        // Bypass dash pattern handling if the points are the same.
      } else {
        // Stores the previous point along the current series line segment where
        // we rendered a dash (or left a gap).
        var previousPoint = previousSeriesPoint;

        var d = _getOffsetDistance(previousSeriesPoint, seriesPoint);

        while (d > 0) {
          var dashSegment =
              remainder > 0 ? remainder : getNextDashPatternSegment();
          remainder = 0;

          // Create a unit vector in the direction from previous to next point.
          final v = seriesPoint - previousPoint;
          final u = Offset(v.dx / v.distance, v.dy / v.distance);

          // If the remaining distance is less than the length of the dash
          // pattern segment, then cut off the pattern segment for this portion
          // of the overall line.
          final distance = d < dashSegment ? d : dashSegment.toDouble();

          // Compute a vector representing the length of dash pattern segment to
          // be drawn.
          final nextPoint = previousPoint + (u * distance);

          // If we are in a solid portion of the dash pattern, draw a line.
          // Else, move on.
          if (solid) {
            if (remainderPoints != null) {
              // If we had a partial un-drawn dash from the previous point along
              // the line, draw a path that includes it and the end of the dash
              // pattern segment in the current line segment.
              remainderPoints.add(Offset(nextPoint.dx, nextPoint.dy));

              final path = Path()
                ..moveTo(remainderPoints.first.dx, remainderPoints.first.dy);

              for (var p in remainderPoints) {
                path.lineTo(p.dx, p.dy);
              }

              canvas.drawPath(path, paint);

              remainderPoints = null;
            } else {
              if (d < dashSegment && pointIndex < points.length - 1) {
                // If the remaining distance d is too small to fit this dash,
                // and we have more points in the line, save off a series of
                // remainder points so that we can draw a path segment moving in
                // the direction of the next point.
                //
                // Note that we don't need to save anything off for the "blank"
                // portions of the pattern because we still take the remaining
                // distance into account before starting the next dash in the
                // next line segment.
                remainderPoints = [
                  Offset(previousPoint.dx, previousPoint.dy),
                  Offset(nextPoint.dx, nextPoint.dy)
                ];
              } else {
                // Otherwise, draw a simple line segment for this dash.
                canvas.drawLine(previousPoint, nextPoint, paint);
              }
            }
          }

          solid = !solid;
          previousPoint = nextPoint;
          d = d - dashSegment;
        }

        // Save off the remaining distance so that we can continue the dash (or
        // gap) into the next line segment.
        remainder = -d.round();

        // If we have a remaining un-drawn distance for the current dash (or
        // gap), revert the last change to "solid" so that we will continue
        // either drawing a dash or leaving a gap.
        if (remainder > 0) {
          solid = !solid;
        }
      }

      previousSeriesPoint = seriesPoint;
    }
  }

  /// Computes the distance between two [Offset]s, as if they were [Point]s.
  static num _getOffsetDistance(Offset o1, Offset o2) {
    final p1 = Point(o1.dx, o1.dy);
    final p2 = Point(o2.dx, o2.dy);
    return p1.distanceTo(p2);
  }
}
