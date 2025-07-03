import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/workout_detail_card.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import '../../../domain/entities/social_with_user.dart';

class ViewPost extends StatelessWidget {
  const ViewPost({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! SocialWithUser) {
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
                  arguments: {
                    'id': post.social.uid,
                    'accountPicture': post.accountPicture,
                    'firstName': post.firstName,
                    'lastName': post.lastName,
                    'userName': post.userName,
                    'email': post.email,
                  },
                );
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(13, 12, 12, 0),
              child: Text(
                'Workout',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            ...post.exercises.map((exercise) {
              return WorkoutDetail(
                exerciseName: exercise['exercise_name'] as String,
                sets: (exercise['sets'] as List<dynamic>)
                    .map(
                      (set) => WorkoutSet(
                        setNumber: (set['set_number'] as num).toInt(),
                        weightAndReps: '${set['kg']}kg x ${set['reps']} reps',
                      ),
                    )
                    .toList(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
