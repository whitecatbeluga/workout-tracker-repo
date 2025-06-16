import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

import '../../../core/providers/workout_exercise_provider.dart';

class SetEntry {
  final int setNumber;
  final String previous;
  double kg;
  int reps;
  bool isCompleted;

  SetEntry({
    required this.setNumber,
    required this.previous,
    this.kg = 0,
    this.reps = 0,
    this.isCompleted = false,
  });
}

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
              child: ValueListenableBuilder<List<Exercise>>(
                valueListenable: workoutExercises,
                builder: (context, exercises, _) {
                  if (exercises.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];

                      exerciseSets.putIfAbsent(
                        exercise.name,
                        () => [SetEntry(setNumber: 1, previous: "0kg x 0")],
                      );

                      final sets = exerciseSets[exercise.name]!;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DataTable(
                                columnSpacing: 12,
                                columns: const [
                                  DataColumn(label: Text('Set')),
                                  DataColumn(label: Text('Previous')),
                                  DataColumn(label: Text('KG')),
                                  DataColumn(label: Text('Reps')),
                                  DataColumn(label: Icon(Icons.check)),
                                ],
                                rows: sets.map((set) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${set.setNumber}')),
                                      DataCell(Text(set.previous)),
                                      DataCell(
                                        SizedBox(
                                          width: 50,
                                          child: TextFormField(
                                            initialValue: set.kg.toString(),
                                            keyboardType: TextInputType.number,
                                            onChanged: (val) {
                                              setState(() {
                                                set.kg =
                                                    double.tryParse(val) ?? 0;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 50,
                                          child: TextFormField(
                                            initialValue: set.reps.toString(),
                                            keyboardType: TextInputType.number,
                                            onChanged: (val) {
                                              setState(() {
                                                set.reps =
                                                    int.tryParse(val) ?? 0;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Checkbox(
                                          value: set.isCompleted,
                                          onChanged: (val) {
                                            setState(() {
                                              set.isCompleted = val ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      sets.add(
                                        SetEntry(
                                          setNumber: sets.length + 1,
                                          previous: "0kg x 0",
                                        ),
                                      );
                                    });
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text("Add Set"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF323232)),
        onPressed: () => Navigator.pushNamed(context, AuthRoutes.home),
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
                Icon(Icons.timer, color: Color(0xFF000000)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.fitness_center_rounded,
            size: 90.0,
            color: Color(0xFF626262),
          ),
          SizedBox(height: 10.0),
          Text(
            'Get Started',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5.0),
          Text(
            'Get started by adding an exercise to your routine.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            onPressed: () =>
                Navigator.pushNamed(context, WorkoutRoutes.addWorkoutExercise),
            variant: ButtonVariant.secondary,
            fullWidth: true,
          ),
          SizedBox(height: 5.0),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRoutes.home),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Discard Workout',
                    style: TextStyle(color: Color(0xFFDB141F)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
