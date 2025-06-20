import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/log_exercise_card.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';

class CreateRoutine extends StatefulWidget {
  const CreateRoutine({super.key});

  @override
  State<CreateRoutine> createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> {
  final Map<String, List<SetEntry>> exerciseSets = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, // disable default back button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                  ),
                ),
              ),
              Text('Create Routine', style: TextStyle(fontSize: 20)),
              GestureDetector(
                onTap: () {}, // your save action
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFF48A6A7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              style: TextStyle(
                color: Color(0xFF626262),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Routine Title',
                hintStyle: TextStyle(
                  color: Color(0xFF626262).withValues(alpha: 0.5),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),

                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: LogExerciseCard(
                workoutExercises: routineExercises,
                exerciseSets: exerciseSets,
              ),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Button(
          label: 'Add Exercise',
          prefixIcon: Icons.add,
          onPressed: () => Navigator.pushNamed(
            context,
            ExerciseRoutes.addWorkoutExercise,
            arguments: {'isLogWorkout': false},
          ),
          variant: ButtonVariant.secondary,
          fullWidth: true,
          size: ButtonSize.large,
        ),
      ),
    );
  }
}
