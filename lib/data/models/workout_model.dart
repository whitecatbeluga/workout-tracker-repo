import '../../domain/entities/workout.dart';

class WorkoutModel extends Workout {
  WorkoutModel({
    required super.id,
    required super.name,
    required super.duration,
    required super.createdAt,
    super.sets,
    super.volume,
    super.exercises,
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> data, String docId) {
    return WorkoutModel(
      id: docId,
      name: data['name'] ?? '',
      duration: parseDuration(data['workout_duration'] ?? '0m 0s'),
      createdAt: (data['created_at']).toDate(),
      sets: data['total_sets'],
      volume: data['total_volume'],
      exercises: data['exercises'],
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
    return 'WorkoutModel{id: $id, name: $name, duration: $duration, createdAt: $createdAt, sets: $sets, volume: $volume, exercises: $exercises}';
  }
}

int parseDuration(String input) {
  final regex = RegExp(r'(\d+)m\s*(\d+)s');
  final match = regex.firstMatch(input);

  if (match != null) {
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    return minutes * 60 + seconds;
  }

  return 0; // fallback
}
