import 'package:dartz/dartz.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullname,
    required String role,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  // Future<Either<Failure, User>> updateProfile({
  //   required String userId,
  //   String? name,
  //   String? profileImageUrl,
  // });

  Future<Either<Failure, void>> changePassword({required String newPassword});

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, void>> deleteAccount();
}
