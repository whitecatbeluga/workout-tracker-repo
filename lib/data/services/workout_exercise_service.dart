import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';

class WorkoutExerciseService {
  Future<void> addExercise(Exercise exercise) async {
    workoutExercises.value = [...workoutExercises.value, exercise];
  }
}
