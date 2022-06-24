import 'dart:math';

import 'package:example/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/chart/bar_chart.dart';
import 'package:flutter_chart/chart/common/axis_delegate.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/chart_gesture_view.dart';
import 'package:flutter_chart/chart/common/popup_spec.dart';
import 'package:flutter_chart/chart/impl/bar/bar_canvas_impl.dart';
import 'package:flutter_chart/chart/impl/bar/bar_layout_impl.dart';
import 'package:flutter_chart/chart/model/chart_data_bar.dart';
import 'package:intl/intl.dart';

/// 可拖动、长按 的 Charts
class DraggableBarChart extends StatefulWidget {
  const DraggableBarChart({Key? key}) : super(key: key);

  @override
  State<DraggableBarChart> createState() => _DraggableBarChartState();
}

class _DraggableBarChartState extends State<DraggableBarChart> {
  static const labels = ['', '离床', '清醒', '浅睡', '深睡', ''];

  /// 构建一个测试ModelBar
  static ChartDataBar _buildModelBar({
    required int index,
    Color? color,
    required int hour,
  }) {
    return ChartDataBar(
      index: index,
      color: color,
      time: 1655913600 + 3600 * hour,
      duration: 60 * 60,
      hasBubble: Random(hour).nextBool(),
    );
  }

  /// 数据源
  final data = [
    // 深睡
    _buildModelBar(index: 0, hour: 0, color: const Color(0xFF3E4590)),
    _buildModelBar(index: 0, hour: 1, color: const Color(0xFF3E4590)),
    _buildModelBar(index: 0, hour: 2, color: const Color(0xFF3E4590)),
    // 浅睡
    _buildModelBar(index: 1, color: const Color(0xFF9498C2), hour: 10),
    _buildModelBar(index: 1, color: const Color(0xFF9498C2), hour: 11),
    _buildModelBar(index: 1, color: const Color(0xFF9498C2), hour: 12),
    // 离床
    _buildModelBar(index: 3, hour: 3, color: const Color(0x26000000)),
    _buildModelBar(index: 3, hour: 4, color: const Color(0x26000000)),
    _buildModelBar(index: 3, hour: 5, color: const Color(0x26000000)),

    // 清醒
    _buildModelBar(index: 2, hour: 7),
    _buildModelBar(index: 0, hour: 8, color: const Color(0xFF3E4590)),
    _buildModelBar(index: 2, hour: 9),
    _buildModelBar(index: 3, hour: 11, color: const Color(0x26000000)),
  ];

  Size? size;
  final margin = const EdgeInsets.all(10);

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
      child: ChartGestureView<ChartDataBar>(
        initConfig: BarLayoutConfig(
          data: data,
          axisCount: 24,
          size: Size(pixel - margin.horizontal, 264),
          delegate: CommonBarAxisDelegate.copyWith(
            xAxisFormatter: _xAxisFormatter,
            yAxisFormatter: _yAxisFormatter,
            axisLineStyle: const LineStyle(
              color: Color(0xFFE5E5E5),
              dashPattern: [4],
            ),
            lineStyle: const LineStyle(
              strokeWidth: 2,
              color: Colors.deepPurple,
            ),
          ),
          popupSpec: CommonBarPopupSpec.copyWith(
            textFormatter: _textFormatter,
            popupShouldDraw: _popupShouldShow,
            bubbleShouldDraw: _popupBubbleShouldShow,
            lineStyle: const LineStyle(
              color: Colors.deepPurple,
              dashPattern: [2],
            ),
            fill: Colors.white,
            stroke: const Color(0x5CD2BFBF),
            strokeWidthPx: 2,
            bubbleSpec: const BubbleSpec(
              radius: 4.5,
              fill: Color(0xFFEE2828),
              strokeWidthPx: 2,
              stroke: Colors.white,
            ),
          ),
        ),
        builder: (_, newConfig) => CustomPaint(
          size: size!,
          painter: BarChart(
            data: data,
            contentCanvas: BarCanvasImpl(),
            layoutConfig: newConfig as BaseLayoutConfig<ChartDataBar>,
          ),
        ),
      ),
    );
  }

  /// 悬浮框内容
  InlineSpan _textFormatter(ChartDataBar data) {
    return TextSpan(
      text: '${DateFormat('HH:mm').format(
        DateTime.fromMillisecondsSinceEpoch((data.time + data.duration) * 1000),
      )}\n',
      style: const TextStyle(fontSize: 12, color: Colors.black),
      children: [
        const TextSpan(
          text: '夜间离床时间已超过',
          style: TextStyle(fontSize: 12, color: Colors.deepPurple),
        ),
        TextSpan(
          text: '${data.duration ~/ 60}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        const TextSpan(
          text: '分钟',
          style: TextStyle(fontSize: 12, color: Colors.deepPurple),
        ),
      ],
    );
  }

  /// x轴坐标数据格式化
  String _xAxisFormatter(ChartDataBar data) {
    return DateFormat("HH:mm").format(
      DateTime.fromMillisecondsSinceEpoch(data.time * 1000),
    );
  }

  /// y轴坐标数据格式化
  String _yAxisFormatter(num data, int index) {
    return labels[index];
  }

  /// 是否应该绘制此点位的悬浮框
  bool _popupShouldShow(ChartDataBar data) => data.hasBubble;

  /// 是否应该绘制此点位的气泡
  bool _popupBubbleShouldShow(ChartDataBar data) => data.hasBubble;
}
