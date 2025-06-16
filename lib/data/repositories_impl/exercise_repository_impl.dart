import 'package:workout_tracker_repo/data/errors/custom_error_exception.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseService _exercise;

  ExerciseRepositoryImpl(this._exercise);

  @override
  Stream<List<Exercise>> getExercises() {
    try {
      return _exercise.getAll().map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExerciseModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }
}
