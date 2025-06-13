// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample2 extends StatelessWidget {
  final List<double> monthlyIncome;

  BarChartSample2({required this.monthlyIncome});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getMonthName(value.toInt()),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toInt()}k',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8.0),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(12, (index) {
      return _buildBar(index + 1, monthlyIncome[index]);
    });
  }

  BarChartGroupData _buildBar(int monthIndex, double value) {
    return BarChartGroupData(
      x: monthIndex,
      barRods: [
        BarChartRodData(
          toY: value,
          gradient: LinearGradient(
            colors: const [
              Color(0xFF8A2387),
              Color(0xFFE94057),
              Color(0xFFF27121)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          width: 16.0,
          borderRadius: BorderRadius.zero,
        ),
      ],
    );
  }

  String _getMonthName(int monthIndex) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return monthNames[monthIndex - 1]; // Adjust for zero-based index
  }
}
