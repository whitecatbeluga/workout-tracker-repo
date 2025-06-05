class CustomErrorException implements Exception {
  final int code;
  final String message;

  const CustomErrorException._({required this.code, required this.message});

  factory CustomErrorException.fromCode(int code) {
    switch (code) {
      case 400:
        return const CustomErrorException._(code: 400, message: 'Bad Request');
      case 401:
        return const CustomErrorException._(code: 401, message: 'Unauthorized');
      case 403:
        return const CustomErrorException._(code: 403, message: 'Forbidden');
      case 404:
        return const CustomErrorException._(
          code: 404,
          message: 'Resource not found',
        );
      case 500:
        return const CustomErrorException._(
          code: 500,
          message: 'Internal server error',
        );
      case 502:
        return const CustomErrorException._(
          code: 502,
          message: 'Service unavailable',
        );
      case 504:
        return const CustomErrorException._(
          code: 504,
          message: 'Gateway Timeout',
        );
      default:
        return CustomErrorException._(
          code: code,
          message: 'Unexpected error (code: $code)',
        );
    }
  }

  @override
  String toString() => 'CustomErrorException(code: $code, message: $message)';
}
