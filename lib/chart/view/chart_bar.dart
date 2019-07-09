import 'dart:ui';

import 'package:flutter_chart/chart/chart_bean.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/painter/chart_bar_painter.dart';

class ChartBar extends StatefulWidget {
  final Duration duration;
  final Size size;
  final List<ChartBean> chartBeans;
  final Color rectColor; //柱状图默认的颜色
  final Color backgroundColor; //绘制的背景色
  final bool isShowX; //是否显示x刻度
  final bool isAnimation; //是否执行动画
  final bool isCycle; //是否循环执行动画
  final double fontSize; //刻度文本大小
  final Color fontColor; //文本颜色

  const ChartBar({
    Key key,
    @required this.size,
    @required this.chartBeans,
    this.duration = const Duration(milliseconds: 800),
    this.rectColor,
    this.backgroundColor,
    this.isShowX = false,
    this.isAnimation = true,
    this.isCycle = false,
    this.fontSize = 12,
    this.fontColor,
  })  : assert(rectColor != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => ChartBarState();
}

class ChartBarState extends State<ChartBar>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double _value = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimation) {
      _controller = AnimationController(vsync: this, duration: widget.duration);
      Tween(begin: 0.0, end: 1.0).animate(_controller)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            print('绘制完成');
            if (widget.isCycle) {
              setState(() {
                _value = 0;
              });
              _controller.forward(from: 0.0);
            }
          }
        })
        ..addListener(() {
          _value = _controller.value;
          setState(() {});
        });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
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
    );
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
