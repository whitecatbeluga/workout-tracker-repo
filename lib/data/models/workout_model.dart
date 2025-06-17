import '../../domain/entities/workout.dart';

class WorkoutModel extends Workout {
  WorkoutModel({
    required super.id,
    required super.name,
    required super.duration,
    required super.createdAt,
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> data, String docId) {
    return WorkoutModel(
      id: docId,
      name: data['name'] ?? '',
      duration: data['duration'] ?? 0,
      createdAt: (data['created_at']).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'duration': duration, 'createdAt': createdAt};
  }

  @override
  String toString() {
    return 'WorkoutModel{id: $id, name: $name, duration: $duration, createdAt: $createdAt}';
  }
}
