import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CarbonChartCard extends StatelessWidget {
  final List<double> values;
  final List<String> days;

  const CarbonChartCard({
    super.key,
    required this.values,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                  return Text(days[idx]);
                },
              ),
            ),
          ),
          barGroups: List.generate(values.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.green,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}