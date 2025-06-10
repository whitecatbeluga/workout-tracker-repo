import 'package:workout_tracker_repo/domain/entities/comments_with_user.dart';
import '../entities/social_with_user.dart';

abstract class SocialRepository {
  Stream<List<SocialWithUser>> fetchPublicWorkouts(String currentUserId);
  Stream<List<SocialWithUser>> fetchUserPublicWorkouts(String userId);
  Stream<List<SocialWithUser>> fetchCurrentUserData(String userId);
  Future<List<CommentsWithUser>> fetchCommentsWithUserData(String workoutId);
  Future<void> postComment({
    required String workoutId,
    required String userId,
    required String description,
  });
}
