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
  static int hour(int hour) => 1655913600 + 3600 * hour;

  /// 数据源
  final data = [
    // ChartDataModel(xAxis: hour(0), yAxis: 2),
    // ChartDataModel(xAxis: hour(1), yAxis: 64),
    // ChartDataModel(xAxis: hour(2), yAxis: 60),
    // ChartDataModel(xAxis: hour(3), yAxis: 40),
    // ChartDataModel(xAxis: hour(3) + 60 * 10, yAxis: 42),
    // ChartDataModel(xAxis: hour(3) + 60 * 20, yAxis: 42),
    // ChartDataModel(xAxis: hour(3) + 60 * 30, yAxis: 40),
    // ChartDataModel(xAxis: hour(3) + 60 * 45, yAxis: 44),
    // ChartDataModel(xAxis: hour(3) + 60 * 50, yAxis: 46),
    // ChartDataModel(xAxis: hour(4), yAxis: 48),
    // ChartDataModel(xAxis: hour(5), yAxis: 46),
    // ChartDataModel(xAxis: hour(5) + 60 * 5, yAxis: 44),
    // ChartDataModel(xAxis: hour(5) + 60 * 25, yAxis: 42),
    // ChartDataModel(xAxis: hour(5) + 60 * 35, yAxis: 42),
    // ChartDataModel(xAxis: hour(5) + 60 * 40, yAxis: 40),
    // ChartDataModel(xAxis: hour(5) + 60 * 47, yAxis: 38),
    // ChartDataModel(xAxis: hour(6), yAxis: 32),
    // ChartDataModel(xAxis: hour(7), yAxis: 44),
    // ChartDataModel(xAxis: hour(8), yAxis: 40),
    // ChartDataModel(xAxis: hour(9), yAxis: 88),
    // ChartDataModel(xAxis: hour(10), yAxis: 40),
    // ChartDataModel(xAxis: hour(11), yAxis: 0),
    ChartDataModel(xAxis: hour(12), yAxis: 0),
    ChartDataModel(xAxis: hour(12) + 60 * 10, yAxis: 1),
    ChartDataModel(xAxis: hour(12) + 60 * 20, yAxis: 2),
    ChartDataModel(xAxis: hour(12) + 60 * 30, yAxis: 3),
    ChartDataModel(xAxis: hour(12) + 60 * 40, yAxis: 4),
    ChartDataModel(xAxis: hour(12) + 60 * 50, yAxis: 5),
    ChartDataModel(xAxis: hour(13), yAxis: 0),
    ChartDataModel(xAxis: hour(14), yAxis: 19),
    ChartDataModel(xAxis: hour(15), yAxis: 0),
    ChartDataModel(xAxis: hour(16), yAxis: 39),
    ChartDataModel(xAxis: hour(17), yAxis: 10),
    ChartDataModel(xAxis: hour(18), yAxis: 0),
    ChartDataModel(xAxis: hour(19), yAxis: 100),
    ChartDataModel(xAxis: hour(20), yAxis: 0),
    ChartDataModel(xAxis: hour(21), yAxis: 0),
    ChartDataModel(xAxis: hour(22), yAxis: 0),
    ChartDataModel(xAxis: hour(23), yAxis: 0),
  ];

  Size? size;
  final margin = const EdgeInsets.symmetric(horizontal: 10);

  /// x轴开始时间
  static final now = DateTime.now();
  var startDate = DateTime(now.year, now.month, now.day, 12);

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
          ),
          popupSpec: CommonPopupSpec.copyWith(
            textFormatter: _textFormatter,
            // popupShouldDraw: _popupShouldShow,
            // bubbleShouldDraw: _popupBubbleShouldShow,
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
    var xAxis = DateFormat('HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(data.xAxis * 1000));

    /// 是否为异常数据
    var normalValue = 60;
    bool isException = data.yAxis > normalValue;
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
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
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
}
