import 'package:flutter/material.dart';

/// 白天行动轨迹、深浅睡眠
class ChartDataBar implements Comparable<ChartDataBar> {
  /// 对应与y轴刻度的索引
  final int index;

  /// 开始时间
  final DateTime time;

  /// 持续时长
  final int duration;

  /// 填充色
  final Color color;

  /// 是否有气泡点
  final bool hasBubble;

  const ChartDataBar({
    required this.index,
    required this.time,
    required this.duration,
    Color? color,
    bool? hasBubble,
  })  : color = color ?? Colors.transparent,
        hasBubble = hasBubble ?? false;

  @override
  int compareTo(ChartDataBar other) => time.compareTo(other.time);

  @override
  String toString() {
    return '{"index":"$index","time":"$time","duration":"$duration","hasBubble":"$hasBubble","color":"$color"}';
  }
}
