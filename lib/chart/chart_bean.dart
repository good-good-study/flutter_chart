import 'package:flutter/material.dart';

class ChartBean {
  String x;
  double y;
  int millisSeconds;
  Color color;

  ChartBean(
      {@required this.x, @required this.y, this.millisSeconds, this.color});
}
