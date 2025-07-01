import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/log_exercise_card.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';

class CreateRoutine extends StatefulWidget {
  const CreateRoutine({super.key});

  @override
  State<CreateRoutine> createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> {
  final Map<String, List<SetEntry>> exerciseSets = {};
  final user = authService.value.getCurrentUser();
  final TextEditingController routineNameController = TextEditingController();
  final routineRepo = RoutineRepositoryImpl(RoutineService());
  String? folderId;

  @override
  void initState() {
    super.initState();

    // Defer access to ModalRoute to post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('folderId')) {
        setState(() {
          folderId = args['folderId'];
        });
      }
    });
  }

  void _saveRoutine() async {
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
        routineRepo.createNewRoutine(
          user!.uid,
          routineName,
          workoutSets,
          folderId: folderId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine saved successfully!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        print('Error saving routine: $e');
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
              const Text('Create Routine', style: TextStyle(fontSize: 20)),
              GestureDetector(
                onTap: _saveRoutine,
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
                  child: const Text(
                    'Save',
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
                  color: const Color(0xFF626262).withOpacity(0.5),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: LogExerciseCard(
                workoutExercises: routineExercises,
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
}
