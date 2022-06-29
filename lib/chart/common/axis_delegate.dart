import 'package:flutter/material.dart';

import 'style.dart';

/// x轴数据格式化
/// [input] : chart数据类型。
typedef AxisFormatter = String Function(int rulerIndex);

/// y轴数据格式化
/// [input] : y轴刻度的百分比。
/// [rulerIndex] : y轴上的刻度索引。
typedef AxisYFormatter = String Function(num input, int rulerIndex);

/// 域轴配置信息
class AxisDelegate<T> {
  /// 是否显示x轴
  final bool showXAxisLine;

  /// 是否显示y轴
  final bool showYAxisLine;

  /// 是否显示最右侧的y轴
  final bool showEndYAxisLine;

  /// 是否显示横轴的辅助线
  final bool showHorizontalHintAxisLine;

  /// 是否显示纵轴的辅助线
  final bool showVerticalHintAxisLine;

  /// 辅助线数量
  final int hintLineNum;

  /// x轴数据格式化
  final AxisFormatter? xAxisFormatter;

  /// y轴数据格式化
  final AxisYFormatter? yAxisFormatter;

  /// 两点之间的距离
  final double domainPointSpacing;

  /// 选中点时的最小匹配宽度
  final double? minSelectWidth;

  /// x轴与文字间的距离
  final double labelVerticalSpacing;

  /// y轴与文字间的距离
  final double labelHorizontalSpacing;

  /// 文本样式
  final LabelStyle? labelStyle;

  /// 文本居中方式
  final TextAnchor? labelAnchor;

  /// 轴线样式：
  final LineStyle? lineStyle;

  /// 辅助线样式：
  final LineStyle? hintLineStyle;

  /// 轴线样式：x、y
  final LineStyle? axisLineStyle;

  /// Bar样式：
  final BarStyle? barStyle;

  const AxisDelegate({
    this.showXAxisLine = true,
    this.showYAxisLine = true,
    this.showEndYAxisLine = true,
    this.showHorizontalHintAxisLine = true,
    this.showVerticalHintAxisLine = true,
    this.hintLineNum = 4,
    this.xAxisFormatter,
    this.yAxisFormatter,
    this.minSelectWidth = kDomainPointSpacing,
    this.domainPointSpacing = kDomainPointSpacing,
    this.labelHorizontalSpacing = kLabelHorizontalSpacing,
    this.labelVerticalSpacing = kLabelVerticalSpacing,
    this.labelStyle,
    this.labelAnchor,
    this.lineStyle,
    this.hintLineStyle,
    this.axisLineStyle,
    this.barStyle,
  });

  AxisDelegate<T> copyWith({
    bool? showXAxisLine,
    bool? showYAxisLine,
    bool? showEndYAxisLine,
    bool? showHorizontalHintAxisLine,
    int? hintLineNum,
    AxisFormatter? xAxisFormatter,
    AxisYFormatter? yAxisFormatter,
    double? domainPointSpacing,
    double? minSelectWidth,
    double? labelVerticalSpacing,
    double? labelHorizontalSpacing,
    LabelStyle? labelStyle,
    TextAnchor? labelAnchor,
    LineStyle? lineStyle,
    LineStyle? hintLineStyle,
    LineStyle? axisLineStyle,
    BarStyle? barStyle,
  }) {
    return AxisDelegate(
      showXAxisLine: showXAxisLine ?? this.showXAxisLine,
      showYAxisLine: showYAxisLine ?? this.showYAxisLine,
      showEndYAxisLine: showEndYAxisLine ?? this.showEndYAxisLine,
      showHorizontalHintAxisLine:
          showHorizontalHintAxisLine ?? this.showHorizontalHintAxisLine,
      hintLineNum: hintLineNum ?? this.hintLineNum,
      xAxisFormatter: xAxisFormatter ?? this.xAxisFormatter,
      yAxisFormatter: yAxisFormatter ?? this.yAxisFormatter,
      domainPointSpacing: domainPointSpacing ?? this.domainPointSpacing,
      minSelectWidth: minSelectWidth ?? this.minSelectWidth,
      labelHorizontalSpacing:
          labelHorizontalSpacing ?? this.labelHorizontalSpacing,
      labelVerticalSpacing: labelVerticalSpacing ?? this.labelVerticalSpacing,
      labelStyle: labelStyle ?? this.labelStyle,
      labelAnchor: labelAnchor ?? this.labelAnchor,
      lineStyle: lineStyle ?? this.lineStyle,
      hintLineStyle: hintLineStyle ?? this.hintLineStyle,
      axisLineStyle: axisLineStyle ?? this.axisLineStyle,
      barStyle: barStyle ?? this.barStyle,
    );
  }
}

/// 文本样式
class LabelStyle {
  final TextStyle style;

  const LabelStyle({this.style = const TextStyle(color: Colors.grey)});
}

/// 文本居中方式
enum TextAnchor {
  before,
  centered,
  after,
  inside,
}

/// 线样式
class LineStyle {
  final Color color;
  final List<int>? dashPattern;
  final double strokeWidth;
  final int? thickness;

  /// 是否为曲线
  final bool isCurved;

  const LineStyle({
    this.color = Colors.grey,
    this.strokeWidth = 1,
    this.dashPattern,
    this.thickness,
    this.isCurved = true,
  });

  LineStyle copyWith({
    Color? color,
    List<int>? dashPattern,
    double? strokeWidth,
    int? thickness,
    bool? isCurved,
  }) {
    return LineStyle(
      color: color ?? this.color,
      dashPattern: dashPattern ?? this.dashPattern,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      thickness: thickness ?? this.thickness,
      isCurved: isCurved ?? this.isCurved,
    );
  }
}

/// bar样式
class BarStyle {
  final Color? fill;
  final Color? stroke;
  final double height;
  final double strokeWidth;

  const BarStyle({
    this.fill,
    this.stroke,
    this.height = 9,
    this.strokeWidth = 1,
  });

  BarStyle copyWith({
    Color? fill,
    Color? stroke,
    double? height,
    double? strokeWidth,
  }) {
    return BarStyle(
      fill: fill ?? this.fill,
      stroke: stroke ?? this.stroke,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      height: height ?? this.height,
    );
  }
}
