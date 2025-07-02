import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/user_info_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/repositories/routine_repository.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';
import 'package:workout_tracker_repo/presentation/widgets/badge/badge.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart' as base;
import 'package:workout_tracker_repo/routes/workout/workout.dart';

class ViewRoutine extends StatelessWidget {
  ViewRoutine({super.key});

  final RoutineRepository _routineRepository = RoutineRepositoryImpl(
    RoutineService(),
  );

  @override
  Widget build(BuildContext context) {
    final routineId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Details'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Routine>(
        future: _routineRepository.getRoutine(routineId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Routine not found.'));
          }

          final routine = snapshot.data!;

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
