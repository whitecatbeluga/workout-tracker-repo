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

  @override
  Stream<List<Exercise>> getExercisesByUserId(String userId) {
    try {
      return _exercise.getExercises(userId).map((snapshot) {
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

  @override
  Future<void> addExercise(Exercise exercise, String userId) async {
    try {
      final model = ExerciseModel(
        id: exercise.id,
        name: exercise.name,
        description: exercise.description,
        imageUrl: exercise.imageUrl,
        category: exercise.category,
        withoutEquipment: exercise.withoutEquipment,
      );
      await _exercise.addExercise(model.toMap(), userId);
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }
}
