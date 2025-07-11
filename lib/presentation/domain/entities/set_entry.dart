class WorkoutSets {
  WorkoutSets({required this.sets});

  final Map<String, ExerciseWorkoutSet> sets;
}

class ExerciseWorkoutSet {
  ExerciseWorkoutSet({required this.name, required this.sets});

  final String name;
  final List<SetEntry> sets;
}

class SetEntry {
  late final int setNumber;
  late final String previous;
  double kg;
  int reps;
  bool isCompleted;

  SetEntry({
    required this.setNumber,
    required this.previous,
    this.kg = 0,
    this.reps = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'set_number': setNumber,
      'previous': previous,
      'kg': kg,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'set_number': setNumber,
      'kg': kg,
      'reps': reps,
      'is_completed': isCompleted,
      'previous': previous,
    };
  }
}
