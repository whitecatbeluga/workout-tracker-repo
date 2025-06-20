import 'package:flutter/cupertino.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';

ValueNotifier<List<Exercise>> workoutExercises = ValueNotifier<List<Exercise>>(
  [],
);
ValueNotifier<List<Exercise>> routineExercises = ValueNotifier<List<Exercise>>(
  [],
);

Map<String, List<SetEntry>> savedExerciseSets = {};
