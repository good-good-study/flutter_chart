import 'dart:math';
import 'dart:ui';

import 'package:flutter_chart/chart/canvas/base_canvas.dart';
import 'package:flutter_chart/chart/canvas/base_chart_canvas.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/impl/line/fixed_line_layout_impl.dart';
import 'package:flutter_chart/chart/model/chart_data_model.dart';

/// 绘制曲线
class FixedLineCanvasImpl extends BaseCanvas<ChartDataModel> {
  @override
  void draw({
    required List<ChartDataModel> data,
    required Canvas canvas,
    required BaseChartCanvas chartCanvas,
    required BaseLayoutConfig<ChartDataModel> config,
  }) {
    config as FixedLayoutConfig;

    if (config.delegate == null) return;

    ///
    var delegate = config.delegate!;
    var bounds = config.bounds;
    var gestureDelegate = config.gestureDelegate;

    var points = <Offset>[];

    var itemWidth = delegate.domainPointSpacing;
    var lineHeight = config.delegate?.lineStyle?.strokeWidth ?? 0;
    var maxValue = config.maxValue;
    var maxHeight = bounds.height;

    /// 1s时长对应的宽度，全程24小时，两个点之间的跨度为1小时。
    var dw = itemWidth / 3600; // 3600s为1小时

    for (var index = 0; index < data.length; index++) {
      var model = data[index];
      var seconds = max(0, model.xAxis - config.startTime);
      var offset = Offset(
        bounds.left + dw * seconds,
        bounds.bottom - (config.yAxisValue(model) / maxValue) * maxHeight,
      );
      points.add(offset);
    }

    /// 绘制曲线
    /// 这里加上[lineHeight]，是为了让曲线点能在top和bottom上完全显示出来。
    if (delegate.lineStyle?.isCurved ?? true) {
      chartCanvas.drawCurvedLine(
        canvas: canvas,
        points: points,
        color: delegate.lineStyle?.color,
        translate: gestureDelegate?.offset,
        strokeWidthPx: delegate.lineStyle?.strokeWidth,
        dashPattern: delegate.lineStyle?.dashPattern,
        roundEndCaps: true,
        clipBounds: Rectangle(
          bounds.left - (gestureDelegate?.offset.dx ?? 0),
          bounds.top - lineHeight,
          bounds.width,
          bounds.height + lineHeight * 2,
        ),
      );
    } else {
      chartCanvas.drawLine(
        canvas: canvas,
        points: points,
        color: delegate.lineStyle?.color,
        translate: gestureDelegate?.offset,
        strokeWidthPx: delegate.lineStyle?.strokeWidth,
        dashPattern: delegate.lineStyle?.dashPattern,
        roundEndCaps: true,
        clipBounds: Rectangle(
          bounds.left - (gestureDelegate?.offset.dx ?? 0),
          bounds.top - lineHeight,
          bounds.width,
          bounds.height + lineHeight * 2,
        ),
      );
    }
  }
}
