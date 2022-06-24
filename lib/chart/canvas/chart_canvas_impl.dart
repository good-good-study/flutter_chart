import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/common/base_text_element.dart';
import 'package:flutter_chart/chart/common/text_element.dart';

import 'base_chart_canvas.dart';
import 'line_painter.dart';
import 'point_painter.dart';

/// 实现了基础的 [BaseChartCanvas]绘制能力。
class ChartCanvasImpl extends BaseChartCanvas {
  const ChartCanvasImpl() : super();

  /// 默认画笔
  static final _paint = Paint();

  /// 绘制点
  @override
  void drawPoint({
    required Canvas canvas,
    required Offset offset,
    required double radius,
    Color? fill,
    Color? stroke,
    double? strokeWidthPx,
    BlendMode? blendMode,
    Rectangle<num>? clipBounds,
    Offset? translate,
  }) {
    if (translate != null) {
      canvas
        ..save()
        ..translate(translate.dx, 0);
    }
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
    PointPainter.draw(
      canvas: canvas,
      paint: _paint,
      offset: offset,
      radius: radius,
      fill: fill,
      stroke: stroke,
      strokeWidthPx: strokeWidthPx,
    );
    if (clipBounds != null) {
      canvas.restore();
    }
    if (translate != null) {
      canvas.restore();
    }
  }

  /// 绘制折线、虚线
  @override
  void drawLine({
    required Canvas canvas,
    required List<Offset> points,
    Rectangle<num>? clipBounds,
    Offset? translate,
    Color? color,
    bool? roundEndCaps,
    double? strokeWidthPx,
    List<int>? dashPattern,
  }) {
    if (translate != null) {
      canvas.save();
      canvas.translate(translate.dx, 0);
    }
    LinePainter.draw(
      canvas: canvas,
      paint: _paint,
      points: points,
      color: color,
      clipBounds: clipBounds,
      roundEndCaps: roundEndCaps,
      strokeWidthPx: strokeWidthPx,
      dashPattern: dashPattern,
    );
    if (translate != null) {
      canvas.restore();
    }
  }

  /// 绘制曲线
  @override
  void drawCurvedLine({
    required Canvas canvas,
    required List<Offset> points,
    Rectangle<num>? clipBounds,
    Offset? translate,
    Color? color,
    bool? roundEndCaps,
    double? strokeWidthPx,
    List<int>? dashPattern,
  }) {
    if (translate != null) {
      canvas.save();
      canvas.translate(translate.dx, 0);
    }
    LinePainter.draw(
      canvas: canvas,
      paint: _paint,
      points: points,
      color: color,
      clipBounds: clipBounds,
      roundEndCaps: roundEndCaps,
      strokeWidthPx: strokeWidthPx,
      dashPattern: dashPattern,
      isCurved: true,
    );
    if (translate != null) {
      canvas.restore();
    }
  }

  /// 绘制圆角矩形
  @override
  void drawRRect({
    required Canvas canvas,
    required Rectangle<num> bounds,
    Rectangle<num>? clipBounds,
    Offset? translate,
    Color? fill,
    Color? stroke,
    double? strokeWidthPx,
    num? radius,
    bool roundTopLeft = false,
    bool roundTopRight = false,
    bool roundBottomLeft = false,
    bool roundBottomRight = false,
  }) {
    if (translate != null) {
      canvas
        ..save()
        ..translate(translate.dx, 0);
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

    final bool drawStroke =
        (strokeWidthPx != null && strokeWidthPx > 0.0 && stroke != null);

    final strokeWidthOffset = (drawStroke ? strokeWidthPx : 0);

    // Factor out stroke width, if a stroke is enabled.
    final fillRectBounds = Rectangle<num>(
        bounds.left + strokeWidthOffset / 2,
        bounds.top + strokeWidthOffset / 2,
        bounds.width - strokeWidthOffset,
        bounds.height - strokeWidthOffset);

    if (fill != null) {
      _paint.color = fill;
    }
    _paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      _getRRect(
        fillRectBounds,
        radius: radius?.toDouble() ?? 0.0,
        roundTopLeft: roundTopLeft,
        roundTopRight: roundTopRight,
        roundBottomLeft: roundBottomLeft,
        roundBottomRight: roundBottomRight,
      ),
      _paint,
    );

    if (drawStroke) {
      _paint.color = stroke;
      _paint.shader = _createShader(bounds, stroke);
      _paint.strokeJoin = StrokeJoin.round;
      _paint.strokeWidth = strokeWidthPx;
      _paint.style = PaintingStyle.stroke;

      canvas.drawRRect(
          _getRRect(
            fillRectBounds,
            radius: radius?.toDouble() ?? 0.0,
            roundTopLeft: roundTopLeft,
            roundTopRight: roundTopRight,
            roundBottomLeft: roundBottomLeft,
            roundBottomRight: roundBottomRight,
          ),
          _paint);
    }

    // Reset the shader.
    _paint.shader = null;

    if (clipBounds != null) {
      canvas.restore();
    }
    if (translate != null) {
      canvas.restore();
    }
  }

