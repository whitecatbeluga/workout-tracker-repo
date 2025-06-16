import 'package:flutter/cupertino.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/presentation/pages/workout/log_workout.dart';

ValueNotifier<List<Exercise>> workoutExercises = ValueNotifier<List<Exercise>>(
  [],
);
Map<String, List<SetEntry>> savedExerciseSets = {};
