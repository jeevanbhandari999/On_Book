import 'dart:io';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  // Get the user profile details by their id
  Future<Either<Failure, User>> getUserProfileDetailById(String userId);

  // Update the user profile
  Future<Either<Failure, User>> updateUserProfile(
    User profile,
    File? newProfilePicture,
    String avatarToDelete,
  );

  // Upload the profile picture and return the url
  Future<Either<Failure, String>> uploadProfilePicture(
    File profilePictureFile,
    String userId,
  );

  //Delete an profile picture from storage
  Future<Either<Failure, void>> deleteProfilePicture(String imageUrl);

  // Get cache profie details
  Future<Either<Failure, User?>> getCachedProfileDetail(String userId);

  // Cache user profile detail locally
  Future<Either<Failure, void>> cacheProfileDetail(String userId, User profile);

  // Clear cached profile details
  Future<Either<Failure, void>> clearCachedProfileDetail(String userId);

  // Update the profile picture of the user
  Future<Either<Failure, User>> updateProfilePictureUrl(
    String userId,
    String profilePictureUrl,
  );
}
