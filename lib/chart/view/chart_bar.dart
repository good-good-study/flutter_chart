import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/chart_bean.dart';
import 'package:flutter_chart/chart/painter/chart_bar_painter.dart';

/// 柱状图
class ChartBar extends StatefulWidget {
  final Duration duration;
  final Size size;
  final List<ChartBean> chartBeans;
  final Color rectColor; //柱状图默认的颜色
  final Color? backgroundColor; //绘制的背景色
  final bool isShowX; //是否显示x刻度
  final double rectRadius; //矩形的圆角
  //以下的四周圆角只有在 rectRadius 为0的时候才生效
  final double rectRadiusTopLeft,
      rectRadiusTopRight,
      rectRadiusBottomLeft,
      rectRadiusBottomRight;
  final bool isAnimation; //是否执行动画
  final bool isReverse; //是否循环执行动画
  final double fontSize; //刻度文本大小
  final Color? fontColor; //文本颜色
  final bool isCanTouch; //是否可以触摸
  final Color? rectShadowColor; //触摸时显示的阴影颜色
  final bool isShowTouchShadow; //触摸时是否显示阴影
  final bool isShowTouchValue; //触摸时是否显示值

  const ChartBar({
    Key? key,
    required this.size,
    required this.chartBeans,
    this.duration = const Duration(milliseconds: 800),
    required this.rectColor,
    this.backgroundColor,
    this.isShowX = false,
    this.isAnimation = true,
    this.isReverse = false,
    this.fontSize = 12,
    this.fontColor,
    this.rectShadowColor,
    this.isCanTouch = false,
    this.isShowTouchShadow = true,
    this.isShowTouchValue = false,
    this.rectRadius = 0,
    this.rectRadiusTopLeft = 0,
    this.rectRadiusTopRight = 0,
    this.rectRadiusBottomLeft = 0,
    this.rectRadiusBottomRight = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChartBarState();
}

class ChartBarState extends State<ChartBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _value = 0;
  Offset? globalPosition;
  double begin = 0.0, end = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimation) {
      _controller = AnimationController(vsync: this, duration: widget.duration);
      Tween(begin: begin, end: end).animate(_controller!)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            print('绘制完成');
            if (widget.isReverse) {
              _controller!.repeat(reverse: widget.isReverse);
            }
          }
        })
        ..addListener(() {
          if (mounted) {
            _value = _controller!.value;
            setState(() {});
          }
        });
      _controller!.forward();
    }
  }

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var painter = ChartBarPainter(
      widget.chartBeans,
      widget.rectColor,
      isShowX: widget.isShowX,
      value: _value,
      fontSize: widget.fontSize,
      fontColor: widget.fontColor,
      isCanTouch: widget.isCanTouch,
      isShowTouchShadow: widget.isShowTouchShadow,
      isShowTouchValue: widget.isShowTouchValue,
      rectShadowColor: widget.rectShadowColor,
      globalPosition: globalPosition,
      rectRadius: widget.rectRadius,
      rectRadiusTopLeft: widget.rectRadiusTopLeft,
      rectRadiusTopRight: widget.rectRadiusTopRight,
      rectRadiusBottomLeft: widget.rectRadiusBottomLeft,
      rectRadiusBottomRight: widget.rectRadiusBottomRight,
    );

    if (widget.isCanTouch) {
      return MouseRegion(
        onHover: (PointerHoverEvent event) {
          if (mounted) {
            setState(() => globalPosition = event.position);
          }
        },
        onExit: (PointerExitEvent event) {
          if (mounted) {
            setState(() => globalPosition = null);
          }
        },
        child: GestureDetector(
          onLongPressStart: (details) {
            if (mounted) {
              setState(() => globalPosition = details.globalPosition);
            }
          },
          onLongPressMoveUpdate: (details) {
            if (mounted) {
              setState(() => globalPosition = details.globalPosition);
            }
          },
          onLongPressUp: () async {
            await Future.delayed(Duration(milliseconds: 800)).then((_) {
              if (mounted) {
                setState(() => globalPosition = null);
              }
            });
          },
          child: CustomPaint(
              size: widget.size,
              foregroundPainter:
                  widget.backgroundColor != null ? painter : null,
              child: widget.backgroundColor != null
                  ? Container(
                      width: widget.size.width,
                      height: widget.size.height,
                      color: widget.backgroundColor,
                    )
                  : null,
              painter: widget.backgroundColor == null ? painter : null),
        ),
      );
    }
    return CustomPaint(
        size: widget.size,
        foregroundPainter: widget.backgroundColor != null ? painter : null,
        child: widget.backgroundColor != null
            ? Container(
                width: widget.size.width,
                height: widget.size.height,
                color: widget.backgroundColor,
              )
            : null,
        painter: widget.backgroundColor == null ? painter : null);
  }
}
