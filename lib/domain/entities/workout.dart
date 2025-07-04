class Workout {
  final String id;
  final String name;
  final int duration;
  final DateTime createdAt;
  List<dynamic>? exercises;
  final int? sets;
  final int? volume;

  Workout({
    required this.id,
    required this.name,
    required this.duration,
    required this.createdAt,
    this.sets,
    this.volume,
    this.exercises,
  });
}
