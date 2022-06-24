import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/canvas/base_chart_canvas.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/gesture_delegate.dart';
import 'package:flutter_chart/chart/common/text_element.dart';

/// 绘制Line Popup悬浮框
/// [BaseLayoutConfig.popupSpec]
class LinePopupCanvas {
  static void draw<T>({
    required Canvas canvas,
    required BaseChartCanvas chartCanvas,
    required BaseLayoutConfig<T> config,
  }) {
    /// 区分事件类型
    var popup = config.popupSpec;
    var bounds = config.bounds;

    if (config.gestureDelegate == null || popup == null) {
      return;
    }
    final position = config.gestureDelegate!.position;
    if (position?.local == null || position?.global == null) {
      return;
    }

    /// 长按事件：显示悬浮框
    switch (config.gestureDelegate!.type) {
      case GestureType.onLongPressStart:
      case GestureType.onLongPressMoveUpdate:
      case GestureType.onLongPressEnd:
      case GestureType.onTapDown:

        /// 查找最匹配的坐标点。
        var find = config.findTarget(position!.local!);
        if (find == null) return;

        /// 待绘制的富文本
        var element = TextElement(
          config.popupSpec?.textFormatter?.call(find.model) ?? const TextSpan(),
        );

        /// 文本与边框的距离
        var padding = popup.padding;

        /// popup宽度
        var rectWidth = element.measurement.horizontalSliceWidth +
            padding.left +
            padding.right;

        /// popup高度
        var rectHeight = element.measurement.verticalSliceWidth +
            padding.top +
            padding.bottom;

        /// 修正绘制区域
        double top;
        var verticalSpacing = (config.delegate?.labelVerticalSpacing ?? 0);
        var dis = find.offset.dy - rectHeight - verticalSpacing;

        // popup显示在bubble的上方
        if (dis > bounds.top) {
          top = dis;
        } else {
          // popup显示在bubble的下方。
          top = find.offset.dy + verticalSpacing;
        }
        var rectangle = Rectangle(
          max(
            bounds.left,
            min(
              bounds.right - rectWidth,
              position.local!.dx - rectWidth / 2,
            ),
          ),
          top,
          rectWidth,
          rectHeight,
        );

        /// 仅绘制可视范围内的popup
        if (rectangle.left > find.offset.dx ||
            rectangle.right < find.offset.dx) {
          return;
        }

        /// 绘制指示线
        /// 这里减去横轴的辅助线高度，是为了防止指示线压线。
        var strokeWidth = config.delegate?.hintLineStyle?.strokeWidth ?? 0;
        var points = [
          Offset(find.offset.dx, config.bounds.top + strokeWidth * 2),
          Offset(find.offset.dx, config.bounds.bottom - strokeWidth),
        ];
        chartCanvas.drawLine(
          canvas: canvas,
          points: points,
          color: config.popupSpec?.lineStyle?.color,
          strokeWidthPx: config.popupSpec?.lineStyle?.strokeWidth,
          dashPattern: config.popupSpec?.lineStyle?.dashPattern,
        );

        /// 绘制气泡
        if (popup.bubbleShouldDraw?.call(find.model) ?? true) {
          chartCanvas.drawPoint(
            canvas: canvas,
            offset: find.offset,
            radius: popup.bubbleSpec?.radius ?? 4,
            fill: popup.bubbleSpec?.fill,
            stroke: popup.bubbleSpec?.stroke,
            strokeWidthPx: popup.bubbleSpec?.strokeWidthPx,
          );
        }

        /// 此点位，不需要绘制悬浮框,默认可显示。
        if (false == popup.popupShouldDraw?.call(find.model)) return;

        /// 绘制Popup
        chartCanvas.drawRRect(
          canvas: canvas,
          radius: popup.radius,
          fill: popup.fill,
          stroke: popup.stroke,
          strokeWidthPx: popup.strokeWidthPx,
          roundTopLeft: popup.roundTopLeft,
          roundTopRight: popup.roundTopRight,
          roundBottomLeft: popup.roundBottomLeft,
          roundBottomRight: popup.roundBottomRight,
          bounds: rectangle,
        );

        /// 在popup区域内绘制富文本
        chartCanvas.drawText(
          canvas: canvas,
          offset: Offset(
            rectangle.left.toDouble() + padding.left,
            rectangle.top.toDouble() + padding.top,
          ),
          textElement: element,
        );
        break;

      default:
        break;
    }
  }
}
