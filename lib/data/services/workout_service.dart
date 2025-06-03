import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'workouts';

  Future<void> add(Map<String, dynamic> data) =>
      _firestore.collection(_collection).add(data);

  Future<void> update(String id, Map<String, dynamic> data) =>
      _firestore.collection(_collection).doc(id).update(data);

  Future<void> delete(String id) =>
      _firestore.collection(_collection).doc(id).delete();

  Future<DocumentSnapshot<Map<String, dynamic>>> getById(String id) =>
      _firestore.collection(_collection).doc(id).get();

  Stream<QuerySnapshot<Map<String, dynamic>>> getAll() =>
      _firestore.collection(_collection).snapshots();
}