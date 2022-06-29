import 'dart:math';

import 'package:example/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/chart/line_chart.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/chart_gesture_view.dart';
import 'package:flutter_chart/chart/impl/line/line_canvas_impl.dart';
import 'package:flutter_chart/chart/impl/line/line_layout_impl.dart';
import 'package:flutter_chart/chart/model/chart_data_model.dart';
import 'package:intl/intl.dart';

/// 拖拽&长按 的 Charts,横坐标依据数据长度而定。
/// 适合排列场景：07-1 、07-02、07-03、07-04...
/// 即：每个x轴刻度间的距离相同，x轴刻度之间只允许绘制一个点。
class DraggableLineChart extends StatefulWidget {
  const DraggableLineChart({Key? key}) : super(key: key);

  @override
  State<DraggableLineChart> createState() => _DraggableLineChartState();
}

class _DraggableLineChartState extends State<DraggableLineChart> {
  static DateTime hour({int hour = 0}) {
    var milliseconds = (1656302400 + 3600 * hour) * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// 数据源
  final data = [
    ChartDataModel(
      xAxis: hour(hour: 0),
      yAxis: 0,
      hasBubble: Random(0).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 1),
      yAxis: 1,
      hasBubble: Random(1).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 2),
      yAxis: 9,
      hasBubble: Random(2).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 3),
      yAxis: 11,
      hasBubble: Random(3).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 4),
      yAxis: 56,
      hasBubble: Random(4).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 5),
      yAxis: 100,
      hasBubble: Random(5).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 6),
      yAxis: 88,
      hasBubble: Random(6).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 7),
      yAxis: 33,
      hasBubble: Random(7).nextBool(),
    ),
    ChartDataModel(xAxis: hour(hour: 8), yAxis: 55),
    ChartDataModel(xAxis: hour(hour: 9), yAxis: 77),
    ChartDataModel(xAxis: hour(hour: 10), yAxis: 34),
    ChartDataModel(xAxis: hour(hour: 11), yAxis: 2),
    ChartDataModel(xAxis: hour(hour: 12), yAxis: 7),
  ];

  Size? size;
  final margin = const EdgeInsets.symmetric(horizontal: 10);

  @override
  Widget build(BuildContext context) {
    var pixel = MediaQuery.of(context).size.width;
    size ??= Size(pixel, 264);
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ChartGestureView<ChartDataModel>(
        initConfig: LineLayoutConfig(
          data: data,
          size: Size(pixel - margin.horizontal, 264),
          delegate: CommonLineAxisDelegate.copyWith(
            xAxisFormatter: _xAxisFormatter,
            yAxisFormatter: _yAxisFormatter,
            lineStyle: CommonLineAxisDelegate.lineStyle?.copyWith(
              color: Colors.green,
            ),
          ),
          popupSpec: CommonPopupSpec.copyWith(
            textFormatter: _textFormatter,
            // popupShouldDraw: _popupShouldShow,
            // bubbleShouldDraw: _popupBubbleShouldShow,
            lineStyle: CommonPopupSpec.lineStyle?.copyWith(
              color: Colors.lightGreen,
            ),
          ),
        ),
        builder: (_, newConfig) => CustomPaint(
          size: size!,
          painter: LineChart(
            data: data,
            contentCanvas: LineCanvasImpl(),
            layoutConfig: newConfig as BaseLayoutConfig<ChartDataModel>,
          ),
        ),
      ),
    );
  }

  /// 悬浮框内容
  InlineSpan _textFormatter(ChartDataModel data) {
    var xAxis = DateFormat('HH:mm').format(data.xAxis);

    /// 是否为异常数据
    var normalValue = 20;
    bool isException = data.yAxis > normalValue;
    Color color = isException ? Colors.red : Colors.black;
    return TextSpan(
      text: '$xAxis\n',
      style: const TextStyle(fontSize: 12, color: Colors.black),
      children: [
        TextSpan(
          text: isException ? '气温：大于' : '气温: ',
          style: TextStyle(fontSize: 12, color: color),
        ),
        TextSpan(
          text: isException ? normalValue.toString() : '${data.yAxis.toInt()}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextSpan(
          text: '°c',
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }

  /// x轴坐标数据格式化
  String _xAxisFormatter(int index) {
    return DateFormat('HH:mm').format(data[index].xAxis);
  }

  /// y轴坐标数据格式化
  String _yAxisFormatter(num data, int index) {
    return data.toInt().toString();
  }
}
