import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('통계'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3, // 차트가 더 많은 공간을 차지하도록 설정
            child: PieChart(
              PieChartData(
                sections: showingSections(),
                centerSpaceRadius: 50,
                startDegreeOffset: 180,
                sectionsSpace: 0,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          Expanded(
            flex: 2, // 표가 차트보다 적은 공간을 차지하도록 설정
            child: Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Value (%)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ..._buildTableRows(), // 데이터 행 추가
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        value: 40,
        title: 'Category A',
        color: Color(0xFFFF5733), // Red
      ),
      PieChartSectionData(
        value: 25,
        title: 'Category B',
        color: Color(0xFF33FF57), // Green
      ),
      PieChartSectionData(
        value: 20,
        title: 'Category C',
        color: Color(0xFF3357FF), // Blue
      ),
      PieChartSectionData(
        value: 15,
        title: 'Category D',
        color: Color(0xFFFFC300), // Yellow
      ),
    ];
  }

  List<TableRow> _buildTableRows() {
    final categories = ['Category A', 'Category B', 'Category C', 'Category D'];
    final values = [40, 25, 20, 15];

    return List.generate(categories.length, (index) {
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(categories[index]),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${values[index]}%'),
          ),
        ],
      );
    });
  }
}
