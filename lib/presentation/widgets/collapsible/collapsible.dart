import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/domain/entities/upsert_routine_args.dart';
import 'package:workout_tracker_repo/domain/repositories/routine_repository.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/set_entry.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/providers/persistent_duration_provider.dart';
import 'package:workout_tracker_repo/routes/routine/routine.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';
import '../../../domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart' as base;

class Collapsible extends ConsumerStatefulWidget {
  const Collapsible({super.key, required this.folderContent});

  final Folder folderContent;

  @override
  ConsumerState<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends ConsumerState<Collapsible> {
  bool _isExpanded = true;
  final user = authService.value.getCurrentUser();
  final TextEditingController _folderNameController = TextEditingController();
  final RoutineRepository _routineRepository = RoutineRepositoryImpl(
    RoutineService(),
  );

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
  }

  // methods
  void _updateFolder() async {
    final newFolderName = _folderNameController.text.trim();

    if (newFolderName.isNotEmpty) {
      try {
        await _routineRepository.updateFolderName(
          user!.uid,
          widget.folderContent.id,
          newFolderName,
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Folder updated successfully!')));

        setState(() {
          _folderNameController.clear();
        });
      } catch (e) {
        print('Error creating folder: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update folder. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Folder name cannot be empty.')));
    }
  }

