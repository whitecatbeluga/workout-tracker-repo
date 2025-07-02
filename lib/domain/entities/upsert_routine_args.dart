import 'package:workout_tracker_repo/domain/entities/routine.dart';

class UpsertRoutineArgs {
  final String folderId;
  final Routine? routine;

  UpsertRoutineArgs({required this.folderId, this.routine});
}
