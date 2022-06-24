import 'package:flutter/material.dart';

import 'base_layout_config.dart';
import 'gesture_delegate.dart';

/// 构建带有触摸手势的Widget
typedef GestureWidgetBuilder = Widget? Function(
  BuildContext context,
  BaseLayoutConfig newConfig,
);

/// 对[BaseChart]的上层封装，加了一层触摸手势检测
/// 传入初始配置信息：[BaseLayoutConfig]
/// 后续触摸手势更新时，构建新的[BaseLayoutConfig]
class ChartGestureView<T> extends StatefulWidget {
  /// Charts配置信息
  final BaseLayoutConfig<T> initConfig;

  /// [BaseChart]
  final GestureWidgetBuilder builder;

  const ChartGestureView({
    Key? key,
    required this.initConfig,
    required this.builder,
  }) : super(key: key);

  @override
  State<ChartGestureView> createState() => _ChartGestureViewState();
}

class _ChartGestureViewState extends State<ChartGestureView> {
  /// 触摸事件
  late GestureDelegate _gestureDelegate;

  Offset? get originalOffset => widget.initConfig.originOffset;

  Offset? get endOffset => widget.initConfig.endOffset;

  double? get draggableWidth => widget.initConfig.draggableWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gestureDelegate = widget.initConfig.gestureDelegate ?? GestureDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      /// 鼠标悬浮，认为是跟 [GestureDetector.onTapDown]事件一致。
      onHover: (detail) {
        setState(() {
          _gestureDelegate = _gestureDelegate.copyWith(
            type: GestureType.onTapDown,
            position: GesturePosition(
              local: detail.localPosition,
              global: detail.position,
            ),
          );
        });
      },
      child: GestureDetector(
        /// Chart
        child: widget.builder.call(
          context,
          widget.initConfig.copyWith(gestureDelegate: _gestureDelegate),
        ),

        /// 点击事件：点击时可以进行悬浮框的隐藏。
        onTapDown: (detail) {
          setState(() {
            _gestureDelegate = _gestureDelegate.copyWith(
              type: GestureType.onTapDown,
              position: GesturePosition(
                local: detail.localPosition,
                global: detail.globalPosition,
              ),
            );
          });
        },

        /// 拖拽事件：
        /// 这里不能用[onHorizontalDragStart]来开始，会有莫名其妙的问题。
        onHorizontalDragDown: (detail) {
          setState(() {
            _gestureDelegate = _gestureDelegate.copyWith(
              originOffset: originalOffset,
              endOffset: endOffset,
              width: draggableWidth,
              type: GestureType.onDragStart,
              position: GesturePosition(
                local: detail.localPosition,
                global: detail.globalPosition,
              ),
            )..initOffset(detail.localPosition);
          });
        },
        onHorizontalDragUpdate: (detail) {
          setState(() {
            _gestureDelegate = _gestureDelegate.copyWith(
              originOffset: originalOffset,
              endOffset: endOffset,
              width: draggableWidth,
              type: GestureType.onDragUpdate,
              position: GesturePosition(
                local: detail.localPosition,
                global: detail.globalPosition,
              ),
            )..addOffset(detail.localPosition);
          });
        },
        onHorizontalDragEnd: (detail) {
          setState(() {
            _gestureDelegate = _gestureDelegate.copyWith(
              originOffset: originalOffset,
              endOffset: endOffset,
              width: draggableWidth,
              type: GestureType.onDragEnd,
            );
          });
        },

        /// 长按事件：
        onLongPressStart: (detail) {
          setState(() {
            _gestureDelegate = _gestureDelegate.copyWith(
              type: GestureType.onLongPressStart,
              position: GesturePosition(
                local: detail.localPosition,
                global: detail.globalPosition,
              ),
            );
          });
        },
        onLongPressMoveUpdate: (detail) {
          setState(() {
            _gestureDelegate = _gestureDelegate.copyWith(
              type: GestureType.onLongPressMoveUpdate,
              position: GesturePosition(
                local: detail.localPosition,
                global: detail.globalPosition,
              ),
            );
          });
        },
        onLongPressEnd: (detail) {
          setState(() {
            _gestureDelegate = _gestureDelegate.copyWith(
              type: GestureType.onLongPressEnd,
              position: GesturePosition(
                local: detail.localPosition,
                global: detail.globalPosition,
              ),
            );
          });
        },
      ),
    );
  }
}
