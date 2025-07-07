import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/domain/entities/social_with_user.dart';
import 'package:workout_tracker_repo/presentation/pages/workout/confetti_workout.dart';
import 'package:workout_tracker_repo/providers/persistent_duration_provider.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';

import '../../../providers/persistent_volume_set_provider.dart';
import '../../../utils/timer_formatter.dart';
import '../../domain/entities/set_entry.dart';

class SaveWorkout extends ConsumerStatefulWidget {
  final Map<String, List<SetEntry>>? exerciseSets;
  final String? type;
  final SocialWithUser? data;

  const SaveWorkout({super.key, this.exerciseSets, this.type, this.data});

  @override
  ConsumerState<SaveWorkout> createState() => _SaveWorkoutState();
}

class _SaveWorkoutState extends ConsumerState<SaveWorkout> {
  final List<File> _capturedImages = [];
  bool _isUploading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _visibleToEveryone = true;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'edit-workout' && widget.data != null) {
      _titleController.text = widget.data!.social.workoutTitle;
      _descriptionController.text = widget.data!.social.workoutDescription;
      _visibleToEveryone = widget.data!.social.visibleToEveryone;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_capturedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only capture up to 3 images.")),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _capturedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    final storage = FirebaseStorage.instance;
    final List<String> downloadUrls = [];

    for (var image in _capturedImages) {
      try {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = storage.ref().child('workout_images/$fileName.jpg');

        final uploadTask = ref.putFile(image);
        await uploadTask.whenComplete(() {});

        final url = await ref.getDownloadURL();
        downloadUrls.add(url);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }

    return downloadUrls;
  }

  Future<void> _saveWorkout() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a workout title.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";
      final imageUrls = await _uploadImages();
      final seconds = ref.read(workoutElapsedDurationProvider).inSeconds;
      final durationTime = formatDuration(seconds);
      int totalSets = 0;
      int totalVolume = 0;

      List<Map<String, dynamic>> exercisesData = [];

      for (var exercise in workoutExercises.value) {
        final sets = widget.exerciseSets?[exercise.id] ?? [];
        totalSets += sets.length;
        totalVolume += sets.fold(
          0,
          (sum, set) => sum + (set.kg * set.reps).round(),
        );

        exercisesData.add({
          'exercise_id': exercise.id,
          'exercise_name': exercise.name,
          'image_url': exercise.imageUrl,
          'sets': sets.map((set) => set.toMap()).toList(),
        });
      }

      await FirebaseFirestore.instance.collection('workouts').add({
        'user_id': userId,
        'created_at': FieldValue.serverTimestamp(),
        'image_urls': imageUrls,
        'total_sets': totalSets,
        'total_volume': totalVolume,
        'workout_title': _titleController.text.trim(),
        'workout_description': _descriptionController.text.trim(),
        'workout_duration': durationTime,
        'visible_to_everyone': _visibleToEveryone,
        'exercises': exercisesData,
      });

      // Clear all workout state before navigating
      workoutExercises.value.clear();
      widget.exerciseSets?.clear();
      ref.read(workoutElapsedDurationProvider.notifier).state = Duration.zero;
      ref.read(volumeSetProvider.notifier).reset();

      setState(() {
        _isUploading = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ConfettiWorkout()),
        (route) => false,
      );
    } catch (e) {
      print("Error saving workout: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save workout.")));
    }
  }

  Future<void> _editWorkout() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a workout title.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(widget.data!.social.id)
          .update({
            'workout_title': _titleController.text.trim(),
            'workout_description': _descriptionController.text.trim(),
            'visible_to_everyone': _visibleToEveryone,
          });

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout updated successfully.")),
      );

      // Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      print("Error updating workout: $e");
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update workout.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final seconds = ref.read(workoutElapsedDurationProvider).inSeconds;
    final durationTime = formatDuration(seconds);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.type == 'edit-workout'
                      ? "Edit Workout"
                      : "Save Workout",
                  style: TextStyle(fontSize: 20),
                ),
                GestureDetector(
                  onTap: _isUploading
                      ? null
                      : () {
                          if (widget.type == 'edit-workout') {
                            _editWorkout();
                          } else {
                            _saveWorkout();
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isUploading
                          ? Colors.grey
                          : const Color(0xFF48A6A7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Title input
                  TextField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Workout Title',
                      hintStyle: TextStyle(fontWeight: FontWeight.normal),
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    enabled: !_isUploading,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    spacing: 70,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duration',
                            style: TextStyle(fontSize: 16),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final durationDisplay =
                                  widget.type == 'edit-workout'
                                  ? widget.data!.social.workoutDuration
                                  : durationTime;

                              return Text(
                                durationDisplay,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF48A6A7),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      Consumer(
                        builder: (context, ref, child) {
                          final volumeState = ref.watch(volumeSetProvider);

                          final volumeDisplay =
                              widget.type == 'edit-workout' &&
                                  widget.data != null
                              ? widget.data!.social.totalVolume.toString()
                              : volumeState.totalVolume.round().toString();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Volume',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                volumeDisplay,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          );
                        },
                      ),

                      Consumer(
                        builder: (context, ref, child) {
                          final volumeState = ref.watch(volumeSetProvider);

                          final setsDisplay =
                              widget.type == 'edit-workout' &&
                                  widget.data != null
                              ? widget.data!.social.totalSets.toString()
                              : volumeState.totalSets.toString();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sets',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                setsDisplay,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('When', style: TextStyle(fontSize: 16)),
                          Text(
                            '28, Apr 2025, 9:14 AM',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF48A6A7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (widget.type != 'edit-workout')
                    GestureDetector(
                      onTap: () {
                        _captureImage();
                      },
                      child: Row(
                        children: [
                          DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            borderType: BorderType.RRect,
                            radius: Radius.circular(4),
                            dashPattern: [6, 3],
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Icon(Icons.photo, color: Colors.grey),
                            ),
                          ),
                          Text(
                            'Add a Photo / Video',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  Container(
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description'),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText:
                                'How did your workout go? Leave some notes here...',
                            border: InputBorder.none,
                          ),
                          maxLines: 3,
                          enabled: !_isUploading,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Visibility', style: TextStyle(fontSize: 16)),

                      GestureDetector(
                        onTap: _isUploading
                            ? null
                            : () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) => OptionsBottomSheet(
                                    selectedOption: _visibleToEveryone
                                        ? 'Everyone'
                                        : 'Private',
                                    onOptionSelected: (newValue) {
                                      setState(() {
                                        _visibleToEveryone =
                                            newValue == 'Everyone';
                                      });
                                    },
                                  ),
                                );
                              },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Text(
                              _visibleToEveryone ? 'Everyone' : 'Private',
                              style: TextStyle(
                                fontSize: 16,
                                color: _isUploading
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: _isUploading ? Colors.grey : Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Visible to everyone toggle
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       'Visible to Everyone',
                  //       style: TextStyle(fontSize: 16),
                  //     ),
                  //     Switch(
                  //       value: _visibleToEveryone,
                  //       onChanged: _isUploading
                  //           ? null
                  //           : (val) {
                  //               setState(() {
                  //                 _visibleToEveryone = val;
                  //               });
                  //             },
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 12),

                  // ElevatedButton.icon(
                  //   onPressed: _isUploading ? null : _captureImage,
                  //   icon: const Icon(Icons.camera_alt),
                  //   label: const Text('Capture Image'),
                  // ),
                  const SizedBox(height: 10),
                  if (_capturedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _capturedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.file(_capturedImages[index]),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: workoutExercises.value.isEmpty
                        ? Center(
                            child: Text(
                              widget.type == "edit-workout"
                                  ? ""
                                  : "No exercises added",
                            ),
                          )
                        : ListView.builder(
                            itemCount: workoutExercises.value.length,
                            itemBuilder: (context, index) {
                              final exercise = workoutExercises.value[index];
                              final sets =
                                  widget.exerciseSets?[exercise.id] ?? [];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Exercise Name with Image
                                      Row(
                                        children: [
                                          // Exercise Image
                                          if (exercise.imageUrl != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                exercise.imageUrl!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.fitness_center,
                                              size: 50,
                                            ),
                                          const SizedBox(width: 12),
                                          // Exercise Name
                                          Expanded(
                                            child: Text(
                                              exercise.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Sets List
                                      if (sets.isNotEmpty) ...[
                                        const Divider(),
                                        ...sets.map((set) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                // Set Number
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    'Set ${set.setNumber}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                // Weight and Reps
                                                Expanded(
                                                  child: Text(
                                                    '${set.kg}kg x ${set.reps}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                // Completion Icon
                                                Icon(
                                                  set.isCompleted
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color: set.isCompleted
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ] else ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          'No sets recorded',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isUploading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class OptionsBottomSheet extends StatefulWidget {
  final String selectedOption;
  final void Function(String) onOptionSelected;

  const OptionsBottomSheet({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  State<OptionsBottomSheet> createState() => _OptionsBottomSheetState();
}

class _OptionsBottomSheetState extends State<OptionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildOption('Everyone'), _buildOption('Private')],
      ),
    );
  }

  Widget _buildOption(String option) {
    final isSelected = widget.selectedOption == option;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(option),
      onTap: () {
        widget.onOptionSelected(option);
        Navigator.pop(context);
      },
    );
  }
}
