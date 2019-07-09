import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/chart_bean.dart';
import 'package:flutter_chart/chart/painter/base_painter.dart';

class ChartLinePainter extends BasePainter {
  double value; //当前动画值
  List<ChartBean> chartBeans;
  List<Color> shaderColors; //渐变色
  Color lineColor; //曲线或折线的颜色
  Color xyColor; //xy轴的颜色
  static const double basePadding = 16; //默认的边距
  List<double> maxMin = [0, 0]; //存储极值
  bool isCurve; //是否为曲线
  bool isShowYValue; //是否显示y轴数值
  bool isShowXy; //是否显示坐标轴
  bool isShowXyRuler; //是否显示xy刻度
  bool isShowHintX, isShowHintY; //x、y轴的辅助线
  bool isShowBorderTop, isShowBorderRight; //顶部和右侧的辅助线
  int yNum; //y轴的值数量,默认为5个
  bool isShowFloat; //y轴的值是否显示小数
  double fontSize;
  Color fontColor;
  double lineWidth; //线宽
  double rulerWidth; //刻度的宽度或者高度
  Color rulerColor; //刻度的颜色
  double startX, endX, startY, endY;
  double _fixedHeight, _fixedWidth; //宽高
  Path path;
  Map<double, Offset> _points = new Map();

  bool _isAnimationEnd = false;
  bool _isPressed = false;
  LongPressMoveUpdateDetails _longPressMoveUpdateDetails;
  LongPressStartDetails _longPressStartDetails;

  LongPressMoveUpdateDetails Function() pressedMove;
  LongPressStartDetails Function() pressedStart;

  static const Color defaultColor = Colors.deepPurple;

