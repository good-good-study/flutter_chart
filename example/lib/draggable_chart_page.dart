import 'package:example/draggable_line_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'draggable_bar_chart.dart';
import 'fixed_draggable_bar_chart.dart';
import 'fixed_draggable_line_chart.dart';

class DraggableChartPage extends StatelessWidget {
  const DraggableChartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: '返回',
        middle: Text(
          'Charts',
          style: TextStyle(fontSize: 17, color: Colors.black),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Material(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),

              /// Line Chart
              _title('Line Chart'),
              DraggableLineChart(),

              SizedBox(height: 8),

              /// Fixed Line Chart
              _title('Fixed Line Chart'),
              FixedDraggableLineChart(),

              SizedBox(height: 8),

              /// bar Chart
              _title('Bar Chart'),
              DraggableBarChart(),

              /// bar Chart
              _title('Fixed Bar Chart'),
              FixedDraggableBarChart(),
            ],
          ),
        ),
      ),
    );
  }

  Padding _title(String label) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        label,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }
}
