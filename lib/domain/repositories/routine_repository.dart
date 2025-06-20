import '../../domain/entities/routine.dart';

abstract class RoutineRepository {
  // Folder operations
  Future<List<Foldegr>> getFolders(String userId);
  Future<Folder> createFolder(String userId, String folderName);
  Future<void> updateFolderName(String userId, String folderId, String newName);
  Future<void> deleteFolder(String userId, String folderId);
  Future<void> deleteFolderAndRoutines(
    String userId,
    String folderId,
    List<String> routineIds,
  );

  // Routine operations
  Future<Routine> getRoutine(String routineId);
  Future<List<Routine>> getRoutinesByIds(List<String> routineIds);
  Future<List<Folder>> createNewRoutine(
    String userId,
    String routineName,
    Map<String, dynamic>? sets, {
    String? folderId,
  });
  Future<List<Folder>> updateRoutine(
    String userId,
    String routineId, {
    String? updatedRoutineName,
    Map<String, dynamic>? updatedSets,
  });
  Future<void> deleteRoutine(String userId, String folderId, String routineId);

  // Exercise operations
  Future<List<Exercise>> getExercisesById(String routineId);
}
