import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';

class LogExerciseCard extends StatefulWidget {
  const LogExerciseCard({
    super.key,
    this.workoutExercises,
    this.routineExercises,
    required this.exerciseSets,
  });

  final ValueNotifier<List<Exercise>>? workoutExercises;
  final ValueNotifier<List<Exercise>>? routineExercises;
  final Map<String, List<SetEntry>> exerciseSets;

  @override
  State<LogExerciseCard> createState() => _LogExerciseCardState();
}

class _LogExerciseCardState extends State<LogExerciseCard> {
  @override
  Widget build(BuildContext context) {
    final activeNotifier = widget.workoutExercises ?? widget.routineExercises;

    if (activeNotifier == null) {
      return _buildEmptyState();
    }

    return ValueListenableBuilder<List<Exercise>>(
      valueListenable: activeNotifier,
      builder: (context, exercises, _) {
        if (exercises.isEmpty) return _buildEmptyState();

        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];

            widget.exerciseSets.putIfAbsent(
              exercise.name,
              () => [SetEntry(setNumber: 1, previous: "0kg x 0")],
            );

            final sets = widget.exerciseSets[exercise.name]!;

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
                                  initialValue: set.kg == 0
                                      ? ''
                                      : set.kg.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      set.kg = double.tryParse(val) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 50,
                                child: TextFormField(
                                  initialValue: set.reps == 0
                                      ? ''
                                      : set.reps.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      set.reps = int.tryParse(val) ?? 0;
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
}
