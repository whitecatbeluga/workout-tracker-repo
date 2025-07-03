import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';

import '../models/routine_model.dart';
import '../services/predefined_routine_service.dart';
import '../../domain/repositories/predefined_routine_repository.dart';

class PredefinedRoutineRepositoryImpl implements PredefinedRoutineRepository {
  final PredefinedRoutineService _service;

  PredefinedRoutineRepositoryImpl(this._service);

  @override
  Stream<List<Routine>> streamPredefinedRoutines() async* {
    final routineStream = _service.streamRoutines();

    await for (final docs in routineStream) {
      List<Routine> routines = [];

      for (final doc in docs) {
        final routineData = doc.data();
        final routineId = doc.id;
        final exercisesData = await _service.getExercises(routineId);

        final exercises = exercisesData.map((exercise) {
          final sets = (exercise['sets'] as List).map((setData) {
            return SetDetailModel.fromMap(setData as Map<String, dynamic>);
          }).toList();

          return ExerciseModel(
            id: exercise['exercise_id'],
            name: exercise['name'] ?? '',
            description: exercise['description'] ?? '',
            category: exercise['category'] ?? '',
            withOutEquipment: exercise['with_out_equipment'] ?? false,
            imageUrl: exercise['image_url'] ?? '',
            sets: sets,
          );
        }).toList();

        routines.add(
          RoutineModel(
            id: routineId,
            routineName: routineData['routine_name'],
            createdAt: routineData['createdAt'] is Timestamp
                ? (routineData['createdAt'] as Timestamp)
                      .toDate()
                      .toIso8601String()
                : routineData['createdAt']?.toString(),
            exercises: exercises,
          ),
        );
      }

      yield routines;
    }
  }

  @override
  Future<Routine> getPredefinedRoutine(String routineId) async {
    final routineMap = await _service.getRoutine(routineId);
    if (routineMap == null) throw Exception("Routine not found");

    final exercisesData = await _service.getExercises(routineId);
    final exercises = exercisesData.map((exercise) {
      final sets = (exercise['sets'] as List).map((setData) {
        return SetDetailModel.fromMap(setData as Map<String, dynamic>);
      }).toList();

      return ExerciseModel(
        id: exercise['exercise_id'],
        name: exercise['name'] ?? '',
        description: exercise['description'] ?? '',
        category: exercise['category'] ?? '',
        withOutEquipment: exercise['with_out_equipment'] ?? false,
        imageUrl: exercise['image_url'] ?? '',
        sets: sets,
      );
    }).toList();

    return RoutineModel(
      id: routineMap['id'],
      routineName: routineMap['routine_name'],
      createdAt: routineMap['createdAt'] is Timestamp
          ? (routineMap['createdAt'] as Timestamp).toDate().toIso8601String()
          : routineMap['createdAt']?.toString(),
      exercises: exercises,
    );
  }
}
