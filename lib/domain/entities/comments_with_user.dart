import 'package:workout_tracker_repo/domain/entities/comments.dart';

class CommentsWithUser extends Comment {
  final String accountPicture;
  final String firstName;
  final String lastName;

  CommentsWithUser({
    required super.id,
    required super.from,
    required super.description,
    required super.createdAt,
    required this.accountPicture,
    required this.firstName,
    required this.lastName,
  });
}
