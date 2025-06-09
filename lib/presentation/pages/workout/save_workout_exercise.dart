import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';

class SaveWorkout extends StatefulWidget {
  const SaveWorkout({super.key});

  @override
  State<SaveWorkout> createState() => _SaveWorkoutState();
}

class _SaveWorkoutState extends State<SaveWorkout> {
  final List<File> _capturedImages = [];
  bool _isUploading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _visibleToEveryone = true;

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

      int totalSets = 0;
      int totalVolume = 0;

      for (var exercise in workoutExercises.value) {
        final sets = savedExerciseSets[exercise.name] ?? [];
        totalSets += sets.length;
        totalVolume += sets.fold(
          0,
          (sum, set) => sum + (set.kg * set.reps).round(),
        );
      }

      await FirebaseFirestore.instance.collection('workouts').add({
        'user_id': userId,
        'created_at': FieldValue.serverTimestamp(),
        'image_urls': imageUrls,
        'total_sets': totalSets,
        'total_volume': totalVolume,
        'workout_title': _titleController.text.trim(),
        'workout_description': _descriptionController.text.trim(),
        'workout_duration': '23', // Could be improved later
        'visible_to_everyone': _visibleToEveryone,
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
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Log Workout', style: TextStyle(fontSize: 20)),
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Title input
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Workout Title',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isUploading,
                ),
                const SizedBox(height: 12),

                // Description input
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Workout Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: !_isUploading,
                ),
                const SizedBox(height: 12),

                // Visible to everyone toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Visible to Everyone',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: _visibleToEveryone,
                      onChanged: _isUploading
                          ? null
                          : (val) {
                              setState(() {
                                _visibleToEveryone = val;
                              });
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _captureImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Image'),
                ),
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
                      ? const Center(child: Text("No workout data available."))
                      : ListView.builder(
                          itemCount: workoutExercises.value.length,
                          itemBuilder: (context, index) {
                            final exercise = workoutExercises.value[index];
                            final sets = savedExerciseSets[exercise.name] ?? [];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
