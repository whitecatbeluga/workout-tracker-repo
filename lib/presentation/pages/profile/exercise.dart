import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/exercise_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/exercise_service.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/exercise_card.dart';

enum ExerciseFilter { myExercises, predefinedExercises, allExercises }

class ExcercisesPage extends StatefulWidget {
  const ExcercisesPage({super.key});

  @override
  State<ExcercisesPage> createState() => _ExcercisesPageState();
}

class _ExcercisesPageState extends State<ExcercisesPage> {
  final exerciserepo = ExerciseRepositoryImpl(ExerciseService());
  final user = authService.value.getCurrentUser();
  ExerciseFilter selectedFilter = ExerciseFilter.allExercises;

  String get filterTitle {
    switch (selectedFilter) {
      case ExerciseFilter.myExercises:
        return 'My Exercises';
      case ExerciseFilter.predefinedExercises:
        return 'Predefined Exercises';
      case ExerciseFilter.allExercises:
        return 'All Exercises';
    }
  }

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Exercises',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                ExerciseFilter.allExercises,
                'All Exercises',
                'Show both my exercises and predefined exercises',
                Icons.fitness_center,
              ),
              _buildFilterOption(
                ExerciseFilter.myExercises,
                'My Exercises',
                'Show only exercises I created',
                Icons.person,
              ),
              _buildFilterOption(
                ExerciseFilter.predefinedExercises,
                'Predefined Exercises',
                'Show only predefined exercises',
                Icons.library_books,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    ExerciseFilter filter,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = selectedFilter == filter;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Color(0xFF006A71) : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Color(0xFF006A71) : Colors.black87,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: Color(0xFF006A71))
            : null,
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? Color(0xFF006A71).withAlpha(0x1A) : null,
      ),
    );
  }

  List<dynamic> _getFilteredExercises(
    List<dynamic> predefinedExercises,
    List<dynamic> userExercises,
  ) {
    switch (selectedFilter) {
      case ExerciseFilter.myExercises:
        return userExercises;
      case ExerciseFilter.predefinedExercises:
        return predefinedExercises;
      case ExerciseFilter.allExercises:
        return [...userExercises, ...predefinedExercises];
    }
  }

  Widget _buildExercisesList(
    List<dynamic> predefinedExercises,
    List<dynamic> userExercises,
  ) {
    final exercisesToDisplay = _getFilteredExercises(
      predefinedExercises,
      userExercises,
    );

    if (exercisesToDisplay.isEmpty) {
      String emptyMessage;
      switch (selectedFilter) {
        case ExerciseFilter.myExercises:
          emptyMessage = 'No personal exercises found';
          break;
        case ExerciseFilter.predefinedExercises:
          emptyMessage = 'No predefined exercises found';
          break;
        case ExerciseFilter.allExercises:
          emptyMessage = 'No exercises found';
          break;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, color: Colors.grey, size: 60),
            const SizedBox(height: 10),
            Text(emptyMessage),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _openFilterDrawer,
              icon: const Icon(Icons.filter_list),
              label: const Text('Change Filter'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Color(0xFF006A71).withAlpha(0x1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFF006A71).withAlpha(0x1A)),
          ),
          child: Row(
            children: [
              Icon(
                selectedFilter == ExerciseFilter.myExercises
                    ? Icons.person
                    : selectedFilter == ExerciseFilter.predefinedExercises
                    ? Icons.library_books
                    : Icons.fitness_center,
                color: Color(0xFF006A71),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Showing: $filterTitle (${exercisesToDisplay.length} exercises)',
                style: const TextStyle(
                  color: Color(0xFF006A71),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _openFilterDrawer,
                child: const Icon(
                  Icons.tune,
                  color: Color(0xFF006A71),
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        // Exercise cards
        Column(
          spacing: 10,
          children: [
            for (var exercise in exercisesToDisplay)
              ExerciseCard(
                exerciseName: exercise.name,
                withEquipment: exercise.withoutEquipment,
                exerciseCategory: exercise.category,
                exerciseDescription: exercise.description,
                imageUrl: exercise.imageUrl,
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filterTitle),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: Navigator.canPop(context)
              ? () => Navigator.pop(context)
              : () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDrawer,
            tooltip: 'Filter Exercises',
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: StreamBuilder(
              stream: exerciserepo.getExercises(),
              builder: (context, allExercisesSnapshot) {
                if (allExercisesSnapshot.connectionState ==
                    ConnectionState.waiting) {
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

                if (allExercisesSnapshot.hasError) {
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
                          'Error: ${allExercisesSnapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return StreamBuilder(
                  stream: user != null
                      ? exerciserepo.getExercisesByUserId(user!.uid)
                      : Stream.value([]),
                  builder: (context, userExercisesSnapshot) {
                    if (userExercisesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('Fetching User Exercises...'),
                          ],
                        ),
                      );
                    }

                    if (userExercisesSnapshot.hasError) {
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
                              'Error fetching user exercises: ${userExercisesSnapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final predefinedExercises = allExercisesSnapshot.data ?? [];
                    final userExercises = userExercisesSnapshot.data ?? [];

                    return _buildExercisesList(
                      predefinedExercises,
                      userExercises,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
