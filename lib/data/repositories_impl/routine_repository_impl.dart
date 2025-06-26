import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final RoutineService _service;

  RoutineRepositoryImpl(this._service);

  @override
  Future<List<Folder>> getFolders(String userId) async {
    final docs = await _service.getFolders(userId);

    List<Folder> folders = [];
    for (var doc in docs) {
      final folderData = FolderModel.fromMap(doc.data(), doc.id);

      // Get routines for this folder
      if (folderData.routineIds != null && folderData.routineIds!.isNotEmpty) {
        final routinesData = await _service.getRoutinesByIds(
          folderData.routineIds!,
        );
        final routines = routinesData.map((routineData) {
          final exercises = (routineData['exercises'] as List).map((
            exerciseData,
          ) {
            final sets = (exerciseData['sets'] as List)
                .map(
                  (setData) =>
                      SetDetailModel.fromMap(setData as Map<String, dynamic>),
                )
                .toList();

            return ExerciseModel(
              id: exerciseData['id'],
              exerciseId: exerciseData['exercise_id'],
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
            createdAt: routineData['createdAt'],
            exercises: exercises,
          );
        }).toList();

        folderData.routines = routines;
      }

      folders.add(folderData);
    }

    return folders;
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
        exerciseId: exerciseData['exercise_id'],
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
      createdAt: routineData['createdAt'],
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
          exerciseId: exerciseData['exercise_id'],
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
        createdAt: routineData['createdAt'],
        exercises: exercises,
      );
    }).toList();
  }

  @override
  Future<List<Folder>> createNewRoutine(
    String userId,
    String routineName,
    Map<String, dynamic>? sets, {
    String? folderId,
  }) async {
    await _service.createNewRoutine(
      userId,
      routineName,
      sets,
      folderId: folderId,
    );
    return getFolders(userId);
  }

  @override
  Future<List<Folder>> updateRoutine(
    String userId,
    String routineId, {
    String? updatedRoutineName,
    Map<String, dynamic>? updatedSets,
  }) async {
    await _service.updateRoutine(
      routineId,
      updatedRoutineName: updatedRoutineName,
      updatedSets: updatedSets,
    );
    return getFolders(userId);
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
        exerciseId: exerciseData['exercise_id'],
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
