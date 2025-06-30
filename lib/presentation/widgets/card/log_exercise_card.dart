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

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      SizedBox(width: 40, child: Text('Set')),
                      SizedBox(width: 80, child: Text('Previous')),
                      SizedBox(width: 70, child: Text('KG')),
                      SizedBox(width: 60, child: Text('Reps')),
                      SizedBox(width: 40, child: Icon(Icons.check)),
                    ],
                  ),
                  const Divider(),
                  Column(
                    children: sets.asMap().entries.map((entry) {
                      final setIndex = entry.key;
                      final set = entry.value;

                      return Dismissible(
                        key: UniqueKey(),
                        // ensures each Dismissible is truly unique
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          sets.removeAt(setIndex); // remove first
                          setState(() {
                            for (int i = 0; i < sets.length; i++) {
                              sets[i].setNumber = i + 1;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text('${set.setNumber}'),
                              ),
                              SizedBox(width: 80, child: Text(set.previous)),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: set.kg == 0
                                        ? ''
                                        : set.kg.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(),
                                    onChanged: (val) {
                                      setState(() {
                                        set.kg = double.tryParse(val) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: set.reps == 0
                                        ? ''
                                        : set.reps.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(),
                                    onChanged: (val) {
                                      setState(() {
                                        set.reps = int.tryParse(val) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: set.isCompleted,
                                onChanged: (val) {
                                  setState(() {
                                    set.isCompleted = val ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
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
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.deepPurple,
                      ),
                      label: const Text(
                        "Add Set",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
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
