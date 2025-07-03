import 'package:cloud_firestore/cloud_firestore.dart';

class PredefinedRoutineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _routinesRef =>
      _firestore.collection('predefined_routines');

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamRoutines() {
    return _routinesRef.snapshots().map((snap) => snap.docs);
  }

  Future<Map<String, dynamic>?> getRoutine(String routineId) async {
    final doc = await _routinesRef.doc(routineId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  Future<List<Map<String, dynamic>>> getExercises(String routineId) async {
    final snap = await _routinesRef
        .doc(routineId)
        .collection('exercises')
        .get();

    List<Map<String, dynamic>> exercises = [];

    for (final doc in snap.docs) {
      final data = doc.data();

      final sets = List<Map<String, dynamic>>.from(data['sets'] ?? []);
      final exerciseSnapshot = await _firestore
          .collection('exercises')
          .doc(data['exercise_id'])
          .get();

      final exerciseData = exerciseSnapshot.data() ?? {};

      exercises.add({
        'id': data['exercise_id'],
        'exercise_id': data['exercise_id'],
        'name': exerciseData['name'],
        'description': exerciseData['description'],
        'category': exerciseData['category'],
        'with_out_equipment': exerciseData['with_out_equipment'],
        'image_url': exerciseData['image_url'],
        'sets': sets,
      });
    }

    return exercises;
  }
}
