import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/workout_detail_card.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import '../../../domain/entities/social_with_user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OptionsBottomSheet extends StatefulWidget {
  final String workoutId;

  const OptionsBottomSheet({super.key, required this.workoutId});

  @override
  State<OptionsBottomSheet> createState() => _OptionsBottomSheetState();
}

class _OptionsBottomSheetState extends State<OptionsBottomSheet> {
  final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

  void _openConfirmDelete(BuildContext parentContext) {
    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    showDialog(
      context:
          parentContext, // Still using the parent context to show the dialog
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete this workout?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Button(
                  label: "Delete Workout",
                  prefixIcon: Icons.delete_forever,
                  backgroundColor: Colors.white,
                  textColor: Colors.red.shade800,
                  fontWeight: FontWeight.w500,
                  fullWidth: true,
                  onPressed: () async {
                    Navigator.pop(dialogContext); // Close dialog only

                    await repository.deleteWorkout(workoutId: widget.workoutId);

                    if (!mounted) return;

                    Navigator.pop(parentContext); // Close bottom sheet
                    Navigator.pop(parentContext); // Go back to previous screen

                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Workout deleted successfully'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Button(
                  label: 'Cancel',
                  textColor: Color(0xFF323232),
                  fullWidth: true,
                  variant: ButtonVariant.gray,
                  fontWeight: FontWeight.w500,
                  onPressed: () {
                    Navigator.pop(dialogContext); // Only close the dialog
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 120,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {},
                child: Row(
                  spacing: 10,
                  children: [
                    FaIcon(FontAwesomeIcons.pencil, size: 20),
                    Text('Edit Workout', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _openConfirmDelete(context);
                },
                child: Row(
                  spacing: 10,
                  children: [
                    FaIcon(FontAwesomeIcons.x, color: Colors.red),
                    Text(
                      'Delete Workout',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewPost extends StatefulWidget {
  const ViewPost({super.key});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  final user = authService.value.getCurrentUser();

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
        actions: [
          if (user!.uid == post.social.uid)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return OptionsBottomSheet(workoutId: post.social.id);
                  },
                );
              },
              icon: const Icon(Icons.more_vert),
            ),
        ],
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
