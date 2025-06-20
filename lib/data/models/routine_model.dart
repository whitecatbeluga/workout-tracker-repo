import '../../domain/entities/routine.dart';

class SetDetailModel extends SetDetail {
  SetDetailModel({
    required super.set,
    required super.previous,
    required super.kg,
    required super.reps,
  });

  factory SetDetailModel.fromMap(Map<String, dynamic> map) {
    return SetDetailModel(
      set: map['set'],
      previous: map['previous'],
      kg: map['kg'],
      reps: map['reps'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'set': set, 'previous': previous, 'kg': kg, 'reps': reps};
  }
}

class ExerciseModel extends Exercise {
  ExerciseModel({
    required super.id,
    required super.exerciseId,
    required super.name,
    required super.description,
    required super.category,
    required super.withOutEquipment,
    required super.imageUrl,
    required super.sets,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExerciseModel(
      id: id,
      exerciseId: map['exercise_id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      withOutEquipment: map['with_out_equipment'],
      imageUrl: map['image_url'],
      sets: [], // Will be populated separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'description': description,
      'category': category,
      'with_out_equipment': withOutEquipment,
      'image_url': imageUrl,
    };
  }
}

class RoutineModel extends Routine {
  RoutineModel({
    required super.id,
    super.routineName,
    required super.exercises,
    super.createdAt,
  });

  factory RoutineModel.fromMap(Map<String, dynamic> map, String id) {
    return RoutineModel(
      id: id,
      routineName: map['routine_name'],
      createdAt: map['created_at'],
      exercises: [], // Will be populated separately
    );
  }

  Map<String, dynamic> toMap() {
    return {'routine_name': routineName, 'created_at': createdAt};
  }
}

class FolderModel extends Folder {
  FolderModel({
    required super.id,
    super.routineIds,
    super.folderName,
    super.createdAt,
    super.routines,
  });

  factory FolderModel.fromMap(
    Map<String, dynamic> map,
    String docId, {
    List<RoutineModel>? routines,
  }) {
    return FolderModel(
      id: docId,
      routineIds: List<String>.from(map['routine_ids'] ?? []),
      folderName: map['folder_name'],
      createdAt: map['createdAt']?.toDate().toIso8601String(),
      routines: routines,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routine_ids': routineIds ?? [],
      'folder_name': folderName,
      'createdAt': createdAt,
    };
  }
}
