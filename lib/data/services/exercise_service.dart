import 'package:cloud_firestore/cloud_firestore.dart';

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

  Stream<QuerySnapshot<Map<String, dynamic>>> getExercises(String userId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .snapshots();
}
