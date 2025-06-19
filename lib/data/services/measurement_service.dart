import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'measurements';

  Future<void> add(Map<String, dynamic> data) =>
      _firestore.collection(_collection).add(data);

  Stream<QuerySnapshot<Map<String, dynamic>>> getByUserId(String userId) =>
      _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .snapshots();
}
