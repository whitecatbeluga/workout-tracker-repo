import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/providers/persistent_duration_provider.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

class WorkoutNav extends ConsumerStatefulWidget {
  const WorkoutNav({super.key});

  @override
  ConsumerState<WorkoutNav> createState() => _WorkoutNavState();
}

class _WorkoutNavState extends ConsumerState<WorkoutNav> {
  void _navigateToPage() {
    Navigator.pushNamed(context, WorkoutRoutes.logWorkout);
  }

  void _showWorkoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                Text(
                  "Are you sure you want to dismiss this workout?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Column(
                  spacing: 10,
                  children: [
                    Button(
                      label: "Dismiss Workout",
                      prefixIcon: Icons.delete_forever,
                      backgroundColor: Colors.white,
                      textColor: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                      fullWidth: true,
                      onPressed: () {
                        workoutExercises.value = [];
                        savedExerciseSets = {};

                        ref
                                .read(workoutElapsedDurationProvider.notifier)
                                .state =
                            Duration.zero;
                        Navigator.of(context).pop();
                      },
                    ),
                    Button(
                      label: 'Cancel',
                      textColor: Color(0xFF323232),
                      fullWidth: true,
                      variant: ButtonVariant.gray,
                      fontWeight: FontWeight.w500,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavButton(
              icon: Icons.play_arrow_rounded,
              label: 'Continue Workout',
              onTap: _navigateToPage,
            ),
            _NavButton(
              icon: Icons.close_rounded,
              label: 'Discard Workout',
              onTap: _showWorkoutDialog,
              iconColor: Colors.red.shade900,
              textColor: Colors.red.shade900,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.teal,
    this.textColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: iconColor),
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }
}
