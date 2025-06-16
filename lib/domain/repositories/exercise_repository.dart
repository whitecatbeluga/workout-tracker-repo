import '../../domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Stream<List<Exercise>> getExercises();
}