  ChartLinePainter(
    this.chartBeans,
    this.lineColor, {
    this.lineWidth = 4,
    this.value = 1,
    this.isCurve = true,
    this.isShowXy = true,
    this.isShowYValue = false,
    this.isShowXyRuler = true,
    this.isShowHintX = false,
    this.isShowHintY = false,
    this.isShowBorderTop = false,
    this.isShowBorderRight = false,
    this.rulerWidth = 8,
    this.shaderColors,
    this.xyColor = defaultColor,
    this.yNum = 5,
    this.isShowFloat = false,
    this.fontSize = 10,
    this.fontColor = defaultColor,
    this.rulerColor = defaultColor,
    this.pressedStart,
    this.pressedMove,
  }) {
    if (pressedStart != null) {
      onLongPressStart(pressedStart());
      print('long press start');
    }
    if (pressedMove != null) {
      onLongPressMoveUpdate(pressedMove());
      print('long press move');
    }
    if (pressedStart == null && pressedMove == null) {
      onLongPressUp();
      print('long press up');
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _init(size);
    _drawXy(canvas, size); //坐标轴
    _drawLine(canvas, size); //曲线或折线
    _drawOnPressed(canvas, size); //绘制触摸
  }

  @override
  bool shouldRepaint(ChartLinePainter oldDelegate) {
    _isAnimationEnd = oldDelegate.value == value;
    return oldDelegate.value != value || _isPressed;
  }

  ///初始化
  void _init(Size size) {
    initValue();
    initBorder(size);
    initPath(size);
  }

  void initValue() {
    if (lineColor == null) {
      lineColor = defaultColor;
    }
    if (xyColor == null) {
      xyColor = defaultColor;
    }
    if (rulerColor == null) {
      rulerColor = defaultColor;
    }
    if (fontColor == null) {
      fontColor = defaultColor;
    }
    if (fontSize == null) {
      fontSize = 10;
    }
    if (yNum == null) {
      yNum = 5;
    }
    if (isShowFloat == null) {
      isShowFloat = false;
    }
  }

  ///计算边界
  void initBorder(Size size) {
    startX = yNum > 0 ? basePadding * 2.5 : basePadding * 2; //预留出y轴刻度值所占的空间
    endX = size.width - basePadding * 2;
    startY = size.height - (isShowXyRuler ? basePadding * 3 : basePadding);
    endY = basePadding * 2;
    _fixedHeight = startY - endY;
    _fixedWidth = endX - startX;
    maxMin = calculateMaxMin(chartBeans);
  }

  ///计算Path
  void initPath(Size size) {
    if (path == null) {
      if (chartBeans != null && chartBeans.length > 0 && maxMin[0] > 0) {
        path = Path();
        double preX, preY, currentX, currentY;
        int length = chartBeans.length > 7 ? 7 : chartBeans.length;
        double W = _fixedWidth / (length - 1); //两个点之间的x方向距离
        for (int i = 0; i < length; i++) {
          if (i == 0) {
            var key = startX;
            var value = (startY - chartBeans[i].y / maxMin[0] * _fixedHeight);
            path.moveTo(key, value);
            _points[key] = Offset(key, value);
            continue;
          }
          currentX = startX + W * i;
          preX = startX + W * (i - 1);

          preY = (startY - chartBeans[i - 1].y / maxMin[0] * _fixedHeight);
          currentY = (startY - chartBeans[i].y / maxMin[0] * _fixedHeight);
          _points[currentX] = Offset(currentX, currentY);

          if (isCurve) {
            path.cubicTo((preX + currentX) / 2, preY, (preX + currentX) / 2,
                currentY, currentX, currentY);
          } else {
            path.lineTo(currentX, currentY);
          }
        }
      }
    }
  }

  ///x,y轴
  void _drawXy(Canvas canvas, Size size) {
    if (!isShowXy && !isShowXyRuler) return;
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = xyColor
      ..style = PaintingStyle.stroke;
    if (isShowXy) {
      canvas.drawLine(Offset(startX, startY),
          Offset(endX + basePadding, startY), paint); //x轴
      canvas.drawLine(Offset(startX, startY),
          Offset(startX, endY - basePadding), paint); //y轴
      if (isShowBorderTop) {
        ///最顶部水平边界线
        canvas.drawLine(Offset(startX, endY - basePadding),
            Offset(endX + basePadding, endY - basePadding), paint);
      }
      if (isShowBorderRight) {
        ///最右侧垂直边界线
        canvas.drawLine(Offset(endX + basePadding, startY),
            Offset(endX + basePadding, endY - basePadding), paint);
      }
    }
    drawRuler(canvas, paint); //刻度
  }

  ///x,y轴刻度 & 辅助线
  void drawRuler(Canvas canvas, Paint paint) {
    if (!isShowXyRuler) return;
    if (chartBeans != null && chartBeans.length > 0) {
      int length = chartBeans.length > 7 ? 7 : chartBeans.length; //最多绘制7个
      double dw = _fixedWidth / (length - 1); //两个点之间的x方向距离
      double dh = _fixedHeight / (length - 1); //两个点之间的y方向距离
      for (int i = 0; i < length; i++) {
        ///绘制x轴文本
        TextPainter(
            textAlign: TextAlign.center,
            ellipsis: '.',
            text: TextSpan(
                text: chartBeans[i].x,
                style: TextStyle(color: fontColor, fontSize: fontSize)),
            textDirection: TextDirection.ltr)
          ..layout(minWidth: 40, maxWidth: 40)
          ..paint(canvas, Offset(startX + dw * i - 20, startY + basePadding));

        if (isShowHintX) {
          ///x轴辅助线
          canvas.drawLine(
              Offset(startX, startY - dh * i),
              Offset(endX + basePadding, startY - dh * i),
              paint..color = paint.color.withOpacity(0.5));
        }

        if (isShowHintY) {
          ///y轴辅助线
          canvas.drawLine(Offset(startX + dw * i, startY),
              Offset(startX + dw * i, endY - basePadding), paint);
        }

        ///x轴刻度
        canvas.drawLine(Offset(startX + dw * i, startY),
            Offset(startX + dw * i, startY - rulerWidth), paint);
      }
      int yLength = yNum + 1; //包含原点,所以 +1
      double dValue = maxMin[0] / yNum; //一段对应的值
      double dV = _fixedHeight / yNum; //一段对应的高度
      for (int i = 0; i < yLength; i++) {
        ///绘制y轴文本，保留1位小数
        var yValue = (dValue * i).toStringAsFixed(isShowFloat ? 1 : 0);
        TextPainter(
            textAlign: TextAlign.center,
            ellipsis: '.',
            maxLines: 1,
            text: TextSpan(
                text: '$yValue',
                style: TextStyle(color: fontColor, fontSize: fontSize)),
            textDirection: TextDirection.rtl)
          ..layout(minWidth: 40, maxWidth: 40)
          ..paint(canvas, Offset(startX - 40, startY - dV * i - fontSize / 2));

        ///y轴刻度
        canvas.drawLine(Offset(startX, startY - dV * (i)),
            Offset(startX + rulerWidth, startY - dV * (i)), paint);
      }
    }
  }

  ///曲线或折线
  void _drawLine(Canvas canvas, Size size) {
    if (chartBeans == null || chartBeans.length == 0) return;
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    if (maxMin[0] <= 0) return;
    var pathMetrics = path.computeMetrics(forceClosed: false);
    var list = pathMetrics.toList();
    var length = value * list.length.toInt();
    Path linePath = new Path();
    Path shadowPath = new Path();
    for (int i = 0; i < length; i++) {
      var extractPath =
          list[i].extractPath(0, list[i].length * value, startWithMoveTo: true);
      linePath.addPath(extractPath, Offset(0, 0));
      shadowPath = extractPath;
    }

    ///画阴影,注意LinearGradient这里需要指定方向，默认为从左到右
    if (shaderColors != null) {
      var shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.clamp,
              colors: shaderColors)
          .createShader(Rect.fromLTRB(startX, endY, startX, startY));

      ///从path的最后一个点连接起始点，形成一个闭环
      shadowPath
        ..lineTo(startX + _fixedWidth * value, startY)
        ..lineTo(startX, startY)
        ..close();

      canvas
        ..drawPath(
            shadowPath,
            new Paint()
              ..shader = shader
              ..isAntiAlias = true
              ..style = PaintingStyle.fill);
    }

    ///先画阴影再画曲线，目的是防止阴影覆盖曲线
    canvas.drawPath(linePath, paint);
  }

