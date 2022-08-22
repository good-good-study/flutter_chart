import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 事件类型
/// 1. 管理拖拽位置信息。
/// 2. 一个chart值对应一个[GestureDelegate]实例，如果需要复用已有的参数，则使用 [copyWith]
class GestureDelegate {
  /// 事件
  final GestureType type;

  /// 触摸事件的坐标信息
  final GesturePosition? position;

  /// 坐标原点
  final Offset originOffset;

  /// 最右边的坐标
  final Offset endOffset;

  /// charts初始偏移量
  final Offset? initializeOffset;

  /// 一屏的宽度
  final double width;

  GestureDelegate({
    this.type = GestureType.idle,
    this.position,
    this.originOffset = Offset.zero,
    this.endOffset = Offset.zero,
    this.initializeOffset,
    this.width = 0,
  });

  /// 将已有的信息保留，并且构建一个新的对象。
  GestureDelegate copyWith({
    GestureType? type,
    GesturePosition? position,
    Offset? originOffset,
    Offset? endOffset,
    Offset? initializeOffset,
    double? width,
  }) {
    return GestureDelegate(
      type: type ?? this.type,
      position: position ?? this.position,
      originOffset: originOffset ?? this.originOffset,
      endOffset: endOffset ?? this.endOffset,
      initializeOffset: initializeOffset ?? this.initializeOffset,
      width: width ?? this.width,
    )
      .._totalOffset = offset
      .._initDragOffset = initDragOffset;
  }

  /// 拖拽偏移量
  Offset _totalOffset = Offset.zero;

  /// 初始化偏移量。
  /// 每次从拖拽开始时记录初始偏移量
  Offset? _initDragOffset;

  /// 真实的偏移量，用于绘制
  Offset get offset {
    if (initDragOffset == null && initializeOffset != null) {
      var offset = getInitializeOffset(initializeOffset!);
      if (offset.dx.abs() > maxOffset.dx.abs()) {
        offset = Offset(-maxOffset.dx, offset.dy);
      }
      _totalOffset = offset;
      _initDragOffset = offset;
    }
    return _totalOffset;
  }

  Offset? get initDragOffset => _initDragOffset;

  /// 根据给定的点坐标计算偏移量
  /// 只有绘制内容超过一屏的宽度，才允许拖拽。
  Offset getInitializeOffset(Offset offset) {
    if (offset.dx - originOffset.dx <= width) {
      return Offset.zero;
    }
    // 将目标点位移动至原点
    return Offset(originOffset.dx - offset.dx, offset.dy);
  }

  /// 最大偏移量
  Offset get maxOffset =>
      Offset(endOffset.dx - originOffset.dx - width, endOffset.dy);

  /// 是否滑动到了左右侧，此时不允许再次滑动了。
  bool get isRightArrived => offset.dx.abs() >= maxOffset.dx;

  /// 是否滑动到了最左侧，此时就允许再次滑动了。
  bool get isStartArrived => offset.dx >= 0;

  /// 只有绘制内容超过一屏的宽度，才允许拖拽。
  bool get isDragEnable => (endOffset - originOffset).distance > width;

  /// 累加拖拽的偏移量
  /// 拖拽位置更新时调用。
  /// [GestureType.onDragStart]响应时，初始距离与真正的位置更新还有一段时间，
  /// 所以获取位移数据需要在[GestureType.onDragUpdate]状态下计算。
  void addOffset(Offset offset) {
    /// 如果只有一屏的内容，则不允许拖拽
    if (!isDragEnable) {
      return;
    }
    if (type == GestureType.onDragUpdate) {
      if (_initDragOffset == null) {
        _initDragOffset = offset;
        if (kDebugMode) {
          print('重置拖拽开始位置：$offset}');
        }
        return;
      }
      if (kDebugMode) {
        print('拖拽中...$offset');
      }
      var dis = (offset - _initDragOffset!);
      _totalOffset += dis;
      _initDragOffset = offset;

      /// 到达最左侧
      if (isStartArrived) {
        _totalOffset = Offset.zero;
        if (kDebugMode) {
          print('已经拖动到最左侧了 ➡️ ，原点：$originOffset');
        }
        return;
      }

      /// 到达最右侧
      if (isRightArrived) {
        _totalOffset = -Offset(maxOffset.dx, maxOffset.dy);
        if (kDebugMode) {
          print('已经拖动到最右侧了 ⬅️ ，最右侧：$endOffset');
        }
        return;
      }

      if (kDebugMode) {
        print('拖拽总偏移量：$_totalOffset, 原点： $originOffset,右侧 ： $maxOffset}');
      }
    }
  }

  /// 当事件类型为 [GestureType.onDragStart] 时需要调用。
  /// 初始化偏移量，注意：此偏移量不是真实的，是为了记录拖拽开始的位置。
  void initOffset(Offset offset) {
    if (type == GestureType.onDragStart) {
      _initDragOffset = offset;
      if (kDebugMode) {
        print('拖拽触发');
      }
    }
  }

  /// 是否处于拖拽模式
  bool isDragging() {
    return type == GestureType.onDragStart ||
        type == GestureType.onDragUpdate ||
        type == GestureType.onDragEnd;
  }
}

/// 坐标位置信息
class GesturePosition {
  /// 相对于自身原点（0，0）的坐标
  final Offset? local;

  /// 相对于屏幕原点（0，0）的坐标
  final Offset? global;

  const GesturePosition({this.local, this.global});
}

/// 事件类型
enum GestureType {
  idle, // 初始事件，意思就是没有事件。
  onHover,
  onTapDown,
  onLongPressStart,
  onLongPressMoveUpdate,
  onLongPressEnd,
  onDragStart,
  onDragUpdate,
  onDragEnd,
}
