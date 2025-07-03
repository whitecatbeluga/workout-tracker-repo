import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ExerciseService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'exercises';

  Stream<QuerySnapshot<Map<String, dynamic>>> getAll() =>
      _firestore.collection(_collection).snapshots();

  Future<void> addExercise(Map<String, dynamic> data, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .add(data);
  }

  Future<void> updateExercise(
    String exerciseId,
    Map<String, dynamic> data,
    String userId,
  ) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(exerciseId);

    final docSnapshot = await docRef.get();

    String? newImageUrl;

    if (docSnapshot.exists) {
      final existingData = docSnapshot.data();
      final existingImageUrl = existingData?['image_url'];
      print('\x1B[2J\x1B[1;1H');
      print(existingImageUrl);

      // Delete old image if exists
      if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        print('here');
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(existingImageUrl);
          await oldRef.delete();
        } catch (e) {
          print('Failed to delete old image: $e');
        }
      } else {
        // If new image is provided
        if (data['imageUrl'] != null) {
          // Upload new image with a new filename
          final imageFile = data['imageUrl'] as File;
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final newRef = FirebaseStorage.instance
              .ref()
              .child('exercise_images')
              .child('$fileName.jpg');

          await newRef.putFile(imageFile);
          newImageUrl = await newRef.getDownloadURL();
          data.remove('imageUrl');
          data['imageUrl'] = newImageUrl;
        }
      }
    }

    await docRef.update(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getExercises(String userId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .snapshots();
}
