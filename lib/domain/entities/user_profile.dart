class UserProfile {
  final String userName;
  final String firstName;
  final String lastName;
  final String? accountPicture;

  UserProfile({
    required this.userName,
    required this.firstName,
    required this.lastName,
    this.accountPicture,
  });
}