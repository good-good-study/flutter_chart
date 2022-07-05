import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/canvas/base_canvas.dart';
import 'package:flutter_chart/chart/canvas/base_chart_canvas.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/base_text_element.dart' as common;
import 'package:flutter_chart/chart/common/text_element.dart';

/// 绘制坐标系；域轴、辅助线、坐标值，
class AxisCanvasImpl<T> extends BaseCanvas<T> {
  const AxisCanvasImpl() : super();

  @override
  void draw({
    required List<T> data,
    required Canvas canvas,
    required BaseLayoutConfig<T> config,
    required BaseChartCanvas chartCanvas,
  }) {
    /// 绘制域轴
    _AxisCanvas.draw(
      data: data,
      canvas: canvas,
      config: config,
      chartCanvas: chartCanvas,
    );

    /// 绘制坐标值
    _AxisValueCanvas.draw<T>(
      data: data,
      canvas: canvas,
      config: config,
      chartCanvas: chartCanvas,
    );
  }
}

/// 绘制坐标轴、辅助线
class _AxisCanvas {
  static void draw<T>({
    required List<T> data,
    required Canvas canvas,
    required BaseChartCanvas chartCanvas,
    required BaseLayoutConfig<T> config,
  }) {
    if (config.delegate == null) return;

    ///
    var delegate = config.delegate!;
    var bounds = config.bounds;

    /// 绘制x轴
    if (delegate.showXAxisLine) {
      chartCanvas.drawLine(
        canvas: canvas,
        color: delegate.axisLineStyle?.color,
        strokeWidthPx: delegate.axisLineStyle?.strokeWidth,
        dashPattern: delegate.axisLineStyle?.dashPattern,
        points: [
          Offset(bounds.left, bounds.bottom),
          Offset(bounds.right, bounds.bottom),
        ],
      );
    }

    /// 绘制y轴
    if (delegate.showYAxisLine) {
      chartCanvas.drawLine(
        canvas: canvas,
        color: delegate.axisLineStyle?.color,
        strokeWidthPx: delegate.axisLineStyle?.strokeWidth,
        dashPattern: delegate.axisLineStyle?.dashPattern,
        points: [
          Offset(bounds.left, bounds.bottom),
          Offset(bounds.left, bounds.top),
        ],
      );
    }

    /// 绘制最右侧的y轴
    if (delegate.showEndYAxisLine) {
      chartCanvas.drawLine(
        canvas: canvas,
        color: delegate.axisLineStyle?.color,
        strokeWidthPx: delegate.axisLineStyle?.strokeWidth,
        dashPattern: delegate.axisLineStyle?.dashPattern,
        points: [
          Offset(bounds.right, bounds.bottom),
          Offset(bounds.right, bounds.top),
        ],
      );
    }

    /// 绘制横轴辅助线
    if (delegate.showHorizontalHintAxisLine) {
      var height = bounds.height;
      var lineStyle = delegate.hintLineStyle;
      var lineNum = delegate.hintLineNum;
      var itemHeight = height ~/ lineNum;

      for (var index = 0; index < lineNum + 1; index++) {
        chartCanvas.drawLine(
          canvas: canvas,
          color: lineStyle?.color,
          strokeWidthPx: lineStyle?.strokeWidth,
          dashPattern: lineStyle?.dashPattern,
          points: [
            Offset(bounds.left, bounds.bottom - itemHeight * index),
            Offset(bounds.right, bounds.bottom - itemHeight * index),
          ],
        );
      }
    }

    // /// 绘制纵轴方向的辅助线
    // if (delegate.showVerticalHintAxisLine) {
    //   var itemWidth = delegate.domainPointSpacing;
    //   for (var item = bounds.left; item <= bounds.width; item += itemWidth) {
    //     Offset offset = Offset(
    //       bounds.left + item,
    //       bounds.bottom + delegate.labelVerticalSpacing,
    //     );
    //     chartCanvas.drawLine(
    //       canvas: canvas,
    //       points: [
    //         Offset(offset.dx, bounds.bottom),
    //         Offset(offset.dx, bounds.top),
    //       ],
    //       dashPattern: [4],
    //     );
    //   }
    // }
  }
}

/// 绘制坐标值
class _AxisValueCanvas {
  static void draw<T>({
    required List<T> data,
    required Canvas canvas,
    required BaseChartCanvas chartCanvas,
    required BaseLayoutConfig<T> config,
  }) {
    if (config.delegate == null) return;

    ///
    var delegate = config.delegate!;
    var bounds = config.bounds;
    var gestureDelegate = config.gestureDelegate;
    var labelHorizontalSpacing = delegate.labelHorizontalSpacing;

    /// 绘制横坐标
    /// 当有拖动偏移量时，需要将x轴坐标值区域裁剪。
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(
        bounds.left / 2,
        bounds.bottom,
        bounds.right - config.padding.right / 2,
        bounds.bottom + delegate.labelVerticalSpacing,
      ));

    var itemSpacing = delegate.domainPointSpacing.toInt();

    for (var index = 0; index < config.xAxisCount; index++) {
      var element = TextElement(
        TextSpan(
          text: config.xAxisValue(index) ??
              config.delegate?.xAxisFormatter?.call(index),
          style: delegate.labelStyle?.style,
        ),
        textAlign: TextAlign.center,
      );
      // 当前点
      Offset offset = Offset(
        bounds.left - labelHorizontalSpacing + itemSpacing * index,
        bounds.bottom + delegate.labelVerticalSpacing,
      );
      chartCanvas.drawText(
        canvas: canvas,
        textElement: element,
        offset: offset,
        translate: gestureDelegate?.offset,
      );
    }
    canvas.restore();

    /// 绘制纵坐标
    int num = delegate.hintLineNum;
    var itemHeight = bounds.height ~/ num; // 比如，4个hintLine，中间是3个段落。
    var dValue = config.maxValue / num;

    for (var index = 0; index < num + 1; index++) {
      var element = TextElement(
        TextSpan(
          text: delegate.yAxisFormatter?.call(dValue * index, index),
          style: delegate.labelStyle?.style,
        ),
      );
      element.textAlign=TextAlign.end;
      element.textDirection = common.TextDirection.center;
      chartCanvas.drawText(
        canvas: canvas,
        textElement: element,
        offset: Offset(
          bounds.left - labelHorizontalSpacing,
          bounds.bottom -
              itemHeight * index -
              (delegate.labelStyle?.style.fontSize ?? 0) / 2,
        ),
      );
    }
  }
}
