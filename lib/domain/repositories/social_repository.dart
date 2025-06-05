import '../entities/social_with_user.dart';

abstract class SocialRepository {
  Stream<List<SocialWithUser>> fetchPublicWorkouts(String currentUserId);
  Stream<List<SocialWithUser>> fetchUserPublicWorkouts(String userId);
}
