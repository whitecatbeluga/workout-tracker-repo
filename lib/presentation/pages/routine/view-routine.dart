import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/core/providers/user_info_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/predefined_routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/predefined_routine_service.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/entities/view_routine_args.dart';
import 'package:workout_tracker_repo/domain/repositories/predefined_routine_repository.dart';
import 'package:workout_tracker_repo/domain/repositories/routine_repository.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';
import 'package:workout_tracker_repo/presentation/widgets/badge/badge.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart' as base;
import 'package:workout_tracker_repo/routes/workout/workout.dart';

class ViewRoutine extends StatefulWidget {
  const ViewRoutine({super.key});

  @override
  State<ViewRoutine> createState() => _ViewRoutineState();
}

class _ViewRoutineState extends State<ViewRoutine> {
  final user = authService.value.getCurrentUser();

  final RoutineRepository _routineRepository = RoutineRepositoryImpl(
    RoutineService(),
  );

  final PredefinedRoutineRepository _predefinedRoutineRepository =
      PredefinedRoutineRepositoryImpl(PredefinedRoutineService());

  late final ViewRoutineArgs args;
  Routine? passedRoutine;
  bool _argsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_argsInitialized) {
      final receivedArgs = ModalRoute.of(context)?.settings.arguments;
      if (receivedArgs != null && receivedArgs is ViewRoutineArgs) {
        args = receivedArgs;
        _argsInitialized = true;
      } else {
        throw Exception('Missing arguments for ViewRoutine');
      }
    }
  }

  void _saveRoutine(String? folderId) async {
    final Map<String, ExerciseWorkoutSet> mappedSets = {
      for (final exercise in passedRoutine!.exercises)
        exercise.id: ExerciseWorkoutSet(
          name: exercise.name,
          sets: exercise.sets
              .map(
                (set) => SetEntry(
                  setNumber: set.setNumber,
                  previous: set.previous,
                  kg: set.kg,
                  reps: set.reps,
                  isCompleted: set.isCompleted,
                ),
              )
              .toList(),
        ),
    };

    final workoutSets = WorkoutSets(sets: mappedSets);

    _routineRepository.createNewRoutine(
      user!.uid,
      passedRoutine!.routineName as String,
      workoutSets,
      folderId: folderId,
    );

    routineExercises.value.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Routine saved successfully!')),
    );
  }

  void _showFolderPickerModal(BuildContext context, List<Folder> folders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1.0, // 🔥 This makes it take full width
          child: Padding(
            padding: MediaQuery.of(context).viewInsets, // handles keyboard
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Folder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ...folders.map((folder) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close the bottom sheet

                          _saveRoutine(folder.id);
                        },
                        icon: const Icon(
                          Icons.folder,
                          color: Color(0xFF323232),
                        ),
                        label: Text(
                          folder.folderName ?? 'Unnamed Folder',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF323232),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: const Color(0xFF323232),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Details'),
        backgroundColor: Colors.white,
        actions: [
          if (args.predefinedRoutineId != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final folders = await _routineRepository
                    .streamFolders(user!.uid)
                    .first;

                if (folders.isNotEmpty) {
                  _showFolderPickerModal(context, folders);
                } else {
                  _saveRoutine('');
                }
              },
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Routine>(
        future: args.routineId != null
            ? _routineRepository.getRoutine(args.routineId as String)
            : _predefinedRoutineRepository.getPredefinedRoutine(
                args.predefinedRoutineId as String,
              ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Routine not found.'));
          }

          final routine = snapshot.data!;

          passedRoutine = routine;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Routine Name: ${routine.routineName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: currentUserProfile,
                        builder: (context, user, child) {
                          return Text(
                            'Created By: ${user!.firstName} ${user.lastName}',
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                      Button(
                        label: "Start Routine",
                        onPressed: () {
                          // Set workout exercises (just metadata)
                          workoutExercises.value = routine.exercises.map((e) {
                            return base.Exercise(
                              id: e.id,
                              name: e.name,
                              description: e.description,
                              imageUrl: e.imageUrl,
                              category: e.category,
                              withoutEquipment: e.withOutEquipment,
                            );
                          }).toList();

                          // Clear old sets
                          savedExerciseSets.clear();

                          // Add sets from each exercise
                          for (final exercise in routine.exercises) {
                            savedExerciseSets[exercise.id] = exercise.sets
                                .asMap()
                                .entries
                                .map((entry) {
                                  final set = entry.value;
                                  return SetEntry(
                                    setNumber: entry.key + 1,
                                    previous: "${set.kg}kg x ${set.reps}",
                                    kg: set.kg,
                                    reps: set.reps,
                                    isCompleted: false,
                                  );
                                })
                                .toList();
                          }

                          // Navigate
                          Navigator.pushNamed(
                            context,
                            WorkoutRoutes.logWorkout,
                          );
                        },
                        prefixIcon: Icons.play_arrow_rounded,
                        fullWidth: true,
                        size: ButtonSize.large,
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: routine.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = routine.exercises[index];

                    return Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            exercise.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BadgeWidget(
                              label: exercise.withOutEquipment
                                  ? 'With Equipment'
                                  : 'No Equipment',
                              color: exercise.withOutEquipment
                                  ? const Color(0xFF48A6A7)
                                  : const Color(0xFFED1010),
                            ),
                            Text(
                              exercise.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Set #')),
                              DataColumn(label: Text('Previous')),
                              DataColumn(label: Text('Kg')),
                              DataColumn(label: Text('Reps')),
                              DataColumn(label: Text('Completed')),
                            ],
                            rows: exercise.sets.map((set) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(set.setNumber.toString())),
                                  DataCell(Text(set.previous)),
                                  DataCell(Text(set.kg.toString())),
                                  DataCell(Text(set.reps.toString())),
                                  DataCell(
                                    Icon(
                                      set.isCompleted
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: set.isCompleted
                                          ? Colors.green
                                          : Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
