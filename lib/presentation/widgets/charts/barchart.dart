import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/domain/entities/workout.dart';

class BarChartWidget extends StatefulWidget {
  final String filter;
  final List<Workout> workouts;

  const BarChartWidget({
    super.key,
    this.filter = 'Week',
    required this.workouts,
  });

  @override
  BarChartWidgetState createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  final List<WeekStats> weekStats = [];
  final List<MonthStat> monthStats = [];
  final weekConst = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final monthConst = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    processDates(widget.workouts);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,

      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: widget.filter == 'Week' ? 10 : 30,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toString(),
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String title = widget.filter == 'Week'
                      ? weekConst[value.toInt()]
                      : monthConst[value.toInt()];
                  TextStyle style = const TextStyle(fontSize: 11);
                  if (widget.filter == 'Week' &&
                      DateTime.now().weekday == value.toInt() + 1) {
                    style = const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006A71),
                    );
                  } else if (widget.filter == 'Month' &&
                      DateTime.now().month == value.toInt() + 1) {
                    style = const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006A71),
                    );
                  }
                  return Text(title, style: style);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: widget.filter == 'Week' ? 2 : 5,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            if (widget.filter == 'Week') ...[
              for (var i = 0; i < weekStats.length; i++)
                makeGroupData(i, weekStats[i].count.toDouble()),
            ],
            if (widget.filter == 'Month') ...[
              for (var i = 0; i < monthStats.length; i++)
                makeGroupData(i, monthStats[i].count.toDouble()),
            ],
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Color(0xFF006A71),
          width: 26,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  void processDates(List<Workout> workouts) {
    // Process the dates of the fetched workouts
    final workoutDates = workouts
        .map(
          (workout) =>
              "${workout.createdAt.year}-${workout.createdAt.month}-${workout.createdAt.day}",
        )
        .toList();
    // Get the dates for the current week
    final now = DateTime.now();
    final weekDates = List.generate(7, (index) {
      final date = now.add(Duration(days: index - now.weekday + 1));
      return "${date.year}-${date.month}-${date.day}";
    }).toList();

    //add weekDates to weekStats
    for (var date in weekDates) {
      final count = workoutDates.where((element) => element == date).length;
      weekStats.add(WeekStats(day: date, count: count));
    }

    //convert weekStat from 2025-6-16 to Mon example
    for (var date in weekStats) {
      date.day = weekConst[weekDates.indexOf(date.day)];
    }

    //add monthConst to monthStats
    for (var month in monthConst) {
      final count = workoutDates
          .where(
            (element) =>
                element.split('-')[1] ==
                (monthConst.indexOf(month) + 1).toString(),
          )
          .length;
      monthStats.add(MonthStat(month: month, count: count));
    }

    // print('WORKOUT DATES : $workoutDates');
    // print('MONTH STATS : $monthStats');
  }
}

class WeekStats {
  String day;
  final int count;

  WeekStats({required this.day, required this.count});

  @override
  String toString() {
    return 'WeekStats(day: $day, count: $count)';
  }
}

class MonthStat {
  String month;
  final int count;

  MonthStat({required this.month, required this.count});

  @override
  String toString() {
    return 'MonthStat(month: $month, count: $count)';
  }
}
