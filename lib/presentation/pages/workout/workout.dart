import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/routine/routine.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Workout Tracker REPO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(children: [_buildHeader("Quick Start")]),
                  Button(
                    prefixIcon: Icons.add,
                    label: "Start Empty Workout",
                    onPressed: () {
                      Navigator.pushNamed(context, WorkoutRoutes.logWorkout);
                    },
                    variant: ButtonVariant.secondary,
                    fullWidth: true,
                    size: ButtonSize.large,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Row(children: [_buildHeader("Routines")]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeader("Routines"),
                      GestureDetector(
                        child: Icon(Icons.create_new_folder),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 20,
                                    children: [
                                      Text(
                                        'Create Folder',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Folder Name',
                                          hintStyle: TextStyle(
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        spacing: 10,
                                        children: [
                                          Button(
                                            prefixIcon: Icons.add,
                                            label: 'Create Folder',
                                            width: double.infinity,
                                            onPressed: () {},
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Button(
                                            label: 'Cancel',
                                            width: double.infinity,
                                            textColor: Color(0xFF323232),
                                            variant: ButtonVariant.gray,
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          label: "New Routine",
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              RoutineRoutes.createRoutinePage,
                              (route) => false,
                            );
                          },
                          variant: ButtonVariant.secondary,
                          size: ButtonSize.large,
                          prefixIcon: Icons.grid_view,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Button(
                          label: "Explore",
                          onPressed: () {},
                          variant: ButtonVariant.secondary,
                          size: ButtonSize.large,
                          prefixIcon: Icons.search,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildHeader(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
    );
  }
}
