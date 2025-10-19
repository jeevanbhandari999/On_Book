import 'package:app/core/errors/failures.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  // For error messages
  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      // _ to avoid blue line warning and hepts to identify the type.
      case ServerFailure _:
        return 'Server error occurred. Plese try again';
      case NetworkFailure _:
        return 'Network error occurred. Please try again';
      case CacheFailure _:
        return 'Local storage error occurred.';
      case ValidationFailure _:
        return failure.message;
      case AuthFailure _:
        return 'Authentication failed. Please login again.';
      case PermissionFailure _:
        return 'You don\'t have permission to perform this action.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // To show the error message
  static void showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(failure)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // To show the success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // To show the info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
