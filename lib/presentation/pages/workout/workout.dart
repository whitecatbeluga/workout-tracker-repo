import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/repositories/routine_repository.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/routes/routine/routine.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

import '../../widgets/collapsible/collapsible.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final user = authService.value.getCurrentUser();

  late Future<List<Folder>> _futureFolders;
  final RoutineRepository _routineRepository = RoutineRepositoryImpl(
    RoutineService(),
  );

  @override
  void initState() {
    super.initState();
    _futureFolders = _routineRepository.getFolders(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
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
            FutureBuilder<List<Folder>>(
              future: _futureFolders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final folders = snapshot.data ?? [];

                if (folders.isEmpty) {
                  return const Center(child: Text("No folders found."));
                }

                return Expanded(
                  // wrap to avoid layout issues
                  child: ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return ListTile(
                        title: Text(folder.folderName ?? 'Unnamed Folder'),
                        subtitle: Text(
                          'Routines: ${folder.routineIds?.length}',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Collapsible(title: "Workout Details", routineFolder:),
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
