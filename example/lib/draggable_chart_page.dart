import 'package:example/draggable_line_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        child: Column(
          children: const [
            SizedBox(height: 24),

            /// Fixed Line Chart
            DraggableLineChart(),

            SizedBox(height: 8),

            /// Line Chart
            FixedDraggableLineChart(),

            // SizedBox(height: 24),

            /// bar Chart
            FixedDraggableBarChart(),
          ],
        ),
      ),
    );
  }
}
