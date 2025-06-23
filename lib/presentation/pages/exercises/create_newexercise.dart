import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/exercise_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/exercise_service.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';

class CreateNewExercisePage extends StatefulWidget {
  const CreateNewExercisePage({super.key});

  @override
  State<CreateNewExercisePage> createState() => _CreateNewExercisePageState();
}

class _CreateNewExercisePageState extends State<CreateNewExercisePage> {
  final user = authService.value.getCurrentUser();
  final exerciserepo = ExerciseRepositoryImpl(ExerciseService());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();

  bool withEquipment = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedImage = File(picked.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Use Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedImage = File(picked.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> uploadExerciseImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance
          .ref()
          .child('exercise_images')
          .child('$fileName.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    isloading = true;
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadExerciseImage(_selectedImage!);
      } else {
        imageUrl = '';
      }

      final exercise = Exercise(
        id: '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        category: _categoryController.text.trim(),
        withoutEquipment: withEquipment,
      );

      await exerciserepo.addExercise(exercise, user!.uid);

      if (mounted) {
        isloading = false;
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        isloading = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                ),
              ),
            ),
            const Text('Custom Exercise', style: TextStyle(fontSize: 20)),
            GestureDetector(
              onTap: _submitForm,
              child: Container(
                margin: const EdgeInsets.only(right: 5),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InputImage(onTap: _pickImage, imageFile: _selectedImage),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 165, 165, 165),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                    hintText: 'Exercise Name',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 165, 165, 165),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                InputWidget(label: 'Description', controller: _descController),
                InputWidget(label: 'Category', controller: _categoryController),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'With Equipment',
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          activeColor: const Color(0xFF006A71),
                          value: withEquipment,
                          onChanged: (value) {
                            setState(() {
                              withEquipment = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const InputWidget({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: Color(0xFFEEEEEE)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: Color(0xFFEEEEEE)),
        ),
        floatingLabelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

class InputImage extends StatelessWidget {
  final VoidCallback onTap;
  final File? imageFile;

  const InputImage({super.key, required this.onTap, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(78, 182, 182, 182),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 32,
                    color: Color(0xFF006A71),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add Picture (Optional)',
                    style: TextStyle(color: Color(0xFF006A71), fontSize: 16),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                ),
              ),
      ),
    );
  }
}
