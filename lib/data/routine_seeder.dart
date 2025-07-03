import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> verbs = [
    "Challenge",
    "Build",
    "Boost",
    "Revitalize",
    "Revive",
  ];
  final List<String> nouns = [
    "Workout",
    "Challenge",
    "Routine",
    "Program",
    "Plan",
  ];

  String generateId([int length = 20]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  String randomRoutineName() {
    final rand = Random();
    return '${verbs[rand.nextInt(verbs.length)]} ${nouns[rand.nextInt(nouns.length)]}';
  }

  Future<List<String>> getAllExerciseIds() async {
    final snapshot = await _firestore.collection('exercises').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> seedRoutines() async {
    try {
      final programId = generateId();
      final numRoutines = Random().nextInt(3) + 2; // 2 to 4 routines
      final routineIds = <String>[];
      final exerciseIds = await getAllExerciseIds();
      final batch = _firestore.batch();

      for (int i = 0; i < numRoutines; i++) {
        final routineId = generateId();
        routineIds.add(routineId);

        // Create routine document
        final routineRef = _firestore
            .collection('predefined_routines')
            .doc(routineId);
        await routineRef.set({
          'routine_name': randomRoutineName(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Add exercises + sets to routine
        final shuffledExerciseIds = [...exerciseIds]..shuffle();
        for (final exerciseId in shuffledExerciseIds.take(
          Random().nextInt(3) + 1,
        )) {
          final exerciseRef = routineRef
              .collection('exercises')
              .doc(exerciseId);

          final sets = List.generate(3, (index) {
            return {
              'set_number': index + 1,
              'previous': '0kg x 0',
              'kg': (10 + Random().nextInt(40)).toDouble(),
              'reps': 8 + Random().nextInt(5),
              'isCompleted': false,
            };
          });

          batch.set(exerciseRef, {'exercise_id': exerciseId, 'sets': sets});
        }
      }

      await batch.commit();

      print(
        '✅ Seeded programId: $programId with ${routineIds.length} routine(s).',
      );
    } catch (e) {
      print('❌ Error seeding Firestore: $e');
    }
  }
}
