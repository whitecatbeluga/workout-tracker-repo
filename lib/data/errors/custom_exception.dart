class CustomErrorException implements Exception {
  final String code;
  final String message;

  const CustomErrorException({required this.code, required this.message});

  @override
  String toString() => 'FirebaseErrorException(code: $code, message: $message)';

  factory CustomErrorException.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const CustomErrorException(
          code: 'invalid-email',
          message: 'The email address is invalid',
        );
      case 'user-not-found':
        return const CustomErrorException(
          code: 'user-not-found',
          message: 'No user found with this email',
        );
      case 'wrong-password':
        return const CustomErrorException(
          code: 'wrong-password',
          message: 'The password is incorrect',
        );
      case 'email-already-in-use':
        return const CustomErrorException(
          code: 'email-already-in-use',
          message: 'This email is already in use',
        );
      case 'weak-password':
        return const CustomErrorException(
          code: 'weak-password',
          message: 'The password is weak',
        );
      case 'network-request-failed':
        return const CustomErrorException(
          code: 'network-request-failed',
          message: 'Please check your internet connetion',
        );
      default:
        return CustomErrorException(
          code: code,
          message: 'An unknown error occured (code:$code)',
        );
    }
  }
}
