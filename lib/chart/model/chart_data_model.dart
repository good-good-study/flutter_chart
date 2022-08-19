/// Chart 数据源
class ChartDataModel implements Comparable<ChartDataModel> {
  final double yAxis; // y轴数据
  /// 时间
  final DateTime xAxis; // x轴数据,单位是秒，时间戳
  /// 是否有气泡点
  final bool hasBubble;

  const ChartDataModel({
    required this.yAxis,
    required this.xAxis,
    this.hasBubble = false,
  });

  @override
  int compareTo(ChartDataModel other) => xAxis.compareTo(other.xAxis);

  @override
  String toString() {
    return '{"xAxis":"$xAxis","yAxis":$yAxis,"hasBubble":$hasBubble}';
  }
}