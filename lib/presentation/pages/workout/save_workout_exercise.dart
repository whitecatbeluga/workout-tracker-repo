import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/providers/persistent_duration_provider.dart';

import '../../../utils/timer_formatter.dart';

class SaveWorkout extends ConsumerStatefulWidget {
  const SaveWorkout({super.key});

  @override
  ConsumerState<SaveWorkout> createState() => _SaveWorkoutState();
}

class _SaveWorkoutState extends ConsumerState<SaveWorkout> {
  final List<File> _capturedImages = [];
  bool _isUploading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _visibleToEveryone = true;

  final ImagePicker _picker = ImagePicker();

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
        final sets = savedExerciseSets[exercise.name] ?? [];

        totalSets += sets.length;
        totalVolume += sets.fold(
          0,
          (sum, set) => sum + (set.kg * set.reps).round(),
        );

        final exerciseEntry = {
          'exercise_id': exercise.id,
          'exercise_name': exercise.name,
          'sets': sets.map((set) {
            return {
              'set_number': set.setNumber,
              'kg': set.kg,
              'reps': set.reps,
              'is_completed': set.isCompleted,
            };
          }).toList(),
        };

        exercisesData.add(exerciseEntry);
      }

      await FirebaseFirestore.instance.collection('workouts').add({
        'user_id': userId,
        'created_at': FieldValue.serverTimestamp(),
        'image_urls': imageUrls,
        'total_sets': totalSets,
        'total_volume': totalVolume,
        'workout_title': _titleController.text.trim(),
        'workout_description': _descriptionController.text.trim(),
        'workout_duration': durationTime, // Placeholder for now
        'visible_to_everyone': _visibleToEveryone,
        'exercises': exercisesData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout saved successfully!")),
      );

      Navigator.pushNamed(context, AuthRoutes.home);
    } catch (e) {
      print("Error saving workout: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save workout.")));
    } finally {
      setState(() {
        _isUploading = false;
      });
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
                const Text('Save Workout', style: TextStyle(fontSize: 20)),
                GestureDetector(
                  onTap: _isUploading ? null : _saveWorkout,
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
                          Text('Duration', style: TextStyle(fontSize: 16)),
                          Consumer(
                            builder: (context, ref, child) {
                              return Text(
                                durationTime,
                                // Using the formatter function here
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF48A6A7),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Volume', style: TextStyle(fontSize: 16)),
                          Text('0kg', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sets', style: TextStyle(fontSize: 16)),
                          Text('0', style: TextStyle(fontSize: 16)),
                        ],
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

                  GestureDetector(
                    onTap: () {
                      _captureImage();
                    },
                    child: Row(
                      spacing: 20,
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
                        ? const Center(
                            child: Text("No workout data available."),
                          )
                        : ListView.builder(
                            itemCount: workoutExercises.value.length,
                            itemBuilder: (context, index) {
                              final exercise = workoutExercises.value[index];
                              final sets =
                                  savedExerciseSets[exercise.name] ?? [];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ...sets.map((set) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Set ${set.setNumber}'),
                                              Text('${set.kg} kg'),
                                              Text('${set.reps} reps'),
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
