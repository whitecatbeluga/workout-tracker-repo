import 'package:workout_tracker_repo/data/errors/custom_error_exception.dart';

import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutService _service;

  WorkoutRepositoryImpl(this._service);

  @override
  Future<void> addWorkout(Workout workout) async {
    try {
      final model = WorkoutModel(
        id: '',
        name: workout.name,
        duration: workout.duration,
        createdAt: workout.createdAt,
      );
      await _service.add(model.toMap());
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      _service.delete(id);
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<Workout?> getWorkoutById(String id) async {
    try {
      final doc = await _service.getById(id);
      if (doc.exists) {
        return WorkoutModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Stream<List<Workout>> getWorkouts() {
    try {
      return _service.getAll().map((snapshot) {
        return snapshot.docs.map((doc) {
          return WorkoutModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    try {
      final model = WorkoutModel(
        id: workout.id,
        name: workout.name,
        duration: workout.duration,
        createdAt: workout.createdAt,
      );
      await _service.update(workout.id, model.toMap());
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Stream<List<Workout>> getWorkoutsByUserId(String userId) {
    try {
      return _service.getByUserId(userId).map((snapshot) {
        return snapshot.docs.map((doc) {
          return WorkoutModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }
}
