import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/painter/base_painter.dart';

import '../chart_pie_bean.dart';

class ChartPiePainter extends BasePainter {
  double value; //当前动画值
  List<ChartPieBean> chartBeans;
  double startX, endX, startY, endY;
  double R, centerR; //圆弧半径,中心圆半径
  double centerX, centerY; //圆心
  double fontSize; //刻度文本大小
  Color fontColor; //文本颜色
  Color centerColor; //中心圆颜色
  static const double basePadding = 16; //默认的边距
  static const Color defaultColor = Colors.deepPurple;

  ChartPiePainter(
    this.chartBeans, {
    this.value = 1,
    this.R,
    this.centerR = 0,
    this.centerColor = defaultColor,
    this.fontSize = 12,
    this.fontColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    init(size);
    drawPie(canvas); //画圆弧
    drawCenter(canvas); //画中心圆
  }

  @override
  bool shouldRepaint(ChartPiePainter oldDelegate) {
    return oldDelegate.value != value;
  }

  ///初始化
  init(Size size) {
    startX = basePadding;
    endX = size.width - basePadding;
    startY = size.height - basePadding;
    endY = basePadding;

    centerX = startX + (endX - startX) / 2;
    centerY = endY + (startY - endY) / 2;
    double xR = endX - centerX;
    double yR = startY - centerY;
    double realR = xR.compareTo(yR) > 0 ? yR : xR;

    if (R == null || R == 0) {
      R = realR;
    } else {
      if (R > realR) R = realR;
    }
    if (centerR > R) centerR = R;

    setPieAngle(); //计算角度
  }

  drawPie(Canvas canvas) {
    Paint paint = Paint()..isAntiAlias = true;
    var rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: R);
    var realAngle = value * 2 * pi; //当前动画值对应的总角度
    for (var bean in chartBeans) {
      var targetAngle = bean.startAngle + bean.sweepAngle;
      paint..color = bean.color;
      if (targetAngle <= realAngle) {
        canvas.drawArc(rect, bean.startAngle, bean.sweepAngle, true, paint);
      } else if (bean.startAngle < realAngle) {
        double sweepAngle = realAngle - bean.startAngle;
        canvas.drawArc(rect, bean.startAngle, sweepAngle, true, paint);
      }
    }
  }

  void drawCenter(Canvas canvas) {
    Paint paint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(centerX, centerY), centerR, paint);
  }

  ///计算各个扇形的起始角度
  setPieAngle() {
    double total = getTotal(chartBeans);
    double rate = 0;
    double startAngle = 0; // 扇形开始的角度 正上方
    for (var bean in chartBeans) {
      rate = bean.value / total; //当前对象值所占比例
      bean.rate = rate;
      bean.startAngle = startAngle;
      bean.sweepAngle = rate * 2 * pi; //当前对象所占比例 对应的 角度
      startAngle += bean.sweepAngle;
    }
  }

  ///计算数据总和
  getTotal(List<ChartPieBean> data) {
    double total = 0;
    for (var bean in data) {
      total += bean.value;
    }
    return total;
  }
}
