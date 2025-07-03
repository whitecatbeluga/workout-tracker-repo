import '../../domain/entities/routine.dart';

abstract class PredefinedRoutineRepository {
  Stream<List<Routine>> streamPredefinedRoutines();
  Future<Routine> getPredefinedRoutine(String routineId);
}
