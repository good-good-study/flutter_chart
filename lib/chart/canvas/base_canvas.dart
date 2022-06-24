import 'dart:ui';

import '../common/base_layout_config.dart';
import 'base_chart_canvas.dart';

/// Base 绘制内容
abstract class BaseCanvas<T> {
  const BaseCanvas();

  void draw({
    required List<T> data,
    required Canvas canvas,
    required BaseChartCanvas chartCanvas,
    required BaseLayoutConfig<T> config,
  });
}
