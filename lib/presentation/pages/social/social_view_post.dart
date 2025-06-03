import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/workout_detail_card.dart';

class ViewPost extends StatelessWidget {
  const ViewPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(centerTitle: true, title: Text('Workout Detail')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(0),
              child: PostCard(
                name: 'Philippe',
                email: 'philippetan99@gmail.com',
              ),
            ),
            Container(
              padding: EdgeInsets.all(0),
              child: WorkoutDetail(
                exerciseName: 'Dumbbell Goblet Squat',
                sets: [
                  WorkoutSet(setNumber: 1, weightAndReps: '20kg x 12 reps'),
                  WorkoutSet(setNumber: 2, weightAndReps: '25kg x 10 reps'),
                  WorkoutSet(setNumber: 3, weightAndReps: '30kg x 8 reps'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
