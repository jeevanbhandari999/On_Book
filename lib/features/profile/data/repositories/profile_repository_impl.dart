import 'dart:io';

import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> cacheProfileDetail(
    String userId,
    User profile,
  ) async {
    try {
      final profileModel = UserModel.fromEntity(profile);
      await localDataSource.cacheProfileDetail(userId, profileModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedProfileDetail(String userId) async {
    try {
      await localDataSource.clearAllCachedProfiles();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePicture(String imageUrl) async {
    try {
      await remoteDataSource.deleteProfilePicture(imageUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedProfileDetail(String userId) async {
    try {
      final cachedProfile = await localDataSource.getCachedProfileDetail(
        userId,
      );
      if (cachedProfile != null) {
        return Right(cachedProfile.toEntity());
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfileDetailById(String userId) async {
    try {
      // try to get the cache profile
      // final cachedProfileDetail = await localDataSource.getCachedProfileDetail(
      //   userId,
      // );
      // if (cachedProfileDetail != null) {
      //   print(cachedProfileDetail);
      //   return Right(cachedProfileDetail.toEntity());
      // }
      // Fetch from the remote if not cached from the local

      final profileModel = await remoteDataSource.getProfileDetailById(userId);

      // Then cache the profile detail for next time
      await localDataSource.cacheProfileDetail(userId, profileModel);

      // return the profile detail through the remote data source
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfilePictureUrl(
    String userId,
    String profilePictureUrl,
    String? existingImageUrlToDelete,
  ) async {
    try {
      final profileModel = await remoteDataSource.updateProfilePictureUrl(
        userId,
        profilePictureUrl,
        existingImageUrlToDelete,
      );
      // Then cache the profile detail for next time
      await localDataSource.cacheProfileDetail(userId, profileModel);
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(
    User profile,
    File? newProfilePicture,
    String avatarToDelete,
  ) async {
    try {
      // First convert entiry to model
      final profileModel = UserModel.fromEntity(profile);

      // Delete the previous image
      // Since I have created the separated avatar change so it's not needed , anyway let's keep
      if (avatarToDelete.isNotEmpty) {
        await remoteDataSource.deleteProfilePicture(avatarToDelete);
      }

      // upload new avatar if provided
      // Again , Since I have created the separated avatar change so it's not needed , anyway let's keep

      String newAvatarUrl = '';
      if (newAvatarUrl.isNotEmpty) {
        newAvatarUrl = await remoteDataSource.uploadProfilePicture(
          newProfilePicture!,
          profile.userId,
        );

        // add new avatar to the profile
        await remoteDataSource.updateProfile(profile.userId, profileModel);
      }

      // Finally update the profile remotely
      final updatedProfileDetail = await remoteDataSource.updateProfile(
        profile.userId,
        profileModel,
      );

      // Cache the updated profile
      await localDataSource.cacheProfileDetail(profile.userId, profileModel);

      return Right(updatedProfileDetail.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(
    File profilePictureFile,
    String userId,
  ) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfilePicture(
        profilePictureFile,
        userId,
      );
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> deleteProfilePictureUrl(
    String userId,
    String profilePictureUrlToDelete,
  ) async {
    try {
      final profileModel = await remoteDataSource.deleteProfilePictureUrl(
        userId,
        profilePictureUrlToDelete,
      );
      // Then cache the profile detail for next time
      await localDataSource.cacheProfileDetail(userId, profileModel);
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
