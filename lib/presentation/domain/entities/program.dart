class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool withOutEquipment;
  final String imageUrl;
  final List<WorkoutSet> sets;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.withOutEquipment,
    required this.imageUrl,
    required this.sets,
  });
}

class WorkoutSet {
  final String exerciseId;
  final String name;
  final List<SetDetail> sets;

  WorkoutSet({
    required this.exerciseId,
    required this.name,
    required this.sets,
  });
}

class SetDetail {
  final int set;
  final String previous;
  final String kg;
  final String reps;
  final bool checked;

  SetDetail({
    required this.set,
    required this.previous,
    required this.kg,
    required this.reps,
    required this.checked,
  });
}

class Routine {
  final String id;
  final String? routineName;
  final List<Exercise> exercises;
  final String? createdAt;

  Routine({
    required this.id,
    this.routineName,
    required this.exercises,
    this.createdAt,
  });
}

class Program {
  final String id;
  final List<String>? routineIds;
  final String? programName;
  final String? createdAt;
  final List<Routine> routines;

  Program({
    required this.id,
    this.routineIds,
    this.programName,
    this.createdAt,
    required this.routines,
  });
}

class ProgramState {
  final List<Program> programs;
  final String? error;

  ProgramState({required this.programs, this.error});
}
