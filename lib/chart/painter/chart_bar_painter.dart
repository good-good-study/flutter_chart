import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/chart_bean.dart';
import 'package:flutter_chart/chart/painter/base_painter.dart';

class ChartBarPainter extends BasePainter {
  double _fixedHeight, _fixedWidth; //宽高
  double value; //当前动画值
  List<ChartBean> chartBeans;
  double startX, endX, startY, endY;
  List<double> maxMin = [0, 0]; //存储极值
  Color rectColor; //柱状图默认的颜色
  bool isShowX; //是否显示x轴的文本
  double rectWidth; //柱状图的宽度
  double fontSize; //刻度文本大小
  Color fontColor; //文本颜色
  double rectRadius; //矩形的圆角
  //以下的四周圆角只有在 rectRadius 为0的时候才生效
  double rectRadiusTopLeft,
      rectRadiusTopRight,
      rectRadiusBottomLeft,
      rectRadiusBottomRight;
  bool _isAnimationEnd = false;
  bool isCanTouch;
  Color rectShadowColor; //触摸时显示的阴影颜色
  bool isShowTouchShadow; //触摸时是否显示阴影
  bool isShowTouchValue; //触摸时是否显示值
  Offset globalPosition; //触摸位置
  Map<Rect, double> rectMap = new Map();

  static const double defaultRectPadding = 8; //默认柱状图的间隔
  static const double basePadding = 16; //默认的边距
  static const Color defaultColor = Colors.deepPurple;
  static const Color defaultRectShadowColor = Colors.white;

  ChartBarPainter(
    this.chartBeans,
    this.rectColor, {
    this.value = 1,
    this.isShowX = false,
    this.fontSize = 12,
    this.fontColor,
    this.isCanTouch = false,
    this.isShowTouchShadow = true,
    this.isShowTouchValue = false,
    this.rectShadowColor,
    this.globalPosition,
    this.rectRadius = 0,
    this.rectRadiusTopLeft = 0,
    this.rectRadiusTopRight = 0,
    this.rectRadiusBottomLeft = 0,
    this.rectRadiusBottomRight = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _init(size);
    _drawX(canvas, size); //x轴刻度
    _drawBar(canvas, size); //柱状图
    _drawOnPressed(canvas, size); //绘制触摸
  }

  @override
  bool shouldRepaint(ChartBarPainter oldDelegate) {
    _isAnimationEnd = oldDelegate.value == value;
    return oldDelegate.value != value || isCanTouch;
  }

  ///初始化
  void _init(Size size) {
    startX = basePadding;
    endX = size.width - basePadding;
    startY = size.height - (isShowX ? basePadding * 3 : basePadding);
    endY = basePadding * 2;
    _fixedHeight = startY - endY;
    _fixedWidth = endX - startX;
    maxMin = calculateMaxMin(chartBeans);

    //去除所有间隔之后的所有柱状图宽度(最多7个柱状图,6段)
    var maxRectsWidth = _fixedWidth - 6 * defaultRectPadding;
    rectWidth = maxRectsWidth / 7; //单个柱状图的宽度
  }

  ///x轴刻度
  void _drawX(Canvas canvas, Size size) {
    if (chartBeans != null && chartBeans.length > 0) {
      for (int i = 0; i < chartBeans.length; i++) {
        double x = startX + defaultRectPadding * i + rectWidth * i;
        TextPainter(
            ellipsis: '.',
            maxLines: 1,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            text: TextSpan(
                text: chartBeans[i].x,
                style: TextStyle(
                  color: fontColor != null ? fontColor : defaultColor,
                  fontSize: fontSize,
                )))
          ..layout(minWidth: rectWidth, maxWidth: rectWidth)
          ..paint(canvas, Offset(x, startY + basePadding));
      }
    }
  }

  ///柱状图
  void _drawBar(Canvas canvas, Size size) {
    if (chartBeans == null || chartBeans.length == 0) return;
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = rectColor
      ..style = PaintingStyle.fill;

    if (maxMin[0] <= 0) return;
    //最多只绘制7组数据
    rectMap.clear();
    var length = chartBeans.length > 7 ? 7 : chartBeans.length;
    for (int i = 0; i < length; i++) {
      if (chartBeans[i].color != null) {
        paint.color = chartBeans[i].color;
      } else {
        paint.color = rectColor;
      }
      double left = startX + defaultRectPadding * i + rectWidth * i;
      double right = left + rectWidth;
      double currentHeight =
          startY - chartBeans[i].y / maxMin[0] * _fixedHeight * value;
      var rect = Rect.fromLTRB(left, currentHeight, right, startY);
      if (rectRadius != 0) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(rectRadius)), paint);
      } else {
        canvas.drawRRect(
            RRect.fromRectAndCorners(rect,
                topLeft: Radius.circular(rectRadiusTopLeft),
                topRight: Radius.circular(rectRadiusTopRight),
                bottomLeft: Radius.circular(rectRadiusBottomLeft),
                bottomRight: Radius.circular(rectRadiusBottomRight)),
            paint);
      }
      if (!rectMap.containsKey(rect)) rectMap[rect] = chartBeans[i].y;
    }
  }

  ///绘制触摸
  void _drawOnPressed(Canvas canvas, Size size) {
    print('globalPosition == $globalPosition');
    if (!_isAnimationEnd) return;
    if (globalPosition == null) return;
    if (chartBeans == null || chartBeans.length == 0 || maxMin[0] <= 0) return;
    try {
      Offset pointer = globalPosition;

      ///修复x轴越界
      if (pointer.dx < startX) pointer = Offset(startX, pointer.dy);
      if (pointer.dx > endX) pointer = Offset(endX, pointer.dy);

      //查找当前触摸点对应的rect
      Rect currentRect;
      var yValue;
      rectMap.forEach((rect, value) {
        if (rect.left - defaultRectPadding <= pointer.dx &&
            pointer.dx <= rect.right + defaultRectPadding) {
          currentRect = rect;
          yValue = value;
        }
      });
      if (currentRect != null) {
        if (isShowTouchShadow) {
          var paint = new Paint()
            ..isAntiAlias = true
            ..color = rectShadowColor == null
                ? defaultRectShadowColor.withOpacity(0.5)
                : rectShadowColor;
          if (rectRadius != 0) {
            canvas.drawRRect(
                RRect.fromRectAndRadius(
                    currentRect, Radius.circular(rectRadius)),
                paint);
          } else {
            canvas.drawRRect(
                RRect.fromRectAndCorners(currentRect,
                    topLeft: Radius.circular(rectRadiusTopLeft),
                    topRight: Radius.circular(rectRadiusTopRight),
                    bottomLeft: Radius.circular(rectRadiusBottomLeft),
                    bottomRight: Radius.circular(rectRadiusBottomRight)),
                paint);
          }
        }

        ///绘制文本
        if (isShowTouchValue) {
          TextPainter(
              textAlign: TextAlign.center,
              ellipsis: '.',
              maxLines: 1,
              text: TextSpan(
                  text: "$yValue",
                  style: TextStyle(color: fontColor, fontSize: fontSize)),
              textDirection: TextDirection.ltr)
            ..layout(minWidth: 40, maxWidth: 40)
            ..paint(canvas,
                Offset(currentRect.left, currentRect.top - basePadding));
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
