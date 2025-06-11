import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/calendar_workoutdata.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/calendar_workout_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final List<CalendarWorkoutDates> workoutDates = [];
  late Map<String, List<DateTime>> grouped;
  late List<String> sortedKeys;
  late int initialPage;
  late final PageController _pageController;
  bool isInitialized = false;
  bool isLoading = false;
  bool _showWorkoutModal = false;
  Map<String, dynamic> selectedWorkout = {'date': '', 'workout': ''};

  @override
  void initState() {
    super.initState();
    initializeCalendar();
  }

  @override
  void dispose() {
    _pageController.dispose(); // clean up the PageController
    super.dispose();
  }

  void _toggleWorkoutModal() {
    setState(() {
      _showWorkoutModal = !_showWorkoutModal;
    });
  }

  Future<void> fetchWorkoutDates() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading

    //SAMPLE DATA ONLY
    workoutDates.addAll([
      CalendarWorkoutDates(
        date: DateTime(2025, 6, 9, 8, 0),
        workouts: [
          UserWorkout(
            id: '1',
            title: 'Cardio Day',
            duration: '45 mins',
            volume: '80 kg',
            sets: '4',
            createdAt: DateTime(2025, 6, 11, 7, 0).toString(),
          ),
          UserWorkout(
            id: '2',
            title: 'Leg Day',
            duration: '40 mins',
            volume: '80 kg',
            sets: '3',
            createdAt: DateTime(2025, 6, 11, 8, 0).toString(),
          ),
          UserWorkout(
            id: '3',
            title: 'Back Day',
            duration: '40 mins',
            volume: '30 kg',
            sets: '3',
            createdAt: DateTime(2025, 6, 11, 9, 0).toString(),
          ),
        ],
        images: [
          'https://static.nike.com/a/images/f_auto/dpr_3.0,cs_srgb/h_363,c_limit/e88291f0-bc7b-4eae-b8ae-8fdedb43e9c9/should-i-run-before-or-after-a-strength-workout-%C2%A0.jpg',
        ],
      ),
      CalendarWorkoutDates(
        date: DateTime(2025, 6, 11, 9, 0),
        workouts: [
          UserWorkout(
            id: '1',
            title: 'Chest Day',
            duration: '45 mins',
            volume: '69 kg',
            sets: '4',
            createdAt: DateTime(2025, 6, 11, 9, 0).toString(),
          ),
          UserWorkout(
            id: '2',
            title: 'Shoulder Day',
            duration: '40 mins',
            volume: '23 kg',
            sets: '3',
            createdAt: DateTime(2025, 6, 11, 10, 0).toString(),
          ),
        ],
        images: [],
      ),
    ]);
  }

  Future<void> initializeCalendar() async {
    setState(() => isLoading = true);

    try {
      await fetchWorkoutDates(); // Wait until data is fetched
      // Now process the dates
      grouped = <String, List<DateTime>>{};
      for (var date in workoutDates.map((date) => date.date)) {
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
        grouped.putIfAbsent(key, () => []).add(date);
      }

      final now = DateTime.now();
      final currentKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      if (!grouped.containsKey(currentKey)) {
        grouped[currentKey] = [];
      }

      final workoutMonths = <int>[];
      for (var dates in grouped.values) {
        for (var date in dates) {
          if (!workoutMonths.contains(date.month)) {
            workoutMonths.add(date.month);
          }
        }
      }
      workoutMonths.sort();

      if (workoutMonths.isNotEmpty) {
        int earliestMonth = workoutMonths.first;
        int latestMonth = workoutMonths.last;

        for (var month = earliestMonth; month <= latestMonth; month++) {
          final key =
              "${DateTime.now().year}-${month.toString().padLeft(2, '0')}";
          grouped.putIfAbsent(key, () => []);
        }
      }

      sortedKeys = grouped.keys.toList()..sort();
      initialPage = sortedKeys.indexOf(currentKey);
      _pageController = PageController(initialPage: initialPage);
    } catch (e) {
      // print('Initialization error: $e');
    } finally {
      setState(() {
        isInitialized = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Calendar',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
          ),
          body: isLoading || !isInitialized
              ? _buildBackdropLoader()
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildStreakSection(),
                    const SizedBox(height: 24),
                    _buildCalendarSection(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              final previousPage = (_pageController.page! - 1)
                                  .toInt();
                              if (previousPage >= 0) {
                                _pageController.animateToPage(
                                  previousPage,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: _calendarNavigatorButton(
                              '',
                              Colors.black,
                              Icons.arrow_back_ios,
                              Colors.black,
                              true,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _pageController.animateToPage(
                                initialPage,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF006A71),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Today'),
                          ),
                          TextButton(
                            onPressed: () {
                              final nextPage = (_pageController.page! + 1)
                                  .toInt();
                              if (nextPage < grouped.keys.length) {
                                _pageController.animateToPage(
                                  nextPage,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: _calendarNavigatorButton(
                              '',
                              Colors.black,
                              Icons.arrow_forward_ios,
                              Colors.black,
                              false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        _buildViewWorkoutDayModal(
          isVisible: _showWorkoutModal,
          onClose: _toggleWorkoutModal,
        ),
      ],
    );
  }

  Widget _calendarNavigatorButton(
    String label,
    Color labelColor,
    IconData icon,
    Color iconColor,
    bool isIconStart,
  ) {
    return Row(
      children: [
        isIconStart
            ? Icon(icon, color: iconColor)
            : Text(label, style: TextStyle(color: labelColor)),
        isIconStart
            ? Text(label, style: TextStyle(color: labelColor))
            : Icon(icon, color: iconColor),
      ],
    );
  }

  Widget _buildStreakSection() {
    int streak = _calculateStreak();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.3 * 255).round()),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: _buildStreakAndRestCard(
                '$streak',
                streak >= 2 ? 'Weeks' : 'Week',
                'Streak',
                Icons.local_fire_department,
                Colors.red,
                Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.3 * 255).round()),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: _buildStreakAndRestCard(
                '6',
                'Days',
                'Rest',
                Icons.nightlight_round,
                Colors.teal,
                const Color.fromARGB(255, 4, 83, 75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int getWeekOfYear(DateTime date) {
    int firstDayOfYear = DateTime(date.year, 1, 1).weekday;
    int weekOfYear =
        (date.difference(DateTime(date.year, 1, 1)).inDays +
                firstDayOfYear -
                1) ~/
            7 +
        1;
    return weekOfYear;
  }

  int _calculateStreak() {
    if (workoutDates.isEmpty) return 0;
    // Group workout dates by week of year
    Set<String> weeksWithWorkouts = {};
    for (DateTime date in workoutDates.map((date) => date.date)) {
      int weekNumber = getWeekOfYear(date);
      String weekKey = "${date.year}-$weekNumber";
      weeksWithWorkouts.add(weekKey);
    }

    DateTime now = DateTime.now();
    int currentWeek = getWeekOfYear(now);
    int currentYear = now.year;

    String currentWeekKey = "$currentYear-$currentWeek";
    bool currentWeekHasWorkout = weeksWithWorkouts.contains(currentWeekKey);

    int streak = 0; // Count intervals, not weeks

    if (currentWeekHasWorkout) {
      // Current week has workout, start checking from current week
      int week = currentWeek;
      int year = currentYear;

      // Check consecutive weeks going backwards
      while (week >= 1) {
        String weekKey = "$year-$week";
        if (weeksWithWorkouts.contains(weekKey)) {
          // Check if next week (going backwards) also has workout
          int nextWeek = week - 1;
          int nextYear = year;

          // Handle year boundary
          if (nextWeek < 1) {
            nextYear--;
            nextWeek = 52;
          }

          String nextWeekKey = "$nextYear-$nextWeek";
          if (weeksWithWorkouts.contains(nextWeekKey)) {
            streak++; // Found an interval (consecutive weeks)
            week = nextWeek;
            year = nextYear;
          } else {
            break; // No more consecutive weeks
          }
        } else {
          break;
        }
      }
    } else {
      // Current week has no workout, check previous week
      int week = currentWeek - 1;
      int year = currentYear;

      // Handle year boundary for previous week check
      if (week < 1) {
        year--;
        week = 52;
      }

      String previousWeekKey = "$year-$week";

      if (!weeksWithWorkouts.contains(previousWeekKey)) {
        // Previous week also has no workout, streak is 0
        return 0;
      }

      // Previous week has workout, start counting intervals from there
      while (week >= 1) {
        String weekKey = "$year-$week";
        if (weeksWithWorkouts.contains(weekKey)) {
          // Check if next week (going backwards) also has workout
          int nextWeek = week - 1;
          int nextYear = year;

          // Handle year boundary
          if (nextWeek < 1) {
            nextYear--;
            nextWeek = 52;
          }

          String nextWeekKey = "$nextYear-$nextWeek";
          if (weeksWithWorkouts.contains(nextWeekKey)) {
            streak++; // Found an interval (consecutive weeks)
            week = nextWeek;
            year = nextYear;
          } else {
            break; // No more consecutive weeks
          }
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Widget _buildStreakAndRestCard(
    String value,
    String unit,
    String subtitle,
    IconData icon,
    Color color1,
    Color color2,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value $unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return SizedBox(
      height: 380,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 30),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.3 * 255).round()),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: PageView.builder(
          controller: _pageController,
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final key = sortedKeys[index];
            final parts = key.split('-');
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final monthWorkouts = grouped[key]!;

            return _buildMonthCalendar(
              month: month,
              year: year,
              workoutDates: monthWorkouts,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthCalendar({
    required int month,
    required int year,
    required List<DateTime> workoutDates,
  }) {
    final List<List<String>> weeks = [];
    DateTime firstDay = DateTime(year, month, 1);
    int daysInMonth = DateTime(year, month + 1, 0).day;
    int weekDayOffset = firstDay.weekday % 7;

    List<String> week = List.generate(weekDayOffset, (_) => '');

    for (int day = 1; day <= daysInMonth; day++) {
      week.add(day.toString());
      if (week.length == 7) {
        weeks.add(week);
        week = [];
      }
    }

    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add('');
      }
      weeks.add(week);
    }

    final workoutDays = workoutDates.map((d) => d.day.toString()).toList();
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_monthName(month)} $year",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDaysHeader(),
        const SizedBox(height: 8),
        ...weeks.map((week) {
          return Row(
            children: week.map((day) {
              bool isWorkoutDay = workoutDays.contains(day);
              bool isToday =
                  day.isNotEmpty &&
                  today.day == int.parse(day) &&
                  today.month == month &&
                  today.year == year;

              return Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (isWorkoutDay) {
                          setState(() {
                            selectedWorkout['date'] =
                                '${_monthName(month)} $day, $year, ';
                            final match = this.workoutDates.firstWhere(
                              (element) =>
                                  element.date.year == year &&
                                  element.date.month == month &&
                                  element.date.day == int.parse(day),
                              orElse: () => CalendarWorkoutDates(
                                date: DateTime(year, month, int.parse(day)),
                                workouts: [],
                                images: [],
                              ),
                            );
                            selectedWorkout['workout'] = match.workouts;
                          });
                          _toggleWorkoutModal();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "No workout scheduled for this day.",
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // ADD IMAGE HERE
                          image:
                              isWorkoutDay &&
                                  this.workoutDates.any(
                                    (element) =>
                                        element.date ==
                                            DateTime(
                                              year,
                                              month,
                                              int.parse(day),
                                            ) &&
                                        element.images.isNotEmpty,
                                  )
                              ? DecorationImage(
                                  image: NetworkImage(
                                    this.workoutDates
                                        .firstWhere(
                                          (element) =>
                                              element.date ==
                                              DateTime(
                                                year,
                                                month,
                                                int.parse(day),
                                              ),
                                        )
                                        .images
                                        .first,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: isWorkoutDay
                              ? const Color(0xFFD86227)
                              : Colors.transparent,
                        ),

                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (isToday && isWorkoutDay)
                                      ? Colors.white
                                      : (isToday && !isWorkoutDay)
                                      ? Colors.black
                                      : (isWorkoutDay && !isToday)
                                      ? Colors.white
                                      : Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              if (isToday)
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  height: 1,
                                  width: 15,
                                  color: isWorkoutDay
                                      ? Colors.white
                                      : Colors.black,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildDaysHeader() {
    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Row(
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatWorkoutTime(String createdAtString) {
    try {
      DateTime dateTime = DateTime.parse(createdAtString);
      return TimeOfDay.fromDateTime(dateTime).format(context);
    } catch (e) {
      return createdAtString; // fallback to original string if parsing fails
    }
  }

  Widget _buildBackdropLoader() {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.white),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildViewWorkoutDayModal({
    required bool isVisible,
    required VoidCallback onClose,
  }) {
    return isVisible
        ? Stack(
            children: [
              ModalBarrier(
                dismissible: true,
                color: Colors.black.withAlpha(150),
                onDismiss: () {
                  onClose();
                },
              ),
              Center(
                child: Container(
                  height: 600, // Fixed height for uniformity
                  width: 380, // Fixed width
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.15 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fixed Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha((0.1 * 255).round()),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Workout Details',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: onClose,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedWorkout['date'].toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: Column(
                            children: [
                              ...selectedWorkout['workout'].map(
                                (workout) => WorkoutCard(
                                  title: workout.title,
                                  time: workout.duration,
                                  volume: workout.volume,
                                  sets: workout.sets,
                                  description: '',
                                  reminderText:
                                      'You got your workout done by ${_formatWorkoutTime(workout.createdAt)}',
                                  elevation: 1,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}
