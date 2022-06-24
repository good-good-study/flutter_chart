import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/common/style.dart';

import 'axis_delegate.dart';
import 'find.dart';
import 'gesture_delegate.dart';
import 'popup_spec.dart';

/// Charts基础配置
abstract class BaseLayoutConfig<T> {
  /// 数据源
  final List<T> data;

  /// 绘制大小
  final Size size;

  /// x轴刻度的数量，默认取[data.length].
  final int? axisCount;

  /// 坐标原点
  final Offset originOffset;

  /// 最右边的坐标
  final Offset endOffset;

  /// 绘制区域
  final Rect bounds;

  /// 内边距，绘制在[bounds]的内容区域以为
  final EdgeInsets padding;

  /// 域轴配置信息
  final AxisDelegate<T>? delegate;

  /// 触摸事件
  final GestureDelegate? gestureDelegate;

  /// 悬浮框样式
  final PopupSpec<T>? popupSpec;

  /// 一组数据的最大值
  num get maxValue => 0.0;

  /// 计算最大值
  num getMaxValue(List<T> data) => 0.0;

  /// 获取指定数据的y轴值
  num yAxisValue(T data) => 0.0;

  /// 获取x轴指定位置的值 07：00
  String? xAxisValue(int index) => null;

  /// x轴刻度数量
  int get xAxisCount => axisCount ?? data.length;

  /// 根据触摸坐标，匹配目标点位
  ChartTargetFind<T>? findTarget(Offset offset) => null;

  /// 定义手势拖拽的宽度，一般为一屏的宽度。
  double? get draggableWidth => size.width - padding.horizontal;

  /// 复用已有字段重新创建一个新的Config.
  BaseLayoutConfig<T> copyWith({
    Size? size,
    int? axisCount,
    AxisDelegate<T>? delegate,
    GestureDelegate? gestureDelegate,
    PopupSpec<T>? popupSpec,
    EdgeInsets? padding,
  }) {
    return this;
  }

  BaseLayoutConfig({
    required this.data,
    required this.size,
    this.axisCount,
    this.delegate,
    final GestureDelegate? gestureDelegate,
    this.popupSpec,
    this.padding = const EdgeInsets.only(
      left: 40,
      top: 32,
      right: 16,
      bottom: 40,
    ),
  })  :
        // 计算绘制区域
        bounds = Rect.fromLTWH(
          padding.left,
          padding.top,
          size.width - padding.left - padding.right,
          size.height - padding.top - padding.bottom,
        ),
        // 坐标系原点
        originOffset = _initOriginOffset(size: size, padding: padding),
        // 最右边的点，包括不可见的坐标（即：可拖动查看的最右边的点坐标）
        endOffset = data.isEmpty
            ? _initOriginOffset(size: size, padding: padding)
            : _initEndOffset(
                length: axisCount ?? data.length,
                size: size,
                delegate: delegate,
                padding: padding,
              ),
        // 初始化手势识别器
        gestureDelegate = gestureDelegate?.copyWith(
          width: size.width - padding.horizontal,
          originOffset: _initOriginOffset(size: size, padding: padding),
          endOffset: data.isEmpty
              ? Offset(
                  padding.left,
                  size.height - padding.bottom,
                )
              : _initEndOffset(
                  length: axisCount ?? data.length,
                  size: size,
                  delegate: delegate,
                  padding: padding,
                ),
        );
}

/// 计算坐标原点
Offset _initOriginOffset({
  required Size size,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  var offset = Offset(
    padding.left,
    size.height - padding.bottom,
  );
  return offset;
}

/// 最右边的点，包括不可见的坐标（即：可拖动查看的最右边的点坐标）
Offset _initEndOffset<T, V>({
  int length = 0,
  required Size size,
  AxisDelegate<T>? delegate,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  var offset = Offset(
    length * (delegate?.domainPointSpacing ?? kDomainPointSpacing),
    size.height - padding.bottom,
  );
  return offset;
}
