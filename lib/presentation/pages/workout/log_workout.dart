import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/presentation/pages/exercises/add_exercise.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/log_exercise_card.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

import '../../../core/providers/workout_exercise_provider.dart';

class LogWorkout extends StatefulWidget {
  const LogWorkout({super.key});

  @override
  State<LogWorkout> createState() => _LogWorkoutState();
}

class _LogWorkoutState extends State<LogWorkout> {
  // final Map<String, List<SetEntry>> exerciseSets = {};

  // final Map<String, List<SetEntry>> exerciseSets = savedExerciseSets;
  final Map<String, List<SetEntry>> exerciseSets = {};

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
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '${timerDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timerDuration.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Button(
                                      label: 'Start',
                                      fullWidth: true,
                                      onPressed: isRunning
                                          ? null
                                          : () {
                                              dialogSetState(() {
                                                isRunning = true;
                                              });

                                              Future.delayed(
                                                const Duration(seconds: 1),
                                                () async {
                                                  while (timerDuration
                                                              .inSeconds >
                                                          0 &&
                                                      isRunning) {
                                                    await Future.delayed(
                                                      const Duration(
                                                        seconds: 1,
                                                      ),
                                                    );
                                                    dialogSetState(() {
                                                      timerDuration -=
                                                          const Duration(
                                                            seconds: 1,
                                                          );
                                                    });
                                                  }
                                                  if (timerDuration.inSeconds ==
                                                      0) {
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                              );
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
