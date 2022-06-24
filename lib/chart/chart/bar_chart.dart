import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/canvas/axis_canvas_impl.dart';
import 'package:flutter_chart/chart/canvas/chart_canvas_impl.dart';

import 'bar_popup_canvas.dart';
import 'base_chart.dart';

/// 绘制 bar 段落
class BarChart<T> extends BaseChart<T> {
  const BarChart({
    required super.data,
    required super.layoutConfig,
    super.chartCanvas = const ChartCanvasImpl(),
    super.axisCanvas = const AxisCanvasImpl(),
    super.contentCanvas,
  });

  /// 绘制悬浮框
  @override
  void onDrawGesture(Canvas canvas, Rect bounds) {
    BarPopupCanvas.draw<T>(
      canvas: canvas,
      config: layoutConfig,
      chartCanvas: chartCanvas,
    );
  }
}
