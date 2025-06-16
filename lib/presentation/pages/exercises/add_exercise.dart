import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/data/repositories_impl/exercise_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/exercise_service.dart';

class AddExercise extends StatefulWidget {
  const AddExercise({super.key});

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final TextEditingController _searchController = TextEditingController();
  final exerciseRepo = ExerciseRepositoryImpl(ExerciseService());
  final Set<Exercise> selectedExercises = <Exercise>{};

  // Add these for manual stream management
  List<Exercise> exercises = [];
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription<List<Exercise>>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _listenToExercises();
  }

  void _listenToExercises() {
    _streamSubscription = exerciseRepo.getExercises().listen(
      (exerciseList) {
        if (mounted) {
          setState(() {
            exercises = exerciseList;
            selectedExercises.addAll(
              workoutExercises.value.where(
                (e) => exercises.any((ex) => ex.id == e.id),
              ),
            );
            isLoading = false;
            errorMessage = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = error.toString();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // This method now only updates selectedExercises, not the exercise list
  void _toggleExerciseSelection(Exercise exercise) {
    setState(() {
      final isSelected = selectedExercises.any((e) => e.id == exercise.id);
      if (isSelected) {
        selectedExercises.removeWhere((e) => e.id == exercise.id);
      } else {
        selectedExercises.add(exercise);
      }
    });
  }

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
                onTap: () => Navigator.pop(context),
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
                onTap: () {},
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

          // Exercise Buttons
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

          // List of Exercises - No more StreamBuilder here!
          Expanded(child: _buildExerciseList()),

          // Add Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: selectedExercises.isNotEmpty
                  ? () {
                      // Add to global notifier
                      workoutExercises.value = [...selectedExercises];
                      Navigator.pop(context);
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

  Widget _buildExerciseList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _listenToExercises();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (exercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final isSelected = selectedExercises.any((e) => e.id == exercise.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
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
              Icons.fitness_center,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          title: Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              exercise.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[400]!,
                width: 2,
              ),
              color: isSelected ? const Color(0xFF4ECDC4) : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          onTap: () => _toggleExerciseSelection(exercise),
        ),
      ),
    );
  }
}
