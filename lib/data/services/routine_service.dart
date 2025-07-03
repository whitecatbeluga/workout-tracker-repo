import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';

class RoutineService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _foldersRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('folders');

  // Folder operations
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamFolders(
    String userId,
  ) {
    return _foldersRef(userId).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<DocumentReference> createNewFolder(
    String userId,
    String folderName,
  ) async {
    return _foldersRef(userId).add({
      'folder_name': folderName,
      'created_at': Timestamp.now(),
      'routine_ids': [],
    });
  }

  Future<void> updateFolderName(
    String userId,
    String folderId,
    String newName,
  ) async {
    await _foldersRef(userId).doc(folderId).update({'folder_name': newName});
  }

  Future<void> deleteFolder(String userId, String folderId) async {
    await _foldersRef(userId).doc(folderId).delete();
  }

  // Exercise operations
  Future<List<Map<String, dynamic>>> getExercisesById(String routineId) async {
    final exercisesRef = _firestore
        .collection('routines')
        .doc(routineId)
        .collection('exercises');
    final snapshot = await exercisesRef.get();

    List<Map<String, dynamic>> exercises = [];

    for (var exerciseDoc in snapshot.docs) {
      final exerciseData = exerciseDoc.data();

      // ✅ Get sets directly from embedded 'sets' field
      final rawSets = exerciseData['sets'] as List<dynamic>? ?? [];

      final sets = rawSets.map((set) {
        return {
          'set_number': set['set_number'],
          'previous': set['previous'],
          'kg': set['kg'],
          'reps': set['reps'],
          'isCompleted': set['isCompleted'] ?? false,
        };
      }).toList();

      // ✅ Get full exercise info from 'exercises' collection
      final exerciseRef = _firestore
          .collection('exercises')
          .doc(exerciseData['exercise_id']);
      final exerciseSnapshot = await exerciseRef.get();
      final fullData = exerciseSnapshot.data();

      exercises.add({
        'id': exerciseData['exercise_id'],
        'exercise_id': exerciseData['exercise_id'],
        'name': fullData?['name'],
        'description': fullData?['description'],
        'category': fullData?['category'],
        'with_out_equipment': fullData?['with_out_equipment'],
        'image_url': fullData?['image_url'],
        'sets': sets, // ✅ embedded sets returned
      });
    }

    return exercises;
  }

  // Routine operations
  Future<Map<String, dynamic>?> getRoutine(String routineId) async {
    final routineRef = _firestore.collection('routines').doc(routineId);
    final snapshot = await routineRef.get();

    if (!snapshot.exists) return null;

    return {'id': snapshot.id, ...snapshot.data()!};
  }

  Future<List<Map<String, dynamic>>> getRoutinesByIds(
    List<String> routineIds,
  ) async {
    if (routineIds.isEmpty) return [];

    final routinesRef = _firestore.collection('routines');
    final snapshot = await routinesRef.get();

    List<Map<String, dynamic>> routines = [];

    for (var doc in snapshot.docs) {
      if (routineIds.contains(doc.id)) {
        final routineData = doc.data();
        final exercises = await getExercisesById(doc.id);

        routines.add({
          'id': doc.id,
          ...routineData,
          'exercises': exercises,
          'created_at': routineData['created_at'] is Timestamp
              ? (routineData['created_at'] as Timestamp)
                    .toDate()
                    .toIso8601String()
              : null,
        });
      }
    }

    return routines;
  }

  Future<DocumentReference> createNewRoutine(
    String userId,
    String routineName,
    WorkoutSets? workoutSets, {
    String? folderId,
  }) async {
    String finalFolderId = folderId ?? '';

    // Handle default folder if none is provided
    if (finalFolderId.isEmpty) {
      final foldersSnapshot = await _foldersRef(userId).get();

      if (foldersSnapshot.docs.isNotEmpty) {
        finalFolderId = foldersSnapshot.docs.first.id;
      } else {
        final newFolderRef = await createNewFolder(userId, 'Default Folder');
        finalFolderId = newFolderRef.id;
      }
    }

    // Create the routine document
    final routineRef = await _firestore.collection('routines').add({
      'routine_name': routineName,
      'created_at': Timestamp.now(),
    });

    // Add exercises and sets if provided
    if (workoutSets != null) {
      for (var entry in workoutSets.sets.entries) {
        final exerciseId = entry.key;
        final exerciseData = entry.value;

        // Create the exercise subdocument with embedded sets
        final exerciseRef = routineRef.collection('exercises').doc();
        await exerciseRef.set({
          'exercise_id': exerciseId,
          'name': exerciseData.name, // Optional: if you store name
          'sets': exerciseData.sets
              .map(
                (set) => {
                  'set_number': set.setNumber,
                  'previous': set.previous,
                  'kg': set.kg,
                  'reps': set.reps,
                  'isCompleted': set.isCompleted,
                },
              )
              .toList(),
        });
      }
    }

    // Associate the routine with the folder
    await _foldersRef(userId).doc(finalFolderId).update({
      'routine_ids': FieldValue.arrayUnion([routineRef.id]),
    });

    return routineRef;
  }

  Future<void> updateRoutine(
    String routineId, {
    String? updatedRoutineName,
    Map<String, dynamic>? updatedSets,
  }) async {
    final routineRef = _firestore.collection('routines').doc(routineId);

    // Update routine name
    if (updatedRoutineName != null) {
      await routineRef.update({'routine_name': updatedRoutineName});
    }

    if (updatedSets != null) {
      final exercisesRef = routineRef.collection('exercises');

      // Delete all existing embedded exercise documents
      final existingExercisesSnap = await exercisesRef.get();
      for (var doc in existingExercisesSnap.docs) {
        await doc.reference.delete();
      }

      // Re-insert updated exercises with embedded sets
      for (var entry in updatedSets.entries) {
        final exerciseId = entry.key;
        final exerciseData = entry.value as Map<String, dynamic>;

        final sets = (exerciseData['sets'] as List<dynamic>).map((set) {
          final setMap = set as Map<String, dynamic>;
          return {
            'set_number': setMap['set_number'],
            'previous': setMap['previous'] ?? '',
            'kg': setMap['kg'],
            'reps': setMap['reps'],
            'isCompleted': setMap['isCompleted'] ?? false,
          };
        }).toList();

        await exercisesRef.add({
          'exercise_id': exerciseId,
          'name': exerciseData['name'],
          'sets': sets,
        });
      }
    }
  }

  Future<void> deleteRoutine(
    String userId,
    String folderId,
    String routineId,
  ) async {
    // Remove from folder
    await _foldersRef(userId).doc(folderId).update({
      'routine_ids': FieldValue.arrayRemove([routineId]),
    });

    // Delete routine and its subcollections
    final routineRef = _firestore.collection('routines').doc(routineId);
    final exercisesSnap = await routineRef.collection('exercises').get();

    for (var exerciseDoc in exercisesSnap.docs) {
      final setsRef = exerciseDoc.reference.collection('sets');
      final setsSnap = await setsRef.get();

      for (var setDoc in setsSnap.docs) {
        await setDoc.reference.delete();
      }

      await exerciseDoc.reference.delete();
    }

    await routineRef.delete();
  }

  Future<void> deleteFolderAndRoutines(
    String userId,
    String folderId,
    List<String> routineIds,
  ) async {
    // Delete folder
    await deleteFolder(userId, folderId);

    // Delete all routines
    for (String routineId in routineIds) {
      final routineRef = _firestore.collection('routines').doc(routineId);
      final exercisesSnap = await routineRef.collection('exercises').get();

      for (var exerciseDoc in exercisesSnap.docs) {
        final setsSnap = await exerciseDoc.reference.collection('sets').get();

        for (var setDoc in setsSnap.docs) {
          await setDoc.reference.delete();
        }

        await exerciseDoc.reference.delete();
      }

      await routineRef.delete();
    }
  }
}
