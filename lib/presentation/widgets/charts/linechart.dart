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

  // Simple method to calculate interval based on range
  double _calculateInterval(double range, bool isWeight) {
    if (range <= 2) {
      return 0.5;
    } else if (range <= 5) {
      return 1.0;
    } else if (range <= 10) {
      return 2.0;
    } else if (range <= 20) {
      return showWeight ? 2.0 : 5.0;
    } else if (range <= 50) {
      return 5.0;
    } else if (range <= 100) {
      return 10.0;
    } else {
      return 20.0;
    }
  }

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

    // Get min and max values
    final double dataMin = yValues.reduce((a, b) => a < b ? a : b);
    final double dataMax = yValues.reduce((a, b) => a > b ? a : b);
    final double range = dataMax - dataMin;

    // Calculate interval based on range
    double interval = _calculateInterval(range, showWeight);

    // Set bounds with some padding
    final double minY = (dataMin - interval).floorToDouble();
    final double maxY = (dataMax + interval).ceilToDouble();
    ;

    print('\x1B[2J\x1B[1;1H');
    print('Range: $range');
    print('Interval: $interval');
    print('minY: $minY, maxY: $maxY');

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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 114, 114, 114),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Increased to accommodate larger numbers
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      value.toStringAsFixed(0) + (showWeight ? ' kg' : ' cm'),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color.fromARGB(255, 114, 114, 114),
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval:
                interval, // Ensure grid lines match the title intervals
          ),
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
