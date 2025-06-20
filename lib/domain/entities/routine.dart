// Updated Entity Structure
class SetDetail {
  final int set;
  final String previous;
  final String kg;
  final String reps;

  SetDetail({
    required this.set,
    required this.previous,
    required this.kg,
    required this.reps,
  });
}

class WorkoutSet {
  final String exerciseId;
  final List<SetDetail> sets;

  WorkoutSet({required this.exerciseId, required this.sets});
}

class Exercise {
  final String id;
  final String exerciseId; // Added to match React Native structure
  final String name;
  final String description;
  final String category;
  final bool withOutEquipment;
  final String imageUrl;
  final List<SetDetail>
  sets; // Changed to List<SetDetail> to match React Native

  Exercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.description,
    required this.category,
    required this.withOutEquipment,
    required this.imageUrl,
    required this.sets,
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

class Folder {
  final String id;
  final List<String>? routineIds;
  final String? folderName;
  final String? createdAt;
  List<Routine>? routines;

  Folder({
    required this.id,
    this.routineIds,
    this.folderName,
    this.createdAt,
    this.routines,
  });
}
