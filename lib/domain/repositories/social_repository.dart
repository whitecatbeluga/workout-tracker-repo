import 'package:workout_tracker_repo/domain/entities/comments_with_user.dart';
import 'package:workout_tracker_repo/domain/entities/notifications_with_user.dart';
import '../entities/social_with_user.dart';

abstract class SocialRepository {
  Stream<List<SocialWithUser>> fetchPublicWorkouts(String currentUserId);
  Stream<List<SocialWithUser>> fetchFollowingWorkouts(String userId);
  Stream<List<SocialWithUser>> fetchUserPublicWorkouts(String userId);
  Stream<List<SocialWithUser>> fetchCurrentUserData(String userId);
  Future<List<CommentsWithUser>> fetchCommentsWithUserData(String workoutId);
  Future<void> postComment({
    required String workoutId,
    required String userId,
    required String description,
  });
  Future<void> toggleLike({required String workoutId, required String userId});
  Future<bool> checkIfFollowing(String currentUserId, String otherUserId);
  Future<List<Map<String, dynamic>>> searchUsers(String query);
  Future<List<Map<String, dynamic>>> fetchRecents();
  Future<void> clearAllRecents();
  Stream<List<SocialWithUser>> fetchMyWorkouts(String userId);
  Future<int> countRoutines(String userId);
  Stream<List<NotificationWithUser>> fetchNotifications(String userId);
  Future<SocialWithUser?> fetchSocialWithUserByWorkoutId(String workoutId);
}
