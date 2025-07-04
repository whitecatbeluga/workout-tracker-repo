class NotificationWithUser {
  final String id;
  final String from;
  final String title;
  final String description;
  final String type;
  final String accountPicture;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? createdAt;
  final String? postId;

  NotificationWithUser({
    required this.id,
    required this.from,
    required this.title,
    required this.description,
    required this.type,
    required this.accountPicture,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.createdAt,
    this.postId,
  });
}
