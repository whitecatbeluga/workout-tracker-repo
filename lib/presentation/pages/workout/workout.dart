import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

import '../../domain/entities/program.dart';
import '../../widgets/collapsible/collapsible.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.value.getCurrentUser();

    ProgramState programState = ProgramState(
      programs: [
        Program(
          id: '1',
          programName: 'Program 1',
          routines: [
            Routine(
              id: '1',
              routineName: 'Routine 1',
              exercises: [
                Exercise(
                  id: '1',
                  name: 'Exercise 1',
                  description: 'Description 1',
                  category: 'Category 1',
                  withOutEquipment: true,
                  imageUrl: 'https://example.com/exercise1.jpg',
                  sets: [
                    WorkoutSet(
                      exerciseId: '1',
                      name: 'Set 1',
                      sets: [
                        SetDetail(
                          set: 1,
                          previous: '0',
                          kg: '0',
                          reps: '0',
                          checked: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.value.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AuthRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          "Quick Start",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Button(
                    label: "Start Workout",
                    onPressed: () {
                      Navigator.pushNamed(context, WorkoutRoutes.logWorkout);
                    },
                    variant: ButtonVariant.primary,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          "Routines",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          label: "Start Routine",
                          onPressed: () {},
                          variant: ButtonVariant.primary,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Button(
                          label: "Explore",
                          onPressed: () {},
                          variant: ButtonVariant.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Collapsible(title: "Workout Details", program: programState),
          ],
        ),
      ),
    );
  }
}
