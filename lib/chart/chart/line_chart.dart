import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/canvas/axis_canvas_impl.dart';
import 'package:flutter_chart/chart/canvas/chart_canvas_impl.dart';

import 'base_chart.dart';
import 'line_popup_canvas.dart';

/// 绘制 折线、曲线。
class LineChart<T> extends BaseChart<T> {
  const LineChart({
    required super.data,
    required super.layoutConfig,
    super.chartCanvas = const ChartCanvasImpl(),
    super.axisCanvas = const AxisCanvasImpl(),
    super.contentCanvas,
  });

  /// 绘制悬浮框
  @override
  void onDrawGesture(Canvas canvas, Rect bounds) {
    LinePopupCanvas.draw<T>(
      canvas: canvas,
      config: layoutConfig,
      chartCanvas: chartCanvas,
    );
  }
}
