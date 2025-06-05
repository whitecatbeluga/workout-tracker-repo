class AuthErrorException implements Exception {
  final String code;
  final String message;

  const AuthErrorException({required this.code, required this.message});

  @override
  String toString() => 'FirebaseErrorException(code: $code, message: $message)';

  factory AuthErrorException.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthErrorException(
          code: 'invalid-email',
          message: 'The email address is invalid',
        );
      case 'user-not-found':
        return const AuthErrorException(
          code: 'user-not-found',
          message: 'No user found with this email',
        );
      case 'wrong-password':
        return const AuthErrorException(
          code: 'wrong-password',
          message: 'The password is incorrect',
        );
      case 'email-already-in-use':
        return const AuthErrorException(
          code: 'email-already-in-use',
          message: 'This email is already in use',
        );
      case 'weak-password':
        return const AuthErrorException(
          code: 'weak-password',
          message: 'The password is weak',
        );
      case 'network-request-failed':
        return const AuthErrorException(
          code: 'network-request-failed',
          message: 'Please check your internet connection',
        );
      default:
        return AuthErrorException(
          code: code,
          message: 'An unknown error occurred (code:$code)',
        );
    }
  }
}