  /// 绘制矩形
  @override
  void drawRect({
    required Canvas canvas,
    required Rectangle<num> bounds,
    Rectangle<num>? clipBounds,
    Offset? translate,
    Color? fill,
    Color? stroke,
    double? strokeWidthPx,
  }) {
    if (translate != null) {
      canvas
        ..save()
        ..translate(translate.dx, 0);
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
    final bool drawStroke =
        (strokeWidthPx != null && strokeWidthPx > 0.0 && stroke != null);

    final strokeWidthOffset = (drawStroke ? strokeWidthPx : 0);

    // Factor out stroke width, if a stroke is enabled.
    final fillRectBounds = Rectangle<num>(
        bounds.left + strokeWidthOffset / 2,
        bounds.top + strokeWidthOffset / 2,
        bounds.width - strokeWidthOffset,
        bounds.height - strokeWidthOffset);

    if (fill != null) {
      _paint.color = fill;
    }
    _paint.style = PaintingStyle.fill;
    canvas.drawRect(_getRect(fillRectBounds), _paint);

    if (drawStroke) {
      _paint.color = stroke;
      // Set shader to null if no draw area bounds so it can use the color
      // instead.
      // _paint.shader = drawAreaBounds != null
      //     ? _createHintGradient(drawAreaBounds.left.toDouble(),
      //     drawAreaBounds.top.toDouble(), stroke)
      //     : null;
      _paint.strokeJoin = StrokeJoin.round;
      _paint.strokeWidth = strokeWidthPx;
      _paint.style = PaintingStyle.stroke;

      // canvas.drawRect(_getRect(bounds), _paint);
    }

    // Reset the shader.
    _paint.shader = null;

    if (clipBounds != null) {
      canvas.restore();
    }

    if (translate != null) {
      canvas.restore();
    }
  }

  /// 绘制文本
  @override
  void drawText({
    required Canvas canvas,
    required BaseTextElement textElement,
    required Offset offset,
    double rotation = 0.0,
    Offset? translate,
  }) {
    assert(textElement is TextElement);
    final element = textElement as TextElement;
    final textDirection = textElement.textDirection;
    final measurement = textElement.measurement;

    if (translate != null) {
      canvas.save();
      canvas.translate(translate.dx, 0);
    }

    var offsetX = offset.dx;
    var offsetY = offset.dy;

    if (rotation != 0) {
      if (textDirection == TextDirection.rtl) {
        offsetY += measurement.horizontalSliceWidth.toInt();
      }
      offsetX -= element.verticalFontShift;

      canvas.save();
      canvas.translate(offsetX.toDouble(), offsetY.toDouble());
      canvas.rotate(rotation);
      element.textPainter!.paint(canvas, const Offset(0.0, 0.0));
      canvas.restore();
    } else {
      if (textDirection == TextDirection.rtl) {
        offsetX -= measurement.horizontalSliceWidth.toInt();
      }
      // 居中显示
      if (textDirection == TextDirection.center) {
        offsetX -= (measurement.horizontalSliceWidth / 2).ceil();
      }

      offsetY -= element.verticalFontShift;

      element.textPainter!.paint(
        canvas,
        Offset(offsetX.toDouble(), offsetY.toDouble()),
      );
    }
    if (translate != null) {
      canvas.restore();
    }
  }
}

/// Convert dart:math [Rectangle] to Flutter [Rect].
Rect _getRect(Rectangle<num> rectangle) {
  return Rect.fromLTWH(
    rectangle.left.toDouble(),
    rectangle.top.toDouble(),
    rectangle.width.toDouble(),
    rectangle.height.toDouble(),
  );
}

/// Convert dart:math [Rectangle] and to Flutter [RRect].
RRect _getRRect(
  Rectangle<num> rectangle, {
  double radius = 0,
  bool roundTopLeft = false,
  bool roundTopRight = false,
  bool roundBottomLeft = false,
  bool roundBottomRight = false,
}) {
  final cornerRadius = radius == 0 ? Radius.zero : Radius.circular(radius);

  return RRect.fromLTRBAndCorners(
      rectangle.left.toDouble(),
      rectangle.top.toDouble(),
      rectangle.right.toDouble(),
      rectangle.bottom.toDouble(),
      topLeft: roundTopLeft ? cornerRadius : Radius.zero,
      topRight: roundTopRight ? cornerRadius : Radius.zero,
      bottomLeft: roundBottomLeft ? cornerRadius : Radius.zero,
      bottomRight: roundBottomRight ? cornerRadius : Radius.zero);
}

Shader _createShader(Rectangle<num> bounds, Color color) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    tileMode: TileMode.clamp,
    colors: [color, color.withOpacity(0.5)],
  ).createShader(
    Rect.fromLTRB(
      bounds.left.toDouble(),
      bounds.top.toDouble(),
      bounds.left.toDouble(),
      bounds.bottom.toDouble(),
    ),
  );
}
