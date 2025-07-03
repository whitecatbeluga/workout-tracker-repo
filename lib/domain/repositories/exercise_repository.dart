import '../../domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Stream<List<Exercise>> getExercises();

  Future<void> addExercise(Exercise exercise, String userId);
  Future<void> updateExercise(Exercise exercise, String userId);

  Stream<List<Exercise>> getExercisesByUserId(String userId);
}
