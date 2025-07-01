import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/routine.dart';

class SetDetailModel extends SetDetail {
  SetDetailModel({
    required super.setNumber,
    required super.previous,
    required super.kg,
    required super.reps,
    super.isCompleted = false,
  });

  factory SetDetailModel.fromMap(Map<String, dynamic> map) {
    return SetDetailModel(
      setNumber: map['set_number'],
      previous: map['previous'],
      kg: (map['kg'] as num).toDouble(),
      reps: map['reps'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'set_number': setNumber,
      'previous': previous,
      'kg': kg,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }
}

class ExerciseModel extends Exercise {
  ExerciseModel({
    required super.id,
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
      name: map['name'],
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      withOutEquipment: map['with_out_equipment'] ?? false,
      imageUrl: map['image_url'] ?? '',
      sets: List<Map<String, dynamic>>.from(
        map['sets'] ?? [],
      ).map((set) => SetDetailModel.fromMap(set)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'with_out_equipment': withOutEquipment,
      'image_url': imageUrl,
      'sets': sets
          .map(
            (s) => SetDetailModel(
              setNumber: s.setNumber,
              previous: s.previous,
              kg: s.kg,
              reps: s.reps,
              isCompleted: s.isCompleted,
            ).toMap(),
          )
          .toList(),
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
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate().toIso8601String()
          : map['created_at']?.toString(),
      exercises: [], // Filled later
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
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate().toIso8601String()
          : map['created_at']?.toString(),

      routines: routines,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routine_ids': routineIds ?? [],
      'folder_name': folderName,
      'created_at': createdAt,
    };
  }
}
