import 'package:flutter/material.dart';

import 'axis_delegate.dart';

/// [InlineSpan] 悬浮框显示文本内容，可以绘制富文本。
/// [T] charts 的数据类型。
typedef PopupTextFormatter<T> = InlineSpan Function(T data);

/// 对应点是否需要绘制悬浮框、气泡
typedef PopupShouldDraw<T> = bool Function(T data);

/// 悬浮框
class PopupSpec<T> {
  /// 高亮点气泡样式
  final BubbleSpec? bubbleSpec;

  /// 辅助线样式
  final LineStyle? lineStyle;

  /// 内边距
  final EdgeInsets padding;

  /// 悬浮框背景色
  final Color? fill;

  /// 悬浮框边框阴影
  final Color? stroke;

  /// 边框宽度
  final double? strokeWidthPx;

  /// 圆角
  final num? radius;

  /// 可以分别设置上下左右的圆角
  final bool roundTopLeft;
  final bool roundTopRight;
  final bool roundBottomLeft;
  final bool roundBottomRight;

  /// 绘制内容
  final PopupTextFormatter<T>? textFormatter;

  /// 是否应该显示该坐标的悬浮框
  final PopupShouldDraw<T>? popupShouldDraw;

  /// 是否应该显示该坐标的气泡
  final PopupShouldDraw<T>? bubbleShouldDraw;

  const PopupSpec({
    this.bubbleSpec,
    this.lineStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    this.fill,
    this.stroke,
    this.strokeWidthPx,
    this.radius,
    this.roundTopLeft = true,
    this.roundTopRight = true,
    this.roundBottomLeft = true,
    this.roundBottomRight = true,
    this.textFormatter,
    this.popupShouldDraw,
    this.bubbleShouldDraw,
  });

  PopupSpec<T> copyWith({
    LineStyle? lineStyle,
    EdgeInsets? padding,
    BubbleSpec? bubbleSpec,
    Color? fill,
    Color? stroke,
    double? strokeWidthPx,
    num? radius,
    bool? roundTopLeft,
    bool? roundTopRight,
    bool? roundBottomLeft,
    bool? roundBottomRight,
    PopupTextFormatter<T>? textFormatter,
    PopupShouldDraw<T>? popupShouldDraw,
    PopupShouldDraw<T>? bubbleShouldDraw,
  }) {
    return PopupSpec(
      lineStyle: lineStyle ?? this.lineStyle,
      padding: padding ?? this.padding,
      bubbleSpec: bubbleSpec ?? this.bubbleSpec,
      textFormatter: textFormatter ?? this.textFormatter,
      popupShouldDraw: popupShouldDraw ?? this.popupShouldDraw,
      bubbleShouldDraw: bubbleShouldDraw ?? this.bubbleShouldDraw,
      fill: fill ?? this.fill,
      stroke: stroke ?? this.stroke,
      strokeWidthPx: strokeWidthPx ?? this.strokeWidthPx,
      radius: radius ?? this.radius,
      roundTopLeft: roundTopLeft ?? this.roundTopLeft,
      roundTopRight: roundTopRight ?? this.roundTopRight,
      roundBottomLeft: roundBottomLeft ?? this.roundBottomLeft,
      roundBottomRight: roundBottomRight ?? this.roundBottomRight,
    );
  }
}

/// 高亮点气泡样式（标注charts上的某一个点）
class BubbleSpec {
  /// 圆角
  final double radius;

  /// 填充色
  final Color? fill;

  /// 边框颜色
  final Color? stroke;

  /// 边框宽度
  final double? strokeWidthPx;

  const BubbleSpec({
    this.radius = 6,
    this.fill,
    this.stroke,
    this.strokeWidthPx,
  });

  BubbleSpec copyWith({
    double? radius,
    Color? fill,
    Color? stroke,
    double? strokeWidthPx,
  }) {
    return BubbleSpec(
      radius: radius ?? this.radius,
      fill: fill ?? this.fill,
      stroke: stroke ?? this.stroke,
      strokeWidthPx: strokeWidthPx ?? this.strokeWidthPx,
    );
  }
}
