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
  final Map<String, List<TextEditingController>> _kgControllers = {};
  final Map<String, List<TextEditingController>> _repControllers = {};

  @override
  void dispose() {
    for (final controllers in _kgControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    for (final controllers in _repControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

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

            _kgControllers.putIfAbsent(
              exercise.name,
              () => List.generate(
                sets.length,
                (i) => TextEditingController(
                  text: sets[i].kg == 0 ? '' : sets[i].kg.toString(),
                ),
              ),
            );

            _repControllers.putIfAbsent(
              exercise.name,
              () => List.generate(
                sets.length,
                (i) => TextEditingController(
                  text: sets[i].reps == 0 ? '' : sets[i].reps.toString(),
                ),
              ),
            );

            while (_kgControllers[exercise.name]!.length < sets.length) {
              final i = _kgControllers[exercise.name]!.length;
              _kgControllers[exercise.name]!.add(
                TextEditingController(
                  text: sets[i].kg == 0 ? '' : sets[i].kg.toString(),
                ),
              );
              _repControllers[exercise.name]!.add(
                TextEditingController(
                  text: sets[i].reps == 0 ? '' : sets[i].reps.toString(),
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
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
                  Row(
                    children: [
                      if (exercise.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            exercise.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        )
                      else
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      SizedBox(width: 40, child: Text('Set')),
                      SizedBox(width: 80, child: Text('Previous')),
                      SizedBox(width: 70, child: Text('KG')),
                      SizedBox(width: 60, child: Text('Reps')),
                      SizedBox(width: 65, child: Icon(Icons.check)),
                    ],
                  ),
                  const Divider(),
                  Column(
                    children: sets.asMap().entries.map((entry) {
                      final setIndex = entry.key;
                      final set = entry.value;

                      final kgController =
                          _kgControllers[exercise.name]![setIndex];
                      final repController =
                          _repControllers[exercise.name]![setIndex];

                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            sets.removeAt(setIndex);
                            _kgControllers[exercise.name]!.removeAt(setIndex);
                            _repControllers[exercise.name]!.removeAt(setIndex);
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
                                    controller: kgController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: _inputDecoration(),
                                    onChanged: (val) {
                                      set.kg = double.tryParse(val) ?? 0;
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    controller: repController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(),
                                    onChanged: (val) {
                                      set.reps = int.tryParse(val) ?? 0;
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
                          final newSet = SetEntry(
                            setNumber: sets.length + 1,
                            previous: "0kg x 0",
                          );
                          sets.add(newSet);
                          _kgControllers[exercise.name]!.add(
                            TextEditingController(text: ''),
                          );
                          _repControllers[exercise.name]!.add(
                            TextEditingController(text: ''),
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