  void _deleteFolder() async {
    final isEmpty = widget.folderContent.routines?.isEmpty ?? true;

    try {
      if (isEmpty) {
        await _routineRepository.deleteFolder(
          user!.uid,
          widget.folderContent.id,
        );
      } else {
        await _routineRepository.deleteFolderAndRoutines(
          user!.uid,
          widget.folderContent.id,
          widget.folderContent.routineIds!,
        );
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting folder: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete folder. Please try again.'),
        ),
      );
    }
  }

  void _deleteRoutine(String routineId) async {
    try {
      await _routineRepository.deleteRoutine(
        user!.uid,
        widget.folderContent.id,
        routineId,
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Folder deleted successfully!')));
    } catch (e) {
      print('Error creating folder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete folder. Please try again.')),
      );
    }
  }

  // bottom sheets
  void _openFolderMenu() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          heightFactor: 0.5,
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.folderContent.folderName ?? "",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Button(
                    label: "Update Folder Name",
                    prefixIcon: Icons.edit_note,
                    variant: ButtonVariant.primary,
                    fontWeight: FontWeight.w500,
                    fullWidth: true,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      _openUpdateFolderNameDialog();
                    },
                  ),
                  Button(
                    label: (widget.folderContent.routines?.isEmpty ?? true)
                        ? "Delete Folder"
                        : "Delete Folder and Routines",
                    prefixIcon: Icons.delete_forever,
                    backgroundColor: Colors.white,
                    textColor: Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                    fullWidth: true,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      _openDeleteFolderDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openRoutineMenu(Routine routine) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.routineName ?? "",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Button(
                    label: "View Routine",
                    prefixIcon: Icons.view_carousel,
                    variant: ButtonVariant.primary,
                    fontWeight: FontWeight.w500,
                    fullWidth: true,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        RoutineRoutes.viewRoutine,
                        arguments: routine.id,
                      );
                    },
                  ),
                  Button(
                    label: "Update Routine",
                    prefixIcon: Icons.edit_note,
                    variant: ButtonVariant.primary,
                    fontWeight: FontWeight.w500,
                    fullWidth: true,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        RoutineRoutes.upsertRoutinePage,
                        arguments: UpsertRoutineArgs(
                          folderId: widget.folderContent.id,
                          routine: routine,
                        ),
                      );
                    },
                  ),
                  Button(
                    label: "Delete Routine",
                    prefixIcon: Icons.delete_forever,
                    backgroundColor: Colors.white,
                    textColor: Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                    fullWidth: true,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      _openDeleteRoutineDialog(routine.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // dialogs
  void _openUpdateFolderNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                  'Update Folder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _folderNameController,
                  decoration: InputDecoration(
                    // hintText: 'Folder Name',
                    hintText: widget.folderContent.folderName ?? "",
                    hintStyle: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
                Column(
                  spacing: 10,
                  children: [
                    Button(
                      label: 'Save',
                      width: double.infinity,
                      onPressed: () => _updateFolder(),
                    ),
                    Button(
                      label: 'Cancel',
                      textColor: Color(0xFF323232),
                      width: double.infinity,
                      variant: ButtonVariant.gray,
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

  void _openDeleteFolderDialog() {
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
                  (widget.folderContent.routines?.isEmpty ?? true)
                      ? "Are you sure you want to delete this folder?"
                      : "Are you sure you want to delete this folder and its routines",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Column(
                  spacing: 10,
                  children: [
                    Button(
                      label: (widget.folderContent.routines?.isEmpty ?? true)
                          ? "Delete Folder"
                          : "Delete Folder and Routines",
                      prefixIcon: Icons.delete_forever,
                      backgroundColor: Colors.white,
                      textColor: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                      fullWidth: true,
                      onPressed: () => _deleteFolder(),
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

  void _openDeleteRoutineDialog(String routineId) {
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
                      label: "Delete Routine",
                      prefixIcon: Icons.delete_forever,
                      backgroundColor: Colors.white,
                      textColor: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                      fullWidth: true,
                      onPressed: () => _deleteRoutine(routineId),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggleExpand,
                  child: Row(
                    spacing: 6,
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 30,
                        color: Color(0xFF323232),
                      ),
                      Text(
                        widget.folderContent.folderName ?? "",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 30,
                  color: Color(0xFF323232),
                ),
                onTap: () {
                  _openFolderMenu();
                },
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: (widget.folderContent.routines?.isEmpty ?? true)
                ? Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Button(
                            label: "Add Routine",
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                RoutineRoutes.upsertRoutinePage,
                                arguments: UpsertRoutineArgs(
                                  folderId: widget.folderContent.id,
                                  routine: null,
                                ),
                              );
                            },
                            prefixIcon: Icons.add,
                            fullWidth: true,
                            size: ButtonSize.large,
                            borderColor: Color(0xFF006A71),
                            borderWidth: .5,
                            backgroundColor: Colors.white,
                            textColor: Color(0xFF006A71),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: widget.folderContent.routines!.map((routine) {
                      final exercises = routine.exercises ?? [];

                      return Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  routine.routineName ?? 'Unnamed Routine',
                                  style: const TextStyle(
                                    color: Color(0xFF323232),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _openRoutineMenu(routine),
                                  child: Icon(
                                    Icons.more_horiz,
                                    size: 30,
                                    color: Color(0xFF323232),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Exercises
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: exercises.map((exercise) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    exercise.name,
                                    style: const TextStyle(
                                      color: Color(0xFF626262),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            // Start Button
                            Button(
                              label: "Start Routine",
                              onPressed: () {
                                if (workoutExercises.value.isNotEmpty) {
                                  _openWorkoutDialog();
                                } else {
                                  // Set workout exercises (just metadata)
                                  workoutExercises.value = exercises.map((e) {
                                    return base.Exercise(
                                      id: e.id,
                                      name: e.name,
                                      description: e.description,
                                      imageUrl: e.imageUrl,
                                      category: e.category,
                                      withoutEquipment: e.withOutEquipment,
                                    );
                                  }).toList();

                                  // Clear old sets
                                  savedExerciseSets.clear();

                                  // Add sets from each exercise
                                  for (final exercise in exercises) {
                                    savedExerciseSets[exercise.id] = exercise
                                        .sets
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final set = entry.value;
                                          return SetEntry(
                                            setNumber: entry.key + 1,
                                            previous:
                                                "${set.kg}kg x ${set.reps}",
                                            kg: set.kg,
                                            reps: set.reps,
                                            isCompleted: false,
                                          );
                                        })
                                        .toList();
                                  }

                                  // Navigate
                                  Navigator.pushNamed(
                                    context,
                                    WorkoutRoutes.logWorkout,
                                  );
                                }
                              },
                              prefixIcon: Icons.play_arrow_rounded,
                              fullWidth: true,
                              size: ButtonSize.large,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
