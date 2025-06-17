import '../../domain/entities/workout.dart';

class WorkoutModel extends Workout {
  WorkoutModel({
    required super.id,
    required super.name,
    required super.duration,
    required super.createdAt,
    super.sets,
    super.volume,
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> data, String docId) {
    return WorkoutModel(
      id: docId,
      name: data['name'] ?? '',
      duration: int.parse(data['workout_duration'] ?? '0'),
      createdAt: (data['created_at']).toDate(),
      sets: data['total_sets'],
      volume: data['total_volume'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'createdAt': createdAt,
      if (sets != null) 'sets': sets,
      if (volume != null) 'volume': volume,
    };
  }

  @override
  String toString() {
    return 'WorkoutModel{id: $id, name: $name, duration: $duration, createdAt: $createdAt, sets: $sets, volume: $volume, }';
  }
}
