import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/entities/upsert_routine_args.dart';
import 'package:workout_tracker_repo/domain/repositories/routine_repository.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/log_exercise_card.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart'
    as exercise_entity;

class UpsertRoutine extends StatefulWidget {
  const UpsertRoutine({super.key});

  @override
  State<UpsertRoutine> createState() => _UpsertRoutineState();
}

class _UpsertRoutineState extends State<UpsertRoutine> {
  final user = authService.value.getCurrentUser();
  final Map<String, List<SetEntry>> exerciseSets = {};
  final TextEditingController routineNameController = TextEditingController();
  final RoutineRepository _routineRepository = RoutineRepositoryImpl(
    RoutineService(),
  );
  late final UpsertRoutineArgs args;
  bool _argsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_argsInitialized) {
      final receivedArgs = ModalRoute.of(context)?.settings.arguments;
      if (receivedArgs != null && receivedArgs is UpsertRoutineArgs) {
        args = receivedArgs;
        _argsInitialized = true;
        setState(() {
          routineNameController.text = args.routine?.routineName ?? '';
        });

        if (args.routine?.exercises != null) {
          routineExercises.value = args.routine!.exercises.map((e) {
            return exercise_entity.Exercise(
              id: e.id,
              name: e.name,
              description: e.description,
              category: e.category,
              withoutEquipment: e.withOutEquipment,
              imageUrl: e.imageUrl,
            );
          }).toList();

          for (final exercise in args.routine!.exercises) {
            exerciseSets[exercise.id] = exercise.sets.asMap().entries.map((
              entry,
            ) {
              final set = entry.value;
              return SetEntry(
                setNumber: entry.key + 1,
                previous: "${set.kg}kg x ${set.reps}",
                kg: set.kg,
                reps: set.reps,
                isCompleted: false,
              );
            }).toList();
          }
        }
      } else {
        throw Exception('Missing arguments for UpsertRoutine');
      }
    }
  }

  void _saveRoutine(String folderId) async {
    final routineName = routineNameController.text.trim();

    // Map each exercise to its ID, name, and list of SetEntry
    final Map<String, ExerciseWorkoutSet> mappedSets = {
      for (final exercise in routineExercises.value)
        exercise.id: ExerciseWorkoutSet(
          name: exercise.name,
          sets: exerciseSets[exercise.id] ?? [],
        ),
    };

    final workoutSets = WorkoutSets(sets: mappedSets);

    if (routineName.isNotEmpty) {
      try {
        _routineRepository.createNewRoutine(
          user!.uid,
          routineName,
          workoutSets,
          folderId: folderId,
        );

        routineExercises.value.clear();
        exerciseSets.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine saved successfully!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save routine. Please try again.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine name cannot be empty.')),
      );
    }
  }

  void _updateRoutine() async {
    final routineName = routineNameController.text.trim();

    // Build updatedSets Map<String, dynamic> to match Firestore structure
    final Map<String, dynamic> updatedSets = {
      for (final exercise in routineExercises.value)
        exercise.id: {
          'name': exercise.name,
          'sets': (exerciseSets[exercise.id] ?? [])
              .map(
                (set) => {
                  'set_number': set.setNumber,
                  'previous': set.previous,
                  'kg': set.kg,
                  'reps': set.reps,
                  'isCompleted': set.isCompleted,
                },
              )
              .toList(),
        },
    };

    if (routineName.isNotEmpty) {
      try {
        await _routineRepository.updateRoutine(
          args.routine!.id,
          updatedRoutineName: routineName,
          updatedSets: updatedSets,
        );

        // Clear local state
        routineExercises.value.clear();
        exerciseSets.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine saved successfully!')),
        );

        // Navigate back to home screen
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        debugPrint('Error updating routine: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save routine. Please try again.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine name cannot be empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                  ),
                ),
              ),
              Text(
                args.routine == null ? 'Create Routine' : 'Update Routine',
                style: TextStyle(fontSize: 20),
              ),
              GestureDetector(
                onTap: () async {
                  if (args.routine == null) {
                    _saveRoutine(args.folderId);
                  } else {
                    _updateRoutine();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF48A6A7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    args.routine == null ? 'Save' : 'Update',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: routineNameController,
              style: const TextStyle(
                color: Color(0xFF626262),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Routine Title',
                hintStyle: TextStyle(
                  color: const Color(0xFF626262).withAlpha(170),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: LogExerciseCard(
                routineExercises: routineExercises,
                exerciseSets: exerciseSets,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Button(
          label: 'Add Exercise',
          prefixIcon: Icons.add,
          onPressed: () => Navigator.pushNamed(
            context,
            ExerciseRoutes.addWorkoutExercise,
            arguments: {'isLogWorkout': false},
          ),
          variant: ButtonVariant.secondary,
          fullWidth: true,
          size: ButtonSize.large,
        ),
      ),
    );
  }

  @override
  void dispose() {
    routineNameController.dispose();
    super.dispose();
  }
}
