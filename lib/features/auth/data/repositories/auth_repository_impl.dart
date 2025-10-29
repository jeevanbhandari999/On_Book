import 'package:app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  //  LOGIN

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache user + token
      await localDataSource.cacheUser(userModel);
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token != null) await localDataSource.cacheToken(token);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  REGISTER

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullname,
    required String role,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullname,
        role: role,
      );

      // Cache user + token
      await localDataSource.cacheUser(userModel);
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token != null) await localDataSource.cacheToken(token);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  LOGOUT

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  GET CURRENT USER

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // 1. Try cache first
      final cached = await localDataSource.getCachedUser();
      if (cached != null) {
        return Right(cached.toEntity());
      }

      // 2. No cache → remote
      final userModel = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  FORGOT PASSWORD

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  RESET PASSWORD

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  UPDATE PROFILE

  // @override
  // Future<Either<Failure, User>> updateProfile({
  //   required String userId,
  //   String? name,
  //   String? profileImageUrl,
  // }) async {
  //   try {
  //     final userModel = await remoteDataSource.updateProfile(
  //       userId: userId,
  //       name: name,
  //       profileImageUrl: profileImageUrl,
  //     );

  //     await localDataSource.cacheUser(userModel);
  //     return Right(userModel.toEntity());
  //   } on ServerException catch (e) {
  //     return Left(ServerFailure(e.message));
  //   } on NetworkException catch (e) {
  //     return Left(NetworkFailure(e.message));
  //   } catch (e) {
  //     return Left(UnknownFailure(e.toString()));
  //   }
  // }

  //  CHANGE PASSWORD

  @override
  Future<Either<Failure, void>> changePassword({
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(newPassword: newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  IS LOGGED IN

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final loggedIn = await localDataSource.isLoggedIn();
      return Right(loggedIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  //  DELETE ACCOUNT

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
