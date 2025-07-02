import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';

import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final RoutineService _service;

  RoutineRepositoryImpl(this._service);

  @override
  Stream<List<Folder>> streamFolders(String userId) async* {
    final folderStream = _service.streamFolders(userId);

    await for (final docs in folderStream) {
      List<Folder> folders = [];

      for (var doc in docs) {
        final folderData = FolderModel.fromMap(doc.data(), doc.id);

        if (folderData.routineIds != null &&
            folderData.routineIds!.isNotEmpty) {
          final routinesData = await _service.getRoutinesByIds(
            folderData.routineIds!,
          );

          final routines = routinesData.map((routineData) {
            final exercisesRaw = routineData['exercises'] as List? ?? [];

            final exercises = exercisesRaw.map((exerciseData) {
              final setsRaw = exerciseData['sets'] as List? ?? [];

              final sets = setsRaw.map((setData) {
                return SetDetailModel.fromMap(setData as Map<String, dynamic>);
              }).toList();

              return ExerciseModel(
                id: exerciseData['exercise_id'] ?? exerciseData['id'] ?? '',
                name: exerciseData['name'] ?? '',
                description: exerciseData['description'] ?? '',
                category: exerciseData['category'] ?? '',
                withOutEquipment: exerciseData['with_out_equipment'] ?? false,
                imageUrl: exerciseData['image_url'] ?? '',
                sets: sets,
              );
            }).toList();

            return RoutineModel(
              id: routineData['id'],
              routineName: routineData['routine_name'],
              createdAt: routineData['created_at'],
              exercises: exercises,
            );
          }).toList();

          folderData.routines = routines;
        }

        folders.add(folderData);
      }

      yield folders;
    }
  }

  @override
  Future<Folder> createFolder(String userId, String folderName) async {
    final ref = await _service.createNewFolder(userId, folderName);
    return Folder(
      id: ref.id,
      folderName: folderName,
      createdAt: DateTime.now().toIso8601String(),
      routineIds: [],
      routines: [],
    );
  }

  @override
  Future<void> updateFolderName(
    String userId,
    String folderId,
    String newName,
  ) async {
    await _service.updateFolderName(userId, folderId, newName);
  }

  @override
  Future<void> deleteFolder(String userId, String folderId) async {
    await _service.deleteFolder(userId, folderId);
  }

  @override
  Future<void> deleteFolderAndRoutines(
    String userId,
    String folderId,
    List<String> routineIds,
  ) async {
    await _service.deleteFolderAndRoutines(userId, folderId, routineIds);
  }

  @override
  Future<Routine> getRoutine(String routineId) async {
    final routineData = await _service.getRoutine(routineId);
    if (routineData == null) throw Exception('Routine not found');

    final exercisesData = await _service.getExercisesById(routineId);
    final exercises = exercisesData.map((exerciseData) {
      final sets = (exerciseData['sets'] as List)
          .map(
            (setData) =>
                SetDetailModel.fromMap(setData as Map<String, dynamic>),
          )
          .toList();

      return ExerciseModel(
        id: exerciseData['id'],
        name: exerciseData['name'] ?? '',
        description: exerciseData['description'] ?? '',
        category: exerciseData['category'] ?? '',
        withOutEquipment: exerciseData['with_out_equipment'] ?? false,
        imageUrl: exerciseData['image_url'] ?? '',
        sets: sets,
      );
    }).toList();

    return RoutineModel(
      id: routineData['id'],
      routineName: routineData['routine_name'],
      createdAt: (routineData['created_at'] as Timestamp?)
          ?.toDate()
          .toIso8601String(),
      exercises: exercises,
    );
  }

  @override
  Future<List<Routine>> getRoutinesByIds(List<String> routineIds) async {
    final routinesData = await _service.getRoutinesByIds(routineIds);

    return routinesData.map((routineData) {
      final exercises = (routineData['exercises'] as List).map((exerciseData) {
        final sets = (exerciseData['sets'] as List)
            .map(
              (setData) =>
                  SetDetailModel.fromMap(setData as Map<String, dynamic>),
            )
            .toList();

        return ExerciseModel(
          id: exerciseData['id'],
          name: exerciseData['name'] ?? '',
          description: exerciseData['description'] ?? '',
          category: exerciseData['category'] ?? '',
          withOutEquipment: exerciseData['with_out_equipment'] ?? false,
          imageUrl: exerciseData['image_url'] ?? '',
          sets: sets,
        );
      }).toList();

      return RoutineModel(
        id: routineData['id'],
        routineName: routineData['routine_name'],
        createdAt: routineData['created_at'],
        exercises: exercises,
      );
    }).toList();
  }

  @override
  void createNewRoutine(
    String userId,
    String routineName,
    WorkoutSets? workoutSets, {
    String? folderId,
  }) async {
    await _service.createNewRoutine(
      userId,
      routineName,
      workoutSets,
      folderId: folderId,
    );
  }

  @override
  Future<void> updateRoutine(
    String routineId, {
    String? updatedRoutineName,
    Map<String, dynamic>? updatedSets,
  }) async {
    await _service.updateRoutine(
      routineId,
      updatedRoutineName: updatedRoutineName,
      updatedSets: updatedSets,
    );
  }

  @override
  Future<void> deleteRoutine(
    String userId,
    String folderId,
    String routineId,
  ) async {
    await _service.deleteRoutine(userId, folderId, routineId);
  }

  @override
  Future<List<Exercise>> getExercisesById(String routineId) async {
    final exercisesData = await _service.getExercisesById(routineId);

    return exercisesData.map((exerciseData) {
      final sets = (exerciseData['sets'] as List)
          .map(
            (setData) =>
                SetDetailModel.fromMap(setData as Map<String, dynamic>),
          )
          .toList();

      return ExerciseModel(
        id: exerciseData['id'],
        name: exerciseData['name'] ?? '',
        description: exerciseData['description'] ?? '',
        category: exerciseData['category'] ?? '',
        withOutEquipment: exerciseData['with_out_equipment'] ?? false,
        imageUrl: exerciseData['image_url'] ?? '',
        sets: sets,
      );
    }).toList();
  }
}
