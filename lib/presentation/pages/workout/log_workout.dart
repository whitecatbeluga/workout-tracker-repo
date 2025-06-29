import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';
import 'package:workout_tracker_repo/presentation/pages/exercises/add_exercise.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/log_exercise_card.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

import '../../../core/providers/workout_exercise_provider.dart';
import '../../domain/entities/set_entry.dart';

class LogWorkout extends StatefulWidget {
  const LogWorkout({super.key});

  @override
  State<LogWorkout> createState() => _LogWorkoutState();
}

class _LogWorkoutState extends State<LogWorkout> {
  // final Map<String, List<SetEntry>> exerciseSets = {};

  // final Map<String, List<SetEntry>> exerciseSets = savedExerciseSets;
  final Map<String, List<SetEntry>> exerciseSets = {};
  bool isTimerSelected = true;
  Duration timerDuration = const Duration(minutes: 1);
  Duration stopwatchDuration = Duration.zero;
  bool isRunning = false;
  late StateSetter dialogSetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeaderMetrics(),
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
        onPressed: Navigator.canPop(context)
            ? () => Navigator.pop(context)
            : () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
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
              Navigator.pushNamed(context, WorkoutRoutes.saveWorkout);
            },
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        Duration timerDuration = const Duration(minutes: 1);
                        bool isRunning = false;
                        late StateSetter dialogSetState;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            dialogSetState = setState;
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isTimerSelected
                                                  ? Color(0xFF006A71)
                                                  : Color(0xFFD9D9D9),
                                              padding: EdgeInsets.all(15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(6),
                                                  bottomLeft: Radius.circular(
                                                    6,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              dialogSetState(() {
                                                isTimerSelected = true;
                                                isRunning = false;
                                                timerDuration = const Duration(
                                                  minutes: 1,
                                                );
                                                stopwatchDuration =
                                                    Duration.zero;
                                              });
                                            },
                                            child: Text(
                                              'Timer',
                                              style: TextStyle(
                                                color: isTimerSelected
                                                    ? Colors.white
                                                    : Color(0xFF323232),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: !isTimerSelected
                                                  ? Color(0xFF006A71)
                                                  : Color(0xFFD9D9D9),
                                              padding: EdgeInsets.all(15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(6),
                                                  bottomRight: Radius.circular(
                                                    6,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              dialogSetState(() {
                                                isTimerSelected = false;
                                                isRunning = false;
                                                timerDuration = const Duration(
                                                  minutes: 1,
                                                );
                                                stopwatchDuration =
                                                    Duration.zero;
                                              });
                                            },
                                            child: Text(
                                              'Stopwatch',
                                              style: TextStyle(
                                                color: !isTimerSelected
                                                    ? Colors.white
                                                    : Color(0xFF323232),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Timer or Stopwatch Display
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          isTimerSelected
                                              ? '${timerDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timerDuration.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
                                              : '${stopwatchDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(stopwatchDuration.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // -15s and +15s only visible for Timer mode
                                    if (isTimerSelected)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              dialogSetState(() {
                                                timerDuration -= const Duration(
                                                  seconds: 15,
                                                );
                                                if (timerDuration.isNegative ||
                                                    timerDuration.inSeconds <
                                                        0) {
                                                  timerDuration = Duration.zero;
                                                }
                                              });
                                            },
                                            child: const Text(
                                              '-15s',
                                              style: TextStyle(
                                                color: Color(0xFF006A71),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              dialogSetState(() {
                                                timerDuration += const Duration(
                                                  seconds: 15,
                                                );
                                              });
                                            },
                                            child: const Text(
                                              '+15s',
                                              style: TextStyle(
                                                color: Color(0xFF006A71),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 20),

                                    Button(
                                      label: isRunning ? 'Cancel' : 'Start',
                                      fullWidth: true,
                                      variant: isRunning
                                          ? ButtonVariant.gray
                                          : ButtonVariant.primary,
                                      onPressed: () {
                                        if (isRunning) {
                                          dialogSetState(() {
                                            isRunning = false;
                                            timerDuration = const Duration(
                                              minutes: 1,
                                            );
                                            stopwatchDuration = Duration.zero;
                                          });
                                        } else {
                                          dialogSetState(() {
                                            isRunning = true;
                                          });

                                          Future.delayed(
                                            const Duration(seconds: 1),
                                            () async {
                                              while (isRunning) {
                                                await Future.delayed(
                                                  const Duration(seconds: 1),
                                                );
                                                dialogSetState(() {
                                                  if (isTimerSelected) {
                                                    timerDuration -=
                                                        const Duration(
                                                          seconds: 1,
                                                        );
                                                    if (timerDuration
                                                            .inSeconds <=
                                                        0) {
                                                      isRunning = false;
                                                      timerDuration =
                                                          const Duration(
                                                            minutes: 1,
                                                          );
                                                    }
                                                  } else {
                                                    stopwatchDuration +=
                                                        const Duration(
                                                          seconds: 1,
                                                        );
                                                  }
                                                });
                                              }
                                            },
                                          );
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
                  },
                  child: const Icon(Icons.timer, color: Color(0xFF000000)),
                ),

                SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildHeaderMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetric('Duration', '0s'),
        _buildMetric('Volume', '0kg'),
        _buildMetric('Sets', '0'),
      ],
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
                // child: TextButton(
                //   onPressed: () =>
                //       Navigator.pushNamed(context, AuthRoutes.home),
                //   style: TextButton.styleFrom(
                //     backgroundColor: Color(0xFFEEEEEE),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: Text('Cancel', style: TextStyle(color: Colors.black)),
                // ),
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
                // child: TextButton(
                //   onPressed: () {},
                //   style: TextButton.styleFrom(
                //     backgroundColor: Color(0xFFEEEEEE),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: Text(
                //     'Discard Workout',
                //     style: TextStyle(color: Color(0xFFDB141F)),
                //   ),
                // ),
                child: Button(
                  fontSize: 16,
                  label: 'Discard Workout',
                  fullWidth: true,
                  size: ButtonSize.large,
                  textColor: Color(0xFFDB141F),
                  fontWeight: FontWeight.w500,
                  variant: ButtonVariant.gray,
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRoutes.home),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
