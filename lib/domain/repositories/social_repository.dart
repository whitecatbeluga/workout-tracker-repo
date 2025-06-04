import '../entities/social_with_username.dart';

abstract class SocialRepository {
  Stream<List<SocialWithUserName>> fetchPublicWorkouts(String currentUserId);
}
