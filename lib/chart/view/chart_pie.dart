import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/painter/chart_pie_painter.dart';

import '../chart_pie_bean.dart';

/// 饼状图
class ChartPie extends StatefulWidget {
  final Duration duration;
  final Size size;
  final List<ChartPieBean> chartBeans;
  final Color? backgroundColor; //绘制的背景色
  final bool isAnimation; //是否执行动画
  final double? R, centerR; //半径,中心圆半径
  final Color? centerColor; //中心圆颜色
  final double fontSize; //刻度文本大小
  final Color? fontColor; //文本颜色

  const ChartPie({
    Key? key,
    required this.size,
    required this.chartBeans,
    this.duration = const Duration(milliseconds: 800),
    this.backgroundColor,
    this.isAnimation = true,
    this.R,
    this.centerR,
    this.centerColor,
    this.fontSize = 12,
    this.fontColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChartPieState();
}

class ChartPieState extends State<ChartPie>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _value = 0;
  double begin = 0.0, end = 360;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimation) {
      _controller = AnimationController(vsync: this, duration: widget.duration);
      Tween(begin: begin, end: end).animate(_controller!)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (kDebugMode) {
              print('绘制完成');
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
    var painter = ChartPiePainter(
      widget.chartBeans,
      value: _value,
      R: widget.R,
      centerR: widget.centerR,
      centerColor: widget.centerColor,
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
