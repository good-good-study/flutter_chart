import 'dart:math';
import 'dart:ui';

import 'package:flutter_chart/chart/canvas/base_canvas.dart';
import 'package:flutter_chart/chart/canvas/base_chart_canvas.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/model/chart_data_bar.dart';

/// 绘制 bar
class BarCanvasImpl extends BaseCanvas<ChartDataBar> {
  @override
  void draw({
    required List<ChartDataBar> data,
    required Canvas canvas,
    required BaseChartCanvas chartCanvas,
    required BaseLayoutConfig<ChartDataBar> config,
  }) {
    if (config.delegate == null) return;

    ///
    var delegate = config.delegate!;
    var bounds = config.bounds;
    var gestureDelegate = config.gestureDelegate;

    /// x轴方向，两点之间的履历
    var itemWidth = delegate.domainPointSpacing;

    /// y轴方向每段高度。
    var itemHeight = bounds.height / delegate.hintLineNum;

    /// 1s时长对应的宽度，全程24小时，两个点之间的跨度为1小时。
    var dw = itemWidth / 3600; // 3600s为1小时

    /// bar高度
    var barHeight = delegate.barStyle?.height ?? 0;

    /// bubble 距离bar 右侧的距离
    var bubblePadding = 5;

    for (var index = 0; index < data.length; index++) {
      var model = data[index];

      var date = model.time;
      var hour = date.hour;
      var minute = date.minute;
      var begin = date.second + minute * 60 + hour * 3600;

      var offset = Offset(
        // bounds.left + itemWidth * index,
        bounds.left + begin * dw,
        bounds.bottom - model.index * itemHeight - barHeight,
      );

      /// 绘制Rect
      chartCanvas.drawRect(
        canvas: canvas,
        fill: model.color,
        stroke: delegate.barStyle?.stroke,
        strokeWidthPx: delegate.barStyle?.strokeWidth,
        bounds: Rectangle(offset.dx, offset.dy, dw * model.duration, barHeight),
        translate: gestureDelegate?.offset,
        clipBounds: Rectangle(
          bounds.left - (gestureDelegate?.offset.dx ?? 0),
          bounds.top,
          bounds.width,
          bounds.height,
        ),
      );

      /// 绘制气泡
      if (model.hasBubble) {
        var style = config.popupSpec?.bubbleSpec;
        if (style == null) return;
        // 气泡与bar垂直对齐，并且距离bar右侧的距离5px
        var end = Offset(
            dw * model.duration - bubblePadding, barHeight.toDouble() / 2);
        var pointer = offset + end;
        chartCanvas.drawPoint(
          canvas: canvas,
          offset: pointer,
          radius: style.radius,
          fill: style.fill,
          strokeWidthPx: style.strokeWidthPx,
          stroke: style.stroke,
          translate: gestureDelegate?.offset,
          clipBounds: Rectangle(
            bounds.left - (gestureDelegate?.offset.dx ?? 0),
            bounds.top,
            bounds.width,
            bounds.height,
          ),
        );
      }
    }
  }
}
