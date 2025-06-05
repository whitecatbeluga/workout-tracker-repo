import 'package:workout_tracker_repo/data/errors/custom_error_exception.dart';

import '../../domain/entities/social_with_user.dart'; // ✅ Use the same one
import '../../domain/repositories/social_repository.dart';
import '../models/social_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialRepositoryImpl implements SocialRepository {
  final FirebaseFirestore _firestore;

  SocialRepositoryImpl(this._firestore);

  @override
  Stream<List<SocialWithUser>> fetchPublicWorkouts(String currentUserId) {
    try {
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
                final firstName = userDoc.data()?['first_name'] ?? 'Unknown';
                final lastName = userDoc.data()?['last_name'] ?? 'Unknown';
                final email = userDoc.data()?['email'] ?? 'Unknown';

                return SocialWithUser(
                  social: social,
                  userName: userName,
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                );
              }),
            );

            return results;
          });
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Stream<List<SocialWithUser>> fetchUserPublicWorkouts(String userId) {
  try {
    return _firestore
        .collection('workouts')
        .where('user_id', isEqualTo: userId)
        .where('visible_to_everyone', isEqualTo: true)
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
              final firstName = userDoc.data()?['first_name'] ?? 'Unknown';
              final lastName = userDoc.data()?['last_name'] ?? 'Unknown';
              final email = userDoc.data()?['email'] ?? 'Unknown';

              return SocialWithUser(
                social: social,
                userName: userName,
                firstName: firstName,
                lastName: lastName,
                email: email,
              );
            }),
          );

          return results;
        });
  } on CustomErrorException catch (_) {
    throw CustomErrorException.fromCode(400);
  } catch (e) {
    throw CustomErrorException.fromCode(500);
  }
}

}
