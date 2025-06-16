class CalendarWorkoutDates {
  final DateTime date;
  List<UserWorkout> workouts;
  List<String> images;

  CalendarWorkoutDates({
    required this.date,
    required this.workouts,
    required this.images,
  });

  @override
  String toString() =>
      'CalendarWorkoutDates(date: $date, workouts: $workouts, images: $images)';
}

class UserWorkout {
  final String id;
  final String title;
  final String duration;
  final String volume;
  final String sets;
  final String createdAt;

  UserWorkout({
    required this.id,
    required this.title,
    required this.duration,
    required this.volume,
    required this.sets,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'UserWorkout(id: $id, title: $title, duration: $duration, volume: $volume, sets: $sets)';
  }
}
