import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';
import 'package:workout_tracker_repo/presentation/pages/exercises/add_exercise.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/log_exercise_card.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

import '../../../core/providers/workout_exercise_provider.dart';
import '../../../providers/persistent_duration_provider.dart';
import '../../../providers/persistent_volume_set_provider.dart';
import '../../../utils/timer_formatter.dart';

class LogWorkout extends ConsumerStatefulWidget {
  const LogWorkout({super.key});

  @override
  ConsumerState<LogWorkout> createState() => _LogWorkoutState();
}

class _LogWorkoutState extends ConsumerState<LogWorkout> {
  final Map<String, List<SetEntry>> exerciseSets = {};
  late Timer _workoutDurationTimer;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();

    if (savedExerciseSets.isNotEmpty) {
      exerciseSets.addAll(savedExerciseSets);
    }

    // Timer for workout elapsed duration
    _workoutDurationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentDuration = ref.read(workoutElapsedDurationProvider);
      ref.read(workoutElapsedDurationProvider.notifier).state =
          currentDuration + Duration(seconds: 1);
    });
  }

  @override
  void dispose() {
    _workoutDurationTimer.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final timerNotifier = ref.read(timerProvider.notifier);
      final timerState = ref.read(timerProvider);

      if (!timerState.isRunning) {
        timer.cancel();
        return;
      }

      if (timerState.isTimerSelected) {
        // Countdown timer
        if (timerState.timerDuration.inSeconds > 0) {
          timerNotifier.setTimerDuration(
            Duration(seconds: timerState.timerDuration.inSeconds - 1),
          );
        } else {
          // Timer finished
          timerNotifier.setRunning(false);
          timerNotifier.resetTimer();
          // You can add notification/sound here
        }
      } else {
        // Stopwatch
        timerNotifier.addStopwatchSecond();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutDuration = ref.watch(workoutElapsedDurationProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeaderMetrics(workoutDuration),
            SizedBox(height: 20.0),
            Expanded(
              child: LogExerciseCard(
                workoutExercises: workoutExercises,
                exerciseSets: exerciseSets,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: BackButton(
        onPressed: () {
          savedExerciseSets
            ..clear()
            ..addAll(exerciseSets);

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Log Workout', style: TextStyle(fontSize: 20)),
          GestureDetector(
            onTap: () {
              savedExerciseSets
                ..clear()
                ..addAll(exerciseSets);
              Navigator.pushNamed(
                context,
                WorkoutRoutes.saveWorkout,
                arguments: exerciseSets,
              );
            },
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showClockDialog(context),
                  child: const Icon(Icons.timer, color: Color(0xFF000000)),
                ),
                SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF48A6A7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  void _showClockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final timerState = ref.watch(timerProvider);
            final timerNotifier = ref.read(timerProvider.notifier);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Center(
                child: Text(
                  'Clock',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: SizedBox(
                width: 500,
                height: 350,
                child: Column(
                  children: [
                    // Timer/Stopwatch Toggle
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: timerState.isTimerSelected
                                  ? Color(0xFF006A71)
                                  : Color(0xFFD9D9D9),
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                              ),
                            ),
                            onPressed: () {
                              timerNotifier.setTimerSelected(true);
                            },
                            child: Text(
                              'Timer',
                              style: TextStyle(
                                color: timerState.isTimerSelected
                                    ? Colors.white
                                    : Color(0xFF323232),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !timerState.isTimerSelected
                                  ? Color(0xFF006A71)
                                  : Color(0xFFD9D9D9),
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                              ),
                            ),
                            onPressed: () {
                              timerNotifier.setTimerSelected(false);
                            },
                            child: Text(
                              'Stopwatch',
                              style: TextStyle(
                                color: !timerState.isTimerSelected
                                    ? Colors.white
                                    : Color(0xFF323232),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Time Display
                    Expanded(
                      child: Center(
                        child: Text(
                          timerState.isTimerSelected
                              ? '${timerState.timerDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timerState.timerDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                              : '${timerState.stopwatchDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timerState.stopwatchDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Timer Controls (only show for timer mode)
                    if (timerState.isTimerSelected)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              timerNotifier.addTimerSeconds(-15);
                            },
                            child: const Text(
                              '-15s',
                              style: TextStyle(color: Color(0xFF006A71)),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              timerNotifier.addTimerSeconds(15);
                            },
                            child: const Text(
                              '+15s',
                              style: TextStyle(color: Color(0xFF006A71)),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Start/Cancel Button
                    Button(
                      label: timerState.isRunning ? 'Cancel' : 'Start',
                      fullWidth: true,
                      variant: timerState.isRunning
                          ? ButtonVariant.gray
                          : ButtonVariant.primary,
                      onPressed: () {
                        if (timerState.isRunning) {
                          timerNotifier.setRunning(false);
                          timerNotifier.resetTimer();
                          _clockTimer?.cancel();
                        } else {
                          timerNotifier.setRunning(true);
                          _startClockTimer();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openDismissWorkoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                Text(
                  "Are you sure you want to dismiss this workout?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Column(
                  spacing: 10,
                  children: [
                    Button(
                      label: "Dismiss Workout",
                      prefixIcon: Icons.delete_forever,
                      backgroundColor: Colors.white,
                      textColor: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                      fullWidth: true,
                      onPressed: () {
                        // Clear exercises and sets
                        workoutExercises.value.clear();
                        savedExerciseSets.clear();

                        // Reset timer
                        ref
                                .read(workoutElapsedDurationProvider.notifier)
                                .state =
                            Duration.zero;
                        _workoutDurationTimer.cancel();

                        // Reset volume and sets
                        ref.read(volumeSetProvider.notifier).reset();

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AuthRoutes.home,
                          (route) => false,
                        );
                      },
                    ),
                    Button(
                      label: 'Cancel',
                      textColor: Color(0xFF323232),
                      fullWidth: true,
                      variant: ButtonVariant.gray,
                      fontWeight: FontWeight.w500,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderMetrics(Duration workoutDuration) {
    return Consumer(
      builder: (context, ref, child) {
        final volumeSetState = ref.watch(volumeSetProvider);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetric('Duration', formatDuration(workoutDuration.inSeconds)),
            _buildMetric('Volume', '${volumeSetState.totalVolume.round()}'),
            _buildMetric('Sets', volumeSetState.totalSets.toString()),
          ],
        );
      },
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Color(0xFF626262))),
        SizedBox(height: 5.0),
        Text(value, style: TextStyle(fontSize: 16, color: Color(0xFF000000))),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button(
            label: 'Add Exercise',
            prefixIcon: Icons.add,
            onPressed: () => Navigator.pushNamed(
              context,
              ExerciseRoutes.addWorkoutExercise,
              arguments: AddExerciseArguments(isLogWorkout: true),
            ),
            variant: ButtonVariant.secondary,
            fullWidth: true,
            size: ButtonSize.large,
          ),
          SizedBox(height: 5.0),
          Row(
            children: [
              Expanded(
                child: Button(
                  fontSize: 16,
                  label: 'Cancel',
                  fullWidth: true,
                  size: ButtonSize.large,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w500,
                  variant: ButtonVariant.gray,
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRoutes.home),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Button(
                  fontSize: 16,
                  label: 'Discard Workout',
                  fullWidth: true,
                  size: ButtonSize.large,
                  textColor: Color(0xFFDB141F),
                  fontWeight: FontWeight.w500,
                  variant: ButtonVariant.gray,
                  onPressed: () => _openDismissWorkoutDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
