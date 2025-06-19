import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/data/repositories_impl/exercise_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/exercise_service.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/exercise_card.dart';

class ExcercisesPage extends StatefulWidget {
  const ExcercisesPage({super.key});

  @override
  State<ExcercisesPage> createState() => _ExcercisesPageState();
}

class _ExcercisesPageState extends State<ExcercisesPage> {
  final exerciserepo = ExerciseRepositoryImpl(ExerciseService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        backgroundColor: const Color(0xFFF4F4F4),
      ),
      body: Container(
        height: double.infinity,
        color: const Color(0xFFF4F4F4),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder(
              stream: exerciserepo.getExercises(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Fetching Exercises...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Colors.grey,
                          size: 60,
                        ),
                        SizedBox(height: 10),
                        Text('No exercises found'),
                      ],
                    ),
                  );
                }

                final exercises = snapshot.data!;

                return Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var exercise in exercises)
                      ExerciseCard(
                        exerciseName: exercise.name,
                        withEquipment: exercise.withoutEquipment,
                        exerciseCategory: exercise.category,
                        exerciseDescription: exercise.description,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
