import './social.dart';

class SocialWithUser {
  final Social social;
  final String accountPicture;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> likedByUids;
  final int commentCount;
  final List<Map<String, dynamic>> exercises;

  SocialWithUser({
    required this.social,
    required this.accountPicture,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.likedByUids = const [],
    this.commentCount = 0,
    this.exercises = const [],
  });
}
