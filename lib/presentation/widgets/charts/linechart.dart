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

    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data'));
    }

    /// -------------------- Y-Axis Scaling Logic --------------------
    double maxY = dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double minY = dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    bool isPrime(int n) {
      if (n <= 1) return false;
      for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return false;
      }
      return true;
    }

    // Pad maxY slightly if it's prime for better tick division
    while (isPrime(maxY.toInt())) {
      maxY += 1;
    }

    // Determine interval
    double interval = (maxY / 9).ceilToDouble();
    while (maxY % interval != 0) {
      interval += 1;
    }

    // Recalculate maxY as next divisible value
    maxY = (interval * (maxY / interval).ceil()).toDouble();

    // Ensure minY starts from 0 or just below the minimum, rounded nicely
    minY = (minY / interval).floor() * interval;
    if (minY < 0) minY = 0;

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: -0.5,
          maxX: (dataPoints.length - 1) + 0.5,
          minY: minY - interval < 0 ? 0 : minY - interval,
          maxY: maxY + interval,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();

                  if (value != index.toDouble() ||
                      index < 0 ||
                      index >= dates.length) {
                    return const SizedBox();
                  }

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
                reservedSize: 55,
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
          gridData: FlGridData(show: true, horizontalInterval: interval),
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
