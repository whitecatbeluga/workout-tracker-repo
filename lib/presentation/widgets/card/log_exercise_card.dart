import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';

import '../../../providers/persistent_volume_set_provider.dart';

class LogExerciseCard extends ConsumerStatefulWidget {
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
  ConsumerState<LogExerciseCard> createState() => _LogExerciseCardState();
}

class _LogExerciseCardState extends ConsumerState<LogExerciseCard> {
  final Map<String, List<TextEditingController>> _kgControllers = {};
  final Map<String, List<TextEditingController>> _repControllers = {};
  final Map<String, List<FocusNode>> _kgFocusNodes = {};
  final Map<String, List<FocusNode>> _repFocusNodes = {};

  @override
  void dispose() {
    // Dispose all controllers
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

    // Dispose all focus nodes
    for (final focusNodes in _kgFocusNodes.values) {
      for (final focusNode in focusNodes) {
        focusNode.dispose();
      }
    }
    for (final focusNodes in _repFocusNodes.values) {
      for (final focusNode in focusNodes) {
        focusNode.dispose();
      }
    }
    super.dispose();
  }

  void _updateVolumeAndSets(String exerciseId) {
    final sets = widget.exerciseSets[exerciseId] ?? [];
    final completedSets = sets.where((set) => set.isCompleted).toList();
    ref
        .read(volumeSetProvider.notifier)
        .updateVolume(exerciseId, completedSets);
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
        if (exercises.isEmpty) {
          _kgControllers.clear();
          _repControllers.clear();
          _kgFocusNodes.clear();
          _repFocusNodes.clear();
          widget.exerciseSets.clear();
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];

            widget.exerciseSets.putIfAbsent(
              exercise.id,
              () => [SetEntry(setNumber: 1, previous: "0kg x 0")],
            );

            final sets = widget.exerciseSets[exercise.id]!;

            // Initialize controllers if they don't exist
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

            // Initialize focus nodes if they don't exist
            _kgFocusNodes.putIfAbsent(
              exercise.name,
              () => List.generate(sets.length, (i) => FocusNode()),
            );

            _repFocusNodes.putIfAbsent(
              exercise.name,
              () => List.generate(sets.length, (i) => FocusNode()),
            );

            // Add any missing controllers and focus nodes when sets are added
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
              _kgFocusNodes[exercise.name]!.add(FocusNode());
              _repFocusNodes[exercise.name]!.add(FocusNode());
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
                  Row(
                    children: [
                      SizedBox(width: 40, child: Text('Set')),
                      SizedBox(width: 80, child: Text('Previous')),
                      SizedBox(width: 70, child: Text('KG')),
                      SizedBox(width: 60, child: Text('Reps')),
                      if (widget.routineExercises == null)
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
                      final kgFocusNode =
                          _kgFocusNodes[exercise.name]![setIndex];
                      final repFocusNode =
                          _repFocusNodes[exercise.name]![setIndex];

                      return Dismissible(
                        key: ValueKey('set_${exercise.id}_$setIndex'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            // Dispose controllers and focus nodes before removing
                            _kgControllers[exercise.name]![setIndex].dispose();
                            _repControllers[exercise.name]![setIndex].dispose();
                            _kgFocusNodes[exercise.name]![setIndex].dispose();
                            _repFocusNodes[exercise.name]![setIndex].dispose();

                            sets.removeAt(setIndex);
                            _kgControllers[exercise.name]!.removeAt(setIndex);
                            _repControllers[exercise.name]!.removeAt(setIndex);
                            _kgFocusNodes[exercise.name]!.removeAt(setIndex);
                            _repFocusNodes[exercise.name]!.removeAt(setIndex);

                            for (int i = 0; i < sets.length; i++) {
                              sets[i].setNumber = i + 1;
                            }
                            _updateVolumeAndSets(exercise.id);
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
                                    key: ValueKey(
                                      'kg_${exercise.id}_$setIndex',
                                    ),
                                    controller: kgController,
                                    focusNode: kgFocusNode,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: _inputDecoration(),
                                    onChanged: (val) {
                                      setState(() {
                                        set.kg = double.tryParse(val) ?? 0;
                                        if (setIndex + 1 < sets.length) {
                                          sets[setIndex + 1].previous =
                                              '${set.kg}kg x ${set.reps}';
                                        }
                                        _updateVolumeAndSets(exercise.id);
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
                                    key: ValueKey(
                                      'rep_${exercise.id}_$setIndex',
                                    ),
                                    controller: repController,
                                    focusNode: repFocusNode,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(),
                                    onChanged: (val) {
                                      setState(() {
                                        set.reps = int.tryParse(val) ?? 0;
                                        if (setIndex + 1 < sets.length) {
                                          sets[setIndex + 1].previous =
                                              '${set.kg}kg x ${set.reps}';
                                        }
                                        _updateVolumeAndSets(exercise.id);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              if (widget.routineExercises == null)
                                Checkbox(
                                  value: set.isCompleted,
                                  onChanged: (val) {
                                    setState(() {
                                      set.isCompleted = val ?? false;
                                      _updateVolumeAndSets(exercise.id);
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
                            previous: sets.isNotEmpty
                                ? '${sets.last.kg}kg x ${sets.last.reps}'
                                : '0kg x 0',
                          );
                          sets.add(newSet);
                          _kgControllers[exercise.name]!.add(
                            TextEditingController(text: ''),
                          );
                          _repControllers[exercise.name]!.add(
                            TextEditingController(text: ''),
                          );
                          _kgFocusNodes[exercise.name]!.add(FocusNode());
                          _repFocusNodes[exercise.name]!.add(FocusNode());
                          _updateVolumeAndSets(exercise.id);
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
