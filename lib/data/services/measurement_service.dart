import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'measurements';

  Future<void> add(Map<String, dynamic> data) async {
    final String userId = data['user_id'];
    final double? height = data['height'];
    final double? weight = data['weight'];
    final heightM = height! / 100;
    final double bmi = weight! / (heightM * heightM);
    await _firestore.collection(_collection).add(data);

    // Optional: Only update user if height and weight are present
    if (userId.isNotEmpty) {
      await _firestore.collection('users').doc(userId).set({
        'height': height,
        'weight': weight,
        'bmi': double.parse(bmi.toStringAsFixed(1)),
      }, SetOptions(merge: true));
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getByUserId(String userId) =>
      _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .snapshots();
}
