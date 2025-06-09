import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';
import '../../../core/providers/workout_exercise_provider.dart';
import '../../domain/entities/exercise.dart';

class AddWorkoutExercise extends StatefulWidget {
  const AddWorkoutExercise({super.key});

  @override
  State<AddWorkoutExercise> createState() => _AddWorkoutExerciseState();
}

class _AddWorkoutExerciseState extends State<AddWorkoutExercise> {
  final TextEditingController _searchController = TextEditingController();

  // ✅ CHANGE: Track actual Exercise objects, not just names
  Set<Exercise> selectedExercises = {};

  // Sample exercises
  final List<Exercise> exercises = [
    Exercise(
      name: 'Beginner Routine',
      description: 'A routine for beginners.',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Dumbbell Goblet Squat',
      description: 'Works lower body strength.',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Dumbbell Goblet Press',
      description: 'Builds shoulder strength.',
      icon: Icons.fitness_center,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, WorkoutRoutes.logWorkout);
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                  ),
                ),
              ),
              const Text('Add Exercise', style: TextStyle(fontSize: 20)),
              GestureDetector(
                onTap: () {}, // This could be another route or action
                child: Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Exercise Buttons (not yet functional)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Add Exercise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Add Exercise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Exercises',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List of Exercises
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final isSelected = selectedExercises.contains(
                  exercise,
                ); // ✅ CHANGE

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        exercise.icon,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        exercise.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4ECDC4)
                              : Colors.grey,
                          width: 2,
                        ),
                        color: isSelected
                            ? const Color(0xFF4ECDC4)
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedExercises.remove(exercise);
                        } else {
                          selectedExercises.add(exercise);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // ✅ FINAL BUTTON TO ADD EXERCISES TO GLOBAL NOTIFIER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: selectedExercises.isNotEmpty
                  ? () {
                      // ✅ Push selected to global ValueNotifier
                      workoutExercises.value = [
                        ...workoutExercises.value,
                        ...selectedExercises,
                      ];

                      Navigator.pop(context); // or navigate elsewhere
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48A6A7),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                selectedExercises.isEmpty
                    ? 'Add 0 Exercises'
                    : 'Add ${selectedExercises.length} Exercise${selectedExercises.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