  ///绘制触摸
  void _drawOnPressed(Canvas canvas, Size size) {
    if (!_isAnimationEnd) return;
    if (!_isPressed) return;
    if (chartBeans == null || chartBeans.length == 0 || maxMin[0] <= 0) return;
    try {
      Offset pointer = _longPressStartDetails != null
          ? _longPressStartDetails.globalPosition
          : _longPressMoveUpdateDetails.globalPosition;

      ///修复x轴越界
      if (pointer.dx < startX) pointer = Offset(startX, pointer.dy);
      if (pointer.dx > endX) pointer = Offset(endX, pointer.dy);

      double currentX, currentY;
      int length = chartBeans.length > 7 ? 7 : chartBeans.length;
      double W = _fixedWidth / (length - 1); //两个点之间的x方向距离
      for (int i = 0; i < length; i++) {
        currentX = startX + W * i;
        currentY = chartBeans[i].y;
        if (currentX - W / 2 <= pointer.dx && pointer.dx <= currentX + W / 2) {
          pointer = _points[currentX];
          break;
        }
      }

      var hintLinePaint = new Paint()
        ..color = Colors.white
        ..isAntiAlias = true
        ..strokeWidth = 1;
      double radius = 4;
      canvas
        ..drawCircle(pointer, radius, hintLinePaint..strokeWidth = radius)
        ..drawLine(Offset(startX, pointer.dy), Offset(endX, pointer.dy),
            hintLinePaint..strokeWidth = 0.5)
        ..drawLine(
            Offset(pointer.dx, startY),
            Offset(pointer.dx, endY - basePadding),
            hintLinePaint..strokeWidth = 0.5);

      ///绘制文本
      var yValue = currentY.toStringAsFixed(isShowFloat ? 1 : 0);
      TextPainter(
          textAlign: TextAlign.center,
          ellipsis: '.',
          maxLines: 1,
          text: TextSpan(
              text: "$yValue",
              style: TextStyle(color: fontColor, fontSize: fontSize)),
          textDirection: TextDirection.ltr)
        ..layout(minWidth: 40, maxWidth: 40)
        ..paint(
            canvas,
            Offset(
                pointer.dx,
                startY - pointer.dy < basePadding * 2
                    ? pointer.dy - basePadding
                    : pointer.dy + radius * 2));
    } catch (e) {
      print(e.toString());
    }
  }

  ///手指长按移动位置更新回调
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails _moveUpdateDetails) {
    _isPressed = true;
    this._longPressMoveUpdateDetails = _moveUpdateDetails;
  }

  ///手指长按开始
  void onLongPressStart(LongPressStartDetails _longPressStartDetails) {
    _isPressed = true;
    this._longPressStartDetails = _longPressStartDetails;
  }

  ///手指长按结束
  void onLongPressUp() {
    _isPressed = false;
    this._longPressMoveUpdateDetails = null;
    this._longPressStartDetails = null;
  }
}
