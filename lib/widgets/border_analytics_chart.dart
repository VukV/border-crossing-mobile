import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:border_crossing_mobile/models/border/border_analytics.dart';

class BorderAnalyticsChart extends StatelessWidget {
  final List<AverageByHour> averageByHour;

  const BorderAnalyticsChart({
    super.key,
    required this.averageByHour,
  });

  @override
  Widget build(BuildContext context) {
    if (averageByHour.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    // Get the min and max values for X and Y axis dynamically
    final minX = averageByHour.map((data) => data.hourOfDay).reduce((a, b) => a < b ? a : b).toDouble();
    final maxX = averageByHour.map((data) => data.hourOfDay).reduce((a, b) => a > b ? a : b).toDouble();

    final minY = averageByHour.map((data) => data.averageDuration).reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = averageByHour.map((data) => data.averageDuration).reduce((a, b) => a > b ? a : b).toDouble();

    // Calculate intervals dynamically to avoid label overcrowding
    final xInterval = ((maxX - minX) / 6).ceilToDouble();
    final yInterval = ((maxY - minY) / 6).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LineChart(
        _buildChartData(minX, maxX, minY, maxY, xInterval, yInterval),
      ),
    );
  }

  LineChartData _buildChartData(double minX, double maxX, double minY, double maxY, double xInterval, double yInterval) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: yInterval,
        verticalInterval: xInterval,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: xInterval,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  '${value.toInt()}:00',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()} min',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[600]!),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: averageByHour
              .map((data) => FlSpot(data.hourOfDay.toDouble(), data.averageDuration.toDouble()))
              .toList(),
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.deepPurple.withOpacity(0.3), Colors.purple.withOpacity(0.3)],
            ),
          ),
        ),
      ],
    );
  }
}
