import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker_repo/domain/entities/measurement.dart';

class LinechartWidget extends StatelessWidget {
  final List<Measurement> measurements;
  final bool showWeight; // true = weight, false = height
  const LinechartWidget({
    super.key,
    required this.showWeight,
    required this.measurements,
  });
  @override
  Widget build(BuildContext context) {
    final List<FlSpot> dataPoints = measurements.map((e) {
      final index = measurements.indexOf(e);
      return FlSpot(
        index.toDouble(),
        showWeight ? e.weight.toDouble() : e.height.toDouble(),
      );
    }).toList();

    final List<DateTime> dates = measurements.map((e) => e.date).toList();

    // Extract all y-values from dataPoints
    final yValues = dataPoints.map((e) => e.y).toList();

    // Get dynamic min and max Y values with a buffer
    final double minY = (yValues.reduce((a, b) => a < b ? a : b) - 1)
        .floorToDouble();
    final double maxY = (yValues.reduce((a, b) => a > b ? a : b) + 1)
        .ceilToDouble();

    // Decide a dynamic interval (simplified logic)
    // double range = maxY - minY;
    // double interval = showWeight ? 1.0 : 5.0; // Use whole numbers for weight

    // if (range > 50) {
    //   interval = 10.0;
    // } else if (range > 20) {
    //   interval = showWeight ? 4.0 : 5.0;
    // } else if (range > 10) {
    //   interval = showWeight ? 2.0 : 2.0;
    // } else {
    //   interval = showWeight ? 2.0 : 2.0; // Always use 1.0 for small ranges
    // }
    // print('\x1B[2J\x1B[1;1H');
    // print('minY: $minY, maxY: $maxY, range: $range, interval: $interval');

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: -0.5,
          maxX: (dataPoints.length - 1) + 0.5,
          minY: minY,
          maxY: maxY,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();

                  // Only show titles for exact integer values that correspond to our data points
                  if (value != index.toDouble() ||
                      index < 0 ||
                      index >= dates.length) {
                    return const SizedBox();
                  }

                  // Optional: Skip some labels if there are too many data points
                  if (dataPoints.length > 6 && index % 2 != 0) {
                    return const SizedBox();
                  }

                  String formatted = DateFormat('MMM d').format(dates[index]);
                  return SideTitleWidget(
                    meta: meta,
                    space: 12,
                    child: Text(
                      formatted,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 29,
                // interval: interval,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              color: Colors.teal,
              barWidth: 2,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: true),
              spots: dataPoints,
            ),
          ],
        ),
      ),
    );
  }
}
