import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/workout_detail_card.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import '../../../domain/entities/social_with_username.dart';

class ViewPost extends StatelessWidget {
  const ViewPost({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! SocialWithUserName) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Detail')),
        body: const Center(child: Text('No post data found')),
      );
    }
    final post = args;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Workout Detail'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            PostCard(
              data: post,
              viewProfileOnTap: () {
                Navigator.pushNamed(
                  context,
                  SocialRoutes.visitProfile,
                  arguments: {'name': post.userName},
                );
              },
            ),
            WorkoutDetail(
              exerciseName: 'Dumbbell Goblet Squat',
              sets: [
                WorkoutSet(setNumber: 1, weightAndReps: '20kg x 12 reps'),
                WorkoutSet(setNumber: 2, weightAndReps: '25kg x 10 reps'),
                WorkoutSet(setNumber: 3, weightAndReps: '30kg x 8 reps'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
