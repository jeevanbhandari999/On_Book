// Server Exception
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server Exception']);

  @override
  String toString() => 'ServerException: $message';
}


// Network Exception
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network Exception']);

  @override
  String toString() => 'NetworkException: $message';
}

// Cache Exception
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache Exception']);

  @override
  String toString() => 'CacheException: $message';
}


// Validation Exception
class ValidationException implements Exception {
  final String message;

  const ValidationException([this.message = 'Validation Exception']);

  @override
  String toString() => 'ValidationException: $message';
}


// Auth Exception
class AuthException implements Exception {
  final String message;

  const AuthException([this.message = 'Authentication Exception']);

  @override
  String toString() => 'AuthException: $message';
}


// Permission Exception
class PermissionException implements Exception {
  final String message;

  const PermissionException([this.message = 'Permission Exception']);

  @override
  String toString() => 'PermissionException: $message';
}

