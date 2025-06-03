import '../entities/workout.dart';

abstract class WorkoutRepository {
  Future<void> addWorkout(Workout workout);
  Future<void> updateWorkout(Workout workout);
  Future<void> deleteWorkout(String id);
  Future<Workout?> getWorkoutById(String id);
  Stream<List<Workout>> getWorkouts();
}