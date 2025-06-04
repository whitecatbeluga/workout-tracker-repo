import '../../domain/entities/social_with_username.dart'; // ✅ Use the same one
import '../../domain/repositories/social_repository.dart';
import '../models/social_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialRepositoryImpl implements SocialRepository {
  final FirebaseFirestore _firestore;

  SocialRepositoryImpl(this._firestore);

  @override
  Stream<List<SocialWithUserName>> fetchPublicWorkouts(String currentUserId) {
    return _firestore
        .collection('workouts')
        .where('visible_to_everyone', isEqualTo: true)
        // .where('user_id', isNotEqualTo: currentUserId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final results = await Future.wait(
            snapshot.docs.map((doc) async {
              final social = SocialModel.fromMap(doc.data(), doc.id);
              final userDoc = await _firestore
                  .collection('users')
                  .doc(social.uid)
                  .get();
              final userName = userDoc.data()?['user_name'] ?? 'Unknown';

              return SocialWithUserName(social: social, userName: userName);
            }),
          );

          return results;
        });
  }
}
