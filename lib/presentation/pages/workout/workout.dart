import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/entities/upsert_routine_args.dart';
import 'package:workout_tracker_repo/domain/repositories/routine_repository.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/collapsible/collapsible.dart';
import 'package:workout_tracker_repo/providers/persistent_duration_provider.dart';
import 'package:workout_tracker_repo/routes/routine/routine.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  final user = authService.value.getCurrentUser();
  final RoutineRepository _routineRepository = RoutineRepositoryImpl(
    RoutineService(),
  );
  final TextEditingController _folderNameController = TextEditingController();

  void _showFolderPickerModal(BuildContext context, List<Folder> folders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1.0, // 🔥 This makes it take full width
          child: Padding(
            padding: MediaQuery.of(context).viewInsets, // handles keyboard
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Folder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ...folders.map((folder) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close the bottom sheet
                          Navigator.pushNamed(
                            context,
                            RoutineRoutes.upsertRoutinePage,
                            arguments: UpsertRoutineArgs(
                              folderId: folder.id,
                              routine: null,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.folder,
                          color: Color(0xFF323232),
                        ),
                        label: Text(
                          folder.folderName ?? 'Unnamed Folder',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF323232),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: const Color(0xFF323232),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _createFolder() async {
    final name = _folderNameController.text.trim();

    if (name.isNotEmpty) {
      try {
        await _routineRepository.createFolder(user!.uid, name);

        Navigator.of(context).pop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Folder created successfully!')));

        setState(() {
          _folderNameController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create folder. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Folder name cannot be empty.')));
    }
  }

  void _openWorkoutDialog() {
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
                  "Are you sure you want to delete this routine?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Column(
                  spacing: 10,
                  children: [
                    Button(
                      label: "Start New Empty Workout",
                      prefixIcon: Icons.add,
                      variant: ButtonVariant.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fullWidth: true,
                      size: ButtonSize.large,
                      onPressed: () {
                        Navigator.pop(context);

                        workoutExercises.value = [];
                        savedExerciseSets = {};

                        ref
                                .read(workoutElapsedDurationProvider.notifier)
                                .state =
                            Duration.zero;

                        Navigator.pushNamed(context, WorkoutRoutes.logWorkout);
                      },
                    ),
                    Button(
                      label: "Discard Workout",
                      prefixIcon: Icons.delete_forever,
                      backgroundColor: Colors.white,
                      textColor: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.pop(context);

                        workoutExercises.value = [];
                        savedExerciseSets = {};

                        ref
                                .read(workoutElapsedDurationProvider.notifier)
                                .state =
                            Duration.zero;
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
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
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
                      if (workoutExercises.value.isNotEmpty) {
                        _openWorkoutDialog();
                      } else {
                        Navigator.pushNamed(context, WorkoutRoutes.logWorkout);
                      }
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
                                        controller: _folderNameController,
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
                                            onPressed: () => _createFolder(),
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
                          onPressed: () async {
                            final folders = await _routineRepository
                                .streamFolders(user!.uid)
                                .first;

                            if (folders.isNotEmpty) {
                              _showFolderPickerModal(context, folders);
                            } else {
                              Navigator.pushNamed(
                                context,
                                RoutineRoutes.upsertRoutinePage,
                                arguments: UpsertRoutineArgs(
                                  folderId: '',
                                  routine: null,
                                ),
                              );
                            }
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
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RoutineRoutes.exploreRoutines,
                            );
                          },
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
            StreamBuilder<List<Folder>>(
              stream: _routineRepository.streamFolders(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final List<Folder> folders = snapshot.data ?? [];

                if (folders.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/empty-folder.png",
                          width: 300,
                          height: 300,
                        ),
                        SizedBox(
                          width: 350,
                          child: Text(
                            "It looks like you don't have any routines yet. Create a new one to get started!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF323232),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return Collapsible(folderContent: folder);
                    },
                  ),
                );
              },
            ),
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
