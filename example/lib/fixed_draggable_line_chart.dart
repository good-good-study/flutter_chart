import 'dart:math';

import 'package:example/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/chart/line_chart.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/chart_gesture_view.dart';
import 'package:flutter_chart/chart/impl/line/fixed_line_canvas_impl.dart';
import 'package:flutter_chart/chart/impl/line/fixed_line_layout_impl.dart';
import 'package:flutter_chart/chart/model/chart_data_model.dart';
import 'package:intl/intl.dart';

/// 可拖动、长按 的 Charts
/// 横坐标固定为0点到24点
/// 每个点是根据时间时长所绘制。
/// 即：两个坐标刻度之间，可以存在多个子节点。
class FixedDraggableLineChart extends StatefulWidget {
  const FixedDraggableLineChart({Key? key}) : super(key: key);

  @override
  State<FixedDraggableLineChart> createState() =>
      _FixedDraggableLineChartState();
}

class _FixedDraggableLineChartState extends State<FixedDraggableLineChart> {
  static DateTime hour({int hour = 0, int duration = 0}) {
    var milliseconds = (1656302400 + 3600 * hour + duration) * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// 数据源
  final data = [
    ChartDataModel(
      xAxis: hour(hour: 0),
      yAxis: 0,
      hasBubble: Random(0).nextBool(),
    ),
    ChartDataModel(xAxis: hour(hour: 0, duration: 60 * 10), yAxis: 1),
    ChartDataModel(xAxis: hour(hour: 0, duration: 60 * 20), yAxis: 1),
    ChartDataModel(xAxis: hour(hour: 0, duration: 60 * 30), yAxis: 1),
    ChartDataModel(xAxis: hour(hour: 0, duration: 60 * 40), yAxis: 1),
    ChartDataModel(xAxis: hour(hour: 0, duration: 60 * 50), yAxis: 1),
    ChartDataModel(
      xAxis: hour(hour: 1),
      yAxis: 1,
      hasBubble: Random(1).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 2),
      yAxis: 98,
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
    ChartDataModel(xAxis: hour(hour: 6), yAxis: 88),
    ChartDataModel(
      xAxis: hour(hour: 7),
      yAxis: 33,
      hasBubble: Random(7).nextBool(),
    ),
    ChartDataModel(
      xAxis: hour(hour: 8),
      yAxis: 55,
      hasBubble: Random(8).nextBool(),
    ),
    ChartDataModel(xAxis: hour(hour: 9), yAxis: 77),
    ChartDataModel(
      xAxis: hour(hour: 10),
      yAxis: 34,
      hasBubble: Random(10).nextBool(),
    ),
    ChartDataModel(xAxis: hour(hour: 11), yAxis: 2),
    ChartDataModel(xAxis: hour(hour: 12), yAxis: 7),
  ];

  Size? size;
  final margin = const EdgeInsets.symmetric(horizontal: 10);

  /// x轴开始时间
  var startDate = DateTime.fromMillisecondsSinceEpoch(1656302400 * 1000);

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
        initConfig: FixedLayoutConfig(
          data: data,
          axisCount: 25,
          startDateTime: startDate,
          size: Size(pixel - margin.horizontal, 264),
          delegate: CommonLineAxisDelegate.copyWith(
            yAxisFormatter: _yAxisFormatter,
            minSelectWidth: 4,
            // domainPointSpacing: 128,
          ),
          popupSpec: CommonPopupSpec.copyWith(
            textFormatter: _textFormatter,
            // popupShouldDraw: _popupShouldShow,
            bubbleShouldDraw: _popupBubbleShouldShow,
          ),
        ),
        builder: (_, newConfig) => CustomPaint(
          size: size!,
          painter: LineChart(
            data: data,
            contentCanvas: FixedLineCanvasImpl(),
            layoutConfig: newConfig as BaseLayoutConfig<ChartDataModel>,
          ),
        ),
      ),
    );
  }

  /// 悬浮框内容
  InlineSpan _textFormatter(ChartDataModel data) {
    var xAxis = DateFormat('MM-dd HH:mm').format(data.xAxis);

    /// 是否为异常数据
    var normalValue = 60;
    bool isException = data.hasBubble;
    Color color = isException ? Colors.red : Colors.black;
    return TextSpan(
      text: '$xAxis\n',
      style: const TextStyle(fontSize: 12, color: Colors.black),
      children: [
        TextSpan(
          text: isException ? '心率异常: 大于' : '心率: ',
          style: TextStyle(fontSize: 12, color: color),
        ),
        TextSpan(
          text: isException ? normalValue.toString() : '${data.yAxis.toInt()}',
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextSpan(
          text: ' 次/分钟',
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  /// y轴坐标数据格式化
  String _yAxisFormatter(num data, int index) {
    return data.toInt().toString();
  }

  /// 是否显示气泡
  bool _popupBubbleShouldShow(ChartDataModel data) => data.hasBubble;
}
