/// Chart 数据源
class ChartDataModel implements Comparable<ChartDataModel> {
  final int xAxis; // x轴数据
  final double yAxis; // y轴数据

  const ChartDataModel({required this.yAxis, required this.xAxis});

  @override
  String toString() {
    return '{"xAxis":"$xAxis","yAxis":"$yAxis}"}';
  }

  @override
  int compareTo(ChartDataModel other) => xAxis.compareTo(other.xAxis);
}
