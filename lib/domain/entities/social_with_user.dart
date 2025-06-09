import './social.dart';

class SocialWithUser {
  final Social social;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> likedByUids;
  final int commentCount;

  SocialWithUser({
    required this.social,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.likedByUids = const [],
    this.commentCount = 0,
  });
}
