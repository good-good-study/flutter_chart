import 'dart:ui';

import 'package:flutter/material.dart';

class ChartPieBean {
  double value;
  String type;
  double rate;
  Color color;
  double startAngle;
  double sweepAngle;

  ChartPieBean(
      {@required this.value,
      this.type,
      this.rate,
      this.color,
      this.startAngle,
      this.sweepAngle});
}
