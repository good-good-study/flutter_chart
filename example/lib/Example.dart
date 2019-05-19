import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chart/chart/chart_pie_bean.dart';
import 'package:flutter_chart/chart/view/chart_pie.dart';
import 'package:flutter_chart/flutter_chart.dart';

///Demo : how to use Chart
class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExampleChart(),
    );
  }
}

class ExampleChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Colors.black..withOpacity(0)),
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              AnnotatedRegion(
                value: SystemUiOverlayStyle.light
                    .copyWith(statusBarBrightness: Brightness.dark),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    _buildChartLine(context),
                    SizedBox(
                      height: 8,
                    ),
                    _buildChartBar(context),
                    SizedBox(
                      height: 8,
                    ),
                    _buildChartPie(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ///curve or line
  Widget _buildChartLine(context) {
    var chartLine = ChartLine(
      chartBeans: [
        ChartBean(x: '12-01', y: 30),
        ChartBean(x: '12-02', y: 88),
        ChartBean(x: '12-06', y: 20),
        ChartBean(x: '12-06', y: 67),
        ChartBean(x: '12-06', y: 10),
        ChartBean(x: '12-06', y: 40),
        ChartBean(x: '12-06', y: 10),
      ],
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height / 5 * 1.6),
      isCurve: true,
      lineWidth: 6,
      lineColor: Colors.deepPurple,
      fontColor: Colors.white,
      xyColor: Colors.white,
      shaderColors: [Colors.yellow, Colors.lightGreenAccent, Colors.blue],
      fontSize: 12,
      yNum: 8,
      backgroundColor: Colors.black,
      isAnimation: true,
      duration: Duration(milliseconds: 3000),
    );

    return chartLine;
  }

  ///bar
  ChartBar _buildChartBar(context) {
    return ChartBar(
      chartBeans: [
        ChartBean(x: '12-01', y: 30, color: Colors.red),
        ChartBean(x: '12-02', y: 100, color: Colors.yellow),
        ChartBean(x: '12-03', y: 70, color: Colors.green),
        ChartBean(x: '12-04', y: 70, color: Colors.blue),
        ChartBean(x: '12-05', y: 30, color: Colors.deepPurple),
        ChartBean(x: '12-06', y: 90, color: Colors.deepOrange),
        ChartBean(x: '12-07', y: 50, color: Colors.greenAccent)
      ],
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height / 5 * 1.8),
      rectColor: Colors.deepPurple,
      backgroundColor: Colors.black,
      isShowX: true,
      fontColor: Colors.white,
    );
  }

  ///pie
  ChartPie _buildChartPie(context) {
    return ChartPie(
      chartBeans: [
        ChartPieBean(type: '话费', value: 30, color: Colors.blueGrey),
        ChartPieBean(type: '零食', value: 120, color: Colors.deepPurple),
        ChartPieBean(type: '衣服', value: 60, color: Colors.green),
        ChartPieBean(type: '早餐', value: 60, color: Colors.blue),
        ChartPieBean(type: '水果', value: 30, color: Colors.red),
      ],
      size: Size(
          MediaQuery.of(context).size.width, MediaQuery.of(context).size.width),
      backgroundColor: Colors.black,
      R: MediaQuery.of(context).size.width /3,
      centerR: 6,
      duration: Duration(milliseconds: 3000),
      isCycle: true,
      centerColor: Colors.white,
      fontColor: Colors.white,
    );
  }
}