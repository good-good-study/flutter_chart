import 'package:flutter/material.dart';

import '../canvas/base_canvas.dart';
import '../canvas/base_chart_canvas.dart';
import '../common/base_layout_config.dart';

/// create by xt.sun
/// at 2022.06.20
/// 画笔
abstract class BaseChart<T> extends CustomPainter {
  /// 数据源
  final List<T> data;

  /// charts配置信息
  final BaseLayoutConfig<T> layoutConfig;

  /// chart基础绘制：点、线、面,一般的绘制用这个足够了，不够的话，可以扩展。
  final BaseChartCanvas chartCanvas;

  /// 坐标系绘制
  final BaseCanvas? axisCanvas;

  /// charts内容绘制
  final BaseCanvas? contentCanvas;

  const BaseChart({
    required this.data,
    required this.layoutConfig,
    required this.chartCanvas,
    this.axisCanvas,
    this.contentCanvas,
  });

  @override
  bool shouldRepaint(covariant BaseChart oldDelegate) =>
      oldDelegate.data != data || oldDelegate.layoutConfig != layoutConfig;

  @override
  void paint(Canvas canvas, Size size) {
    _onDrawAxis(canvas, layoutConfig.bounds);
    _onDraw(canvas, layoutConfig.bounds);
    if (layoutConfig.gestureDelegate != null) {
      onDrawGesture(canvas, layoutConfig.bounds);
    }
  }

  /// 绘制坐标系
  void _onDrawAxis(Canvas canvas, Rect bounds) {
    axisCanvas?.draw(
      data: data,
      canvas: canvas,
      config: layoutConfig,
      chartCanvas: chartCanvas,
    );
  }

  /// 绘制 Charts
  void _onDraw(Canvas canvas, Rect bounds) {
    contentCanvas?.draw(
      data: data,
      canvas: canvas,
      config: layoutConfig,
      chartCanvas: chartCanvas,
    );
  }

  /// 绘制手势
  void onDrawGesture(Canvas canvas, Rect bounds) {
    // 如果子类需要绘制触摸事件，则需要重写此方法。
  }
}
