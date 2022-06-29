import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/common/axis_delegate.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/find.dart';
import 'package:flutter_chart/chart/common/gesture_delegate.dart';
import 'package:flutter_chart/chart/common/popup_spec.dart';
import 'package:flutter_chart/chart/model/chart_data_model.dart';

/// line charts配置
/// 一个横坐标对应一个点，两个点之间不允许绘制内容。
/// 即：最小刻度即为一个点的距离。
class LineLayoutConfig extends BaseLayoutConfig<ChartDataModel> {
  LineLayoutConfig({
    required super.data,
    required super.size,
    super.axisCount,
    super.delegate,
    super.gestureDelegate,
    super.popupSpec,
    super.padding,
  });

  @override
  LineLayoutConfig copyWith({
    List<ChartDataModel>? data,
    int? axisCount,
    Size? size,
    AxisDelegate<ChartDataModel>? delegate,
    GestureDelegate? gestureDelegate,
    PopupSpec<ChartDataModel>? popupSpec,
    EdgeInsets? padding,
  }) {
    return LineLayoutConfig(
      data: data ?? this.data,
      size: size ?? this.size,
      axisCount: axisCount ?? this.axisCount,
      delegate: delegate ?? this.delegate,
      gestureDelegate: gestureDelegate ?? this.gestureDelegate,
      popupSpec: popupSpec ?? this.popupSpec,
      padding: padding ?? this.padding,
    );
  }

  /// 本组数据的最大值
  double? _maxValue;

  @override
  double get maxValue {
    _maxValue ??= getMaxValue(data);
    return _maxValue!;
  }

  @override
  double getMaxValue(List<ChartDataModel> data) {
    var value = 0.0;
    for (var model in data) {
      value = max(value, model.yAxis);
    }
    return value;
  }

  /// 获取y轴的数据值
  @override
  num yAxisValue(ChartDataModel data) => data.yAxis;

  /// 拖拽的最大宽度
  @override
  double? get draggableWidth => size.width - padding.horizontal;

  /// 根据手势触摸坐标查找指定数据点位
  @override
  ChartTargetFind<ChartDataModel>? findTarget(Offset offset) {
    ChartTargetFind<ChartDataModel>? find;
    // 两点之间的距离
    var itemWidth = delegate!.domainPointSpacing;
    // 选择点的最小匹配宽度
    var minSelectWidth = delegate!.minSelectWidth ?? itemWidth;
    // 当前拖拽的偏移量
    var dragX = (gestureDelegate?.offset ?? Offset.zero).dx;

    for (var index = 0; index < data.length; index++) {
      var model = data[index];
      var curr = Offset(
        bounds.left + dragX + itemWidth * index,
        bounds.bottom - yAxisValue(model) / maxValue * bounds.height,
      );
      if ((curr - offset).dx.abs() <= minSelectWidth) {
        find = ChartTargetFind(model, curr);
        break;
      }
    }
    return find;
  }
}
