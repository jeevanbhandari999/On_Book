import 'package:equatable/equatable.dart';

// Base class for all Failures in the application
abstract class Failure extends Equatable {
  // Error message
  final String message;

  // Optional error code for categorization
  final String? code;

  // Optional additional Properties
  final Map<String, dynamic>? properties;

  const Failure(this.message, {this.code, this.properties});

  @override
  List<Object?> get props => [message, code, properties];

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');

    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (properties != null && properties!.isNotEmpty) {
      buffer.write(' (Properties: $properties)');
    }
    return buffer.toString();
  }
}

// Failure for server-related errors
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.properties});
}

// Failure for network-related errors
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.properties});
}

// Failure for validation-related errors
class ValidationFailure extends Failure {
  // List of validation errors, helps to provide the custom validation error for different cases
  final List<String> validationErrors;

  const ValidationFailure(
    super.message, {
    super.code,
    super.properties,
    this.validationErrors = const [],
  });

  @override
  List<Object?> get props => [...super.props, validationErrors];
}

// Failure for authentication/authorization-related errors
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.properties});
}

// Failure for permission-related errors
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.properties});
}

// Failure for not found - related errors
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.properties});
}

// Failure for cache-related errors
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.properties});
}

// Failure for unknown/unexpected-related errors
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.properties});
}
