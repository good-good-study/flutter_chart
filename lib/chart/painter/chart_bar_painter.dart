import 'dart:ui';

import 'package:flutter_chart/chart/chart_bean.dart';
import 'package:flutter_chart/chart/painter/base_painter.dart';
import 'package:flutter/material.dart';

class ChartBarPainter extends BasePainter {
  double fixedHeight, fixedWidth; //宽高
  double value; //当前动画值
  List<ChartBean> chartBeans;
  double startX, endX, startY, endY;
  List<double> maxMin = [0, 0]; //存储极值
  Color rectColor; //柱状图默认的颜色
  bool isShowX; //是否显示x轴的文本
  double rectWidth; //柱状图的宽度
  double fontSize; //刻度文本大小
  Color fontColor; //文本颜色
  static const double defaultRectPadding = 8; //默认柱状图的间隔
  static const double basePadding = 16; //默认的边距
  static const Color defaultColor = Colors.deepPurple;

  ChartBarPainter(this.chartBeans,
      this.rectColor, {
        this.value = 1,
        this.isShowX = false,
        this.fontSize = 12,
        this.fontColor,
      });

  @override
  void paint(Canvas canvas, Size size) {
    init(size);
    drawX(canvas, size); //x轴刻度
    drawBar(canvas, size); //柱状图
  }

  ///初始化
  void init(Size size) {
    print('size - - > $size');
    startX = basePadding;
    endX = size.width - basePadding;
    startY = size.height - (isShowX ? basePadding * 3 : basePadding);
    endY = basePadding * 2;
    fixedHeight = startY - endY;
    fixedWidth = endX - startX;
    maxMin = calculateMaxMin(chartBeans);

    //去除所有间隔之后的所有柱状图宽度(最多7个柱状图,6段)
    var maxRectsWidth = fixedWidth - 6 * defaultRectPadding;
    rectWidth = maxRectsWidth / 7; //单个柱状图的宽度
  }

  ///x轴刻度
  void drawX(Canvas canvas, Size size) {
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
  void drawBar(Canvas canvas, Size size) {
    if (chartBeans == null || chartBeans.length == 0) return;
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = rectColor
      ..style = PaintingStyle.fill;

    if (maxMin[0] <= 0) return;
    //最多只绘制7组数据
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
          startY - chartBeans[i].y / maxMin[0] * fixedHeight * value;
      canvas.drawRect(Rect.fromLTRB(left, currentHeight, right, startY), paint);
    }
  }
}
