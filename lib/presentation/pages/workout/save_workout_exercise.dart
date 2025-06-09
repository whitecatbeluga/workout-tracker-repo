import 'dart:io';
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

  Future<void> _captureImage() async {
    if (_capturedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can only capture up to 3 images.")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Log Workout', style: TextStyle(fontSize: 20)),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AuthRoutes.home);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF48A6A7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Next',
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
            ElevatedButton.icon(
              onPressed: _captureImage,
              icon: Icon(Icons.camera_alt),
              label: Text('Capture Image'),
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
    );
  }
}
