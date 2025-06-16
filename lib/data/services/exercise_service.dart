import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'exercises';

  Stream<QuerySnapshot<Map<String, dynamic>>> getAll() =>
      _firestore.collection(_collection).snapshots();
}
