import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/data/errors/custom_error_exception.dart';
import 'package:workout_tracker_repo/domain/entities/comments_with_user.dart';

import '../../domain/entities/social_with_user.dart'; // ✅ Use the same one
import '../../domain/repositories/social_repository.dart';
import '../models/social_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comments.dart';
import '../../data/models/comments_model.dart';
import '../../presentation/domain/entities/calendar_workoutdata.dart';

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

                final likesSnapshot = await _firestore
                    .collection('workouts')
                    .doc(doc.id)
                    .collection('likes')
                    .get();

                final likedByUids = likesSnapshot.docs
                    .map((likeDoc) => likeDoc.data()['liked_by'] as String)
                    .toList();

                final commentsSnapshot = await _firestore
                    .collection('workouts')
                    .doc(doc.id)
                    .collection('comments')
                    .get();

                return SocialWithUser(
                  social: social,
                  userName: userName,
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                  likedByUids: likedByUids,
                  commentCount: commentsSnapshot.size,
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
  Stream<List<SocialWithUser>> fetchFollowingWorkouts(String userId) async* {
    try {
      final followingSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      final followingIds = followingSnap.docs.map((e) => e.id).toList();

      if (followingIds.isEmpty) {
        yield [];
      } else {
        yield* _firestore
            .collection('workouts')
            .where('user_id', whereIn: followingIds)
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

                  final likesSnapshot = await _firestore
                      .collection('workouts')
                      .doc(doc.id)
                      .collection('likes')
                      .get();

                  final likedByUids = likesSnapshot.docs
                      .map((like) => like.data()['liked_by'] as String)
                      .toList();

                  final commentsSnapshot = await _firestore
                      .collection('workouts')
                      .doc(doc.id)
                      .collection('comments')
                      .get();

                  return SocialWithUser(
                    social: social,
                    userName: userName,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    likedByUids: likedByUids,
                    commentCount: commentsSnapshot.size,
                  );
                }),
              );
              return results;
            });
      }
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      QuerySnapshot firstNameSnap = await _firestore
          .collection('users')
          .where('first_name', isGreaterThanOrEqualTo: query)
          .where('first_name', isLessThan: query + '\uf8ff')
          .get();

      QuerySnapshot lastNameSnap = await _firestore
          .collection('users')
          .where('last_name', isGreaterThanOrEqualTo: query)
          .where('last_name', isLessThan: query + '\uf8ff')
          .get();

      final allDocs = {
        for (var doc in [...firstNameSnap.docs, ...lastNameSnap.docs])
          doc.id: {"id": doc.id, ...doc.data() as Map<String, dynamic>},
      }.values.toList();

      return allDocs;
    } on FirebaseException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecents() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('recents')
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        String visitedUserId = doc.id;
        Timestamp searchedAt = doc['searched_at'];

        DocumentSnapshot userSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(visitedUserId)
            .get();

        if (userSnap.exists && userSnap.data() != null) {
          final data = userSnap.data() as Map<String, dynamic>;
          results.add({
            "id": userSnap.id,
            "account_picture": data['account_picture'] as String? ?? '',
            "first_name": data['first_name'] as String? ?? '',
            "last_name": data['last_name'] as String? ?? '',
            "user_name": data['user_name'] as String? ?? '',
            "email": data['email'] as String? ?? '',
            "searched_at": searchedAt,
          });
        }
      }
      results.sort((a, b) => b['searched_at'].compareTo(a['searched_at']));
      return results;
    } on FirebaseException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<void> clearAllRecents() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('recents')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (_) {
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

  @override
  Stream<List<SocialWithUser>> fetchCurrentUserData(String userId) {
    try {
      return _firestore
          .collection('workouts')
          .where('user_id', isEqualTo: userId)
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

  Future<List<Comment>> fetchComments(String workoutId) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .doc(workoutId)
          .collection('comments')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommentsModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (_) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<List<CommentsWithUser>> fetchCommentsWithUserData(
    String workoutId,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .doc(workoutId)
        .collection('comments')
        .orderBy('created_at', descending: false)
        .get();

    final comments = snapshot.docs.map((doc) {
      return CommentsModel.fromMap(doc.data(), doc.id);
    }).toList();

    final List<CommentsWithUser> result = [];

    for (final comment in comments) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(comment.from)
          .get();

      final userData = userDoc.data();
      if (userData == null) continue;

      result.add(
        CommentsWithUser(
          id: comment.id,
          from: comment.from,
          description: comment.description,
          createdAt: comment.createdAt,
          accountPicture: userData['account_picture'] ?? '',
          firstName: userData['first_name'] ?? '',
          lastName: userData['last_name'] ?? '',
        ),
      );
    }

    return result;
  }

  @override
  Future<void> postComment({
    required String workoutId,
    required String userId,
    required String description,
  }) async {
    try {
      final commentData = {
        'from': userId,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('workouts')
          .doc(workoutId)
          .collection('comments')
          .add(commentData);
    } on FirebaseException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (_) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<void> toggleLike({
    required String workoutId,
    required String userId,
  }) async {
    try {
      final likeRef = _firestore
          .collection('workouts')
          .doc(workoutId)
          .collection('likes')
          .doc(userId);

      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        await likeRef.delete();
      } else {
        await likeRef.set({'liked_by': userId});
      }
    } on FirebaseException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (_) {
      throw CustomErrorException.fromCode(500);
    }
  }

  Future<void> toggleFollowing({
    required String userId,
    required String followingId,
  }) async {
    try {
      final followingRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(followingId);

      final followerRef = _firestore
          .collection('users')
          .doc(followingId)
          .collection('followers')
          .doc(userId);

      final followingDoc = await followingRef.get();

      if (followingDoc.exists) {
        // Unfollow
        await Future.wait([followingRef.delete(), followerRef.delete()]);
      } else {
        // Follow
        final timestamp = {'followed_at': FieldValue.serverTimestamp()};
        await Future.wait([
          followingRef.set(timestamp),
          followerRef.set(timestamp),
        ]);
      }
    } on FirebaseException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (_) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Future<bool> checkIfFollowing(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(otherUserId)
          .get();

      return doc.exists;
    } on FirebaseException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (_) {
      throw CustomErrorException.fromCode(500);
    }
  }

  Stream<List<CalendarWorkoutDates>> fetchGroupedWorkouts(String userId) {
    return _firestore
        .collection('workouts')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          final Map<DateTime, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
          groupedByDate = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final Timestamp ts = data['created_at'];
            final DateTime fullDate = ts.toDate();

            // Strip time: use only year, month, day
            final DateTime dateOnly = DateTime(
              fullDate.year,
              fullDate.month,
              fullDate.day,
              fullDate.hour,
              fullDate.minute,
            );

            groupedByDate.putIfAbsent(dateOnly, () => []).add(doc);
          }

          return groupedByDate.entries.map((entry) {
            final date = entry.key;
            final workouts = entry.value;

            final userWorkouts = workouts.map((doc) {
              final data = doc.data();

              return UserWorkout(
                id: doc.id,
                title: data['workout_title'] ?? '',
                duration: data['workout_duration']?.toString() ?? '',
                volume: data['total_volume']?.toString() ?? '',
                sets: data['total_sets']?.toString() ?? '',
                createdAt: (data['created_at'] as Timestamp)
                    .toDate()
                    .toString(), // or format as needed
              );
            }).toList();

            final List<String> images = [];

            for (var doc in workouts) {
              final data = doc.data();

              final urls = data['image_urls'];
              if (urls is List) {
                for (var url in urls) {
                  if (url is String) {
                    images.add(url);
                  }
                }
              }
            }

            return CalendarWorkoutDates(
              date: date, // ✅ this is a proper DateTime with only Y/M/D
              workouts: userWorkouts,
              images: images.cast<String>(),
            );
          }).toList();
        });
  }

  Future<SocialWithUser?> fetchSocialWithUserByWorkoutId(
    String workoutId,
  ) async {
    try {
      final doc = await _firestore.collection('workouts').doc(workoutId).get();
      if (!doc.exists) return null;

      final social = SocialModel.fromMap(doc.data()!, doc.id);

      final userDoc = await _firestore
          .collection('users')
          .doc(social.uid)
          .get();
      final userData = userDoc.data() ?? {};

      final userName = userData['user_name'] ?? 'Unknown';
      final firstName = userData['first_name'] ?? 'Unknown';
      final lastName = userData['last_name'] ?? 'Unknown';
      final email = userData['email'] ?? 'Unknown';

      final likesSnapshot = await _firestore
          .collection('workouts')
          .doc(doc.id)
          .collection('likes')
          .get();

      final likedByUids = likesSnapshot.docs
          .map((likeDoc) => likeDoc.data()['liked_by'] as String)
          .toList();

      final commentsSnapshot = await _firestore
          .collection('workouts')
          .doc(doc.id)
          .collection('comments')
          .get();

      return SocialWithUser(
        social: social,
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        email: email,
        likedByUids: likedByUids,
        commentCount: commentsSnapshot.size,
      );
    } catch (e) {
      print('Error fetching workout post: $e');
      return null;
    }
  }
}
