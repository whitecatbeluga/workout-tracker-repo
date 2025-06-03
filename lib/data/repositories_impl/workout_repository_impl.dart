import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutService _service;

  WorkoutRepositoryImpl(this._service);

  @override
  Future<void> addWorkout(Workout workout) async {
    final model = WorkoutModel(
      id: '',
      name: workout.name,
      duration: workout.duration,
      createdAt: workout.createdAt,
    );
    await _service.add(model.toMap());
  }

  @override
  Future<void> deleteWorkout(String id) => _service.delete(id);

  @override
  Future<Workout?> getWorkoutById(String id) async {
    final doc = await _service.getById(id);
    if (doc.exists) {
      return WorkoutModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Stream<List<Workout>> getWorkouts() {
    return _service.getAll().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkoutModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    final model = WorkoutModel(
      id: workout.id,
      name: workout.name,
      duration: workout.duration,
      createdAt: workout.createdAt,
    );
    await _service.update(workout.id, model.toMap());
  }
}