import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/repositories_impl/workout_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/data/services/workout_service.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/entities/workout.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/filter_item.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/collapsible/bottomdrawer.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final user = authService.value.getCurrentUser();
  final workoutRepo = WorkoutRepositoryImpl(WorkoutService());
  final routineRepo = RoutineRepositoryImpl(RoutineService());
  late List<Workout> workouts = [];
  ValueNotifier<String> selectedWF = ValueNotifier('This Week');
  ValueNotifier<String> selectedVOT = ValueNotifier('This Week');

  void showWFFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BottomDrawer(
        filterItems: [
          FilterItem(
            title: 'This Week',
            onTap: () {
              selectedWF.value = 'This Week';
            },
            icon: Icons.today,
          ),
          FilterItem(
            title: 'Last Week',
            onTap: () {
              selectedWF.value = 'Last Week';
            },
            icon: Icons.calendar_month,
          ),
        ],
      ),
    );
  }

  void showVOTFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BottomDrawer(
        filterItems: [
          FilterItem(
            title: 'This Week',
            onTap: () {
              selectedVOT.value = 'This Week';
            },
            icon: Icons.today,
          ),
          FilterItem(
            title: 'Last Week',
            onTap: () {
              selectedVOT.value = 'Last Week';
            },
            icon: Icons.calendar_month,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: Navigator.canPop(context)
              ? () => Navigator.pop(context)
              : () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Statistics', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder(
          stream: workoutRepo.getWorkoutsByUserId(user!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return showLoader();
            }
            final workouts = snapshot.data ?? [];

            return StreamBuilder(
              stream: routineRepo.streamFolders(user!.uid),
              builder: (context, routinesnapshot) {
                if (!routinesnapshot.hasData) {
                  return showLoader();
                }
                List<String> userRoutineIds = [];
                if (routinesnapshot.hasData) {
                  for (var folder in routinesnapshot.data!) {
                    userRoutineIds.addAll(folder.routineIds!);
                  }
                }
                return StreamBuilder(
                  stream: routineRepo.getUserRoutinesByIds(userRoutineIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return showLoader();
                    }
                    final routines = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWorkoutFrequencySection(workouts, routines),
                        const SizedBox(height: 15),

                        _buildWorkoutSummarySection(workouts),
                        const SizedBox(height: 15),

                        _buildVolumeOverTimeSection(workouts),
                        const SizedBox(height: 15),

                        _buildRoutineUsageStatsSection(routines),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Column showLoader() {
    return Column(
      spacing: 15,
      children: [
        SkeletonLoader(),
        SkeletonLoader(),
        SkeletonLoader(),
        SkeletonLoader(),
      ],
    );
  }

  Widget _buildWorkoutFrequencySection(
    List<Workout> workouts,
    List<Routine> routines,
  ) {
    print('\x1B[2J\x1B[1;1H');
    DateTime startOfThisWeek = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    DateTime endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));
    DateTime startOfLastWeek = startOfThisWeek.subtract(
      const Duration(days: 7),
    );
    DateTime endOfLastWeek = startOfThisWeek.subtract(const Duration(days: 1));
    int thisWeekCount = 0;
    int lastWeekCount = 0;
    for (var workout in workouts) {
      final routineDate = workout.createdAt;
      bool isInRange =
          !routineDate.isBefore(startOfThisWeek) &&
          !routineDate.isAfter(endOfThisWeek);
      if (isInRange) {
        thisWeekCount++;
      }
      bool isInRange2 =
          !routineDate.isBefore(startOfLastWeek) &&
          !routineDate.isAfter(endOfLastWeek);
      if (isInRange2) {
        lastWeekCount++;
      }
    }

    int thisRoutineWeekCount = 0;
    int lastRoutineWeekCount = 0;
    for (var routine in routines) {
      final routineDate = DateTime.parse(routine.createdAt!);
      bool isInRange =
          !routineDate.isBefore(startOfThisWeek) &&
          !routineDate.isAfter(endOfThisWeek);
      if (isInRange) {
        thisRoutineWeekCount++;
      }
      bool isInRange2 =
          !routineDate.isBefore(startOfLastWeek) &&
          !routineDate.isAfter(endOfLastWeek);
      if (isInRange2) {
        lastRoutineWeekCount++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ValueListenableBuilder(
        valueListenable: selectedWF,
        builder: (context, value, child) {
          final isThisWeek = value == 'This Week';

          final routineLabel = isThisWeek
              ? 'This week'
              : 'Last week → This week';
          final workoutLabel = isThisWeek
              ? 'This week'
              : 'Last week → This week';

          final routineChange = routineLabel == 'This week'
              ? thisRoutineWeekCount - lastRoutineWeekCount
              : lastRoutineWeekCount - thisRoutineWeekCount;
          final workoutChange = workoutLabel == 'This week'
              ? thisWeekCount - lastWeekCount
              : lastWeekCount - thisWeekCount;
          final workoutCount = workoutLabel == 'This week'
              ? thisWeekCount
              : lastWeekCount;
          final routineCount = routineLabel == 'This week'
              ? thisRoutineWeekCount
              : lastRoutineWeekCount;
          print('Last week: $lastWeekCount');
          print('This Week $thisWeekCount');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Workout Frequency',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Button(
                    label: selectedWF.value,
                    onPressed: () => showWFFilter(context),
                    backgroundColor: Colors.white,
                    textColor: Color(0xFF006A71),
                    suffixIcon: Icons.arrow_downward,
                    fontSize: 14,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFrequencyCard(
                      routineLabel,
                      routineCount.toString(),
                      'routine${thisRoutineWeekCount > 1 ? 's' : ''}',
                      routineChange,
                      routineChange > 0 ? Colors.teal : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFrequencyCard(
                      workoutLabel,
                      workoutCount.toString(),
                      'workout${thisWeekCount > 1 ? 's' : ''}',
                      workoutChange,
                      workoutChange > 0 ? Colors.teal : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFrequencyCard(
    String period,
    String number,
    String type,
    int change,
    Color changeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                type,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _statIndicator(
                  icon: changeColor == Colors.teal
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  value: change.toString(),
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummarySection(List<Workout> workouts) {
    int totalWorkouts = workouts.length;
    int totalVolume = workouts.fold(
      0,
      (sum, workout) => sum + (workout.volume?.toInt() ?? 0),
    );
    int totalDuration = workouts.fold(
      0,
      (sum, workout) => sum + (workout.duration),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular Progress Chart
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: int.parse(DateTime.now().month.toString()) / 12,
                        strokeWidth: 17,
                        backgroundColor: Color(
                          0xFF006A71,
                        ).withAlpha((0.2 * 255).round()),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF006A71),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006A71),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(
                      'Total Workouts:',
                      "$totalWorkouts ${totalWorkouts == 1 ? 'workout' : 'workouts'}",
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Total Duration:',
                      "${(totalDuration / 60).toStringAsFixed(1)} minutes",
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total Volume:', "$totalVolume kg"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVolumeOverTimeSection(List<Workout> workouts) {
    DateTime startOfThisWeek = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    DateTime endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));
    DateTime startOfLastWeek = startOfThisWeek.subtract(
      const Duration(days: 7),
    );
    DateTime endOfLastWeek = startOfThisWeek.subtract(const Duration(days: 1));

    // int totalKgThisWeek = 0;
    int totalSetsThisWeek = 0;
    // int totalKgLastWeek = 0;
    int totalSetsLastWeek = 0;
    for (var workout in workouts) {
      final routineDate = workout.createdAt;
      bool isInRange =
          !routineDate.isBefore(startOfThisWeek) &&
          !routineDate.isAfter(endOfThisWeek);
      if (isInRange) {
        // print(workout);
        // totalKgThisWeek += (workout.volume ?? 0);
        totalSetsThisWeek += (workout.sets ?? 0);
      }
      bool isInRange2 =
          !routineDate.isBefore(startOfLastWeek) &&
          !routineDate.isAfter(endOfLastWeek);
      if (isInRange2) {
        // totalKgLastWeek += (workout.volume ?? 0);
        totalSetsLastWeek += (workout.sets ?? 0);
      }
    }

    double thisWeekRepCount = 0;
    double lastWeekRepCount = 0;

    for (var workout in workouts) {
      final workoutDate = workout.createdAt;
      for (var exercise in workout.exercises!) {
        for (var set in exercise['sets']) {
          bool isInRange =
              !workoutDate.isBefore(startOfThisWeek) &&
              !workoutDate.isAfter(endOfThisWeek);
          if (isInRange) {
            // print(workout);
            thisWeekRepCount += (set['reps'] ?? 0);
          }
          bool isInRange2 =
              !workoutDate.isBefore(startOfLastWeek) &&
              !workoutDate.isAfter(endOfLastWeek);
          if (isInRange2) {
            lastWeekRepCount += (set['reps'] ?? 0);
          }
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ValueListenableBuilder(
        valueListenable: selectedVOT,
        builder: (context, value, child) {
          final isThisWeek = selectedVOT.value == 'This Week';
          final totalKg = isThisWeek ? thisWeekRepCount : lastWeekRepCount;
          final kgChange = isThisWeek
              ? thisWeekRepCount - lastWeekRepCount
              : lastWeekRepCount - thisWeekRepCount;

          final totalSets = isThisWeek ? totalSetsThisWeek : totalSetsLastWeek;
          final setChange = isThisWeek
              ? totalSetsThisWeek - totalSetsLastWeek
              : totalSetsLastWeek - totalSetsThisWeek;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Volume over time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Button(
                    label: selectedVOT.value,
                    onPressed: () => showVOTFilter(context),
                    backgroundColor: Colors.white,
                    textColor: Color(0xFF006A71),
                    suffixIcon: Icons.arrow_downward,
                    fontSize: 14,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildVolumeCard(
                      'Total Reps',
                      totalKg.toInt().toString(),
                      'rep${totalKg <= 1 ? '' : 's'}',
                      kgChange.toInt(),
                      kgChange > 0 ? Colors.teal : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVolumeCard(
                      'Weight Lifted',
                      totalKg.toInt().toString(),
                      'kg',
                      kgChange.toInt(),
                      kgChange > 0 ? Colors.teal : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVolumeCard(
                      'Total Sets',
                      '$totalSets',
                      'sets',
                      setChange,
                      setChange > 0 ? Colors.teal : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVolumeCard(
    String title,
    String value,
    String unit,
    int change,
    Color changeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: changeColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _statIndicator(
              icon: changeColor == Colors.teal
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              value: change < 0 ? (-change).toString() : change.toString(),
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statIndicator({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineUsageStatsSection(List<Routine> routines) {
    List<String> exercises = [];
    List<Map<String, dynamic>> originalList = [];
    for (var routine in routines) {
      print(routine);
      for (var exercise in routine.exercises) {
        exercises.add(exercise.name);
        originalList.add({
          'exerciseName': exercise.name,
          'createdAt': routine.createdAt,
        });
      }
    }
    Map<String, dynamic> exerciseCount = {};

    for (var entry in originalList) {
      String exerciseName = entry['exerciseName'];
      DateTime createdAt = DateTime.parse(entry['createdAt']);
      if (exerciseCount.containsKey(exerciseName)) {
        if (exerciseCount[exerciseName]['createdAt'].isBefore(createdAt)) {
          exerciseCount[exerciseName]['createdAt'] = createdAt;
        }
        exerciseCount[exerciseName]['count'] =
            exerciseCount[exerciseName]['count'] + 1;
      } else {
        exerciseCount[exerciseName] = {'count': 1, 'createdAt': createdAt};
      }
    }

    List<Map<String, dynamic>> countedList = exerciseCount.entries.map((entry) {
      return {
        'exerciseName': entry.key,
        'count': entry.value['count'],
        'createdAt': DateFormat('MMM d, yyyy').format(entry.value['createdAt']),
      };
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Routine usage stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Top Used Routine Exercises',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 0.1),
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Exercise Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Time Used',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Last Used',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Data Rows
          if (countedList.isNotEmpty)
            ...countedList.map(
              (e) => _buildRoutineRow(
                e['exerciseName'],
                e['count'].toString(),
                e['createdAt'],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoutineRow(
    String routineName,
    String timeUsed,
    String lastUsed,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              routineName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(timeUsed, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              lastUsed,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSkeletonCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildSkeletonCard()),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildSkeletonCard() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 14,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 24,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    ),
  );
}
