import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateProfilePictureUseCase {
  final ProfileRepository repository;

  UpdateProfilePictureUseCase(this.repository);

  Future<Either<Failure, User>> call(UpdateProfilePictureParams params) async {
    // validate the required parameters first
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required'));
    }

    if (params.imageUrl.trim().isEmpty) {
      return const Left(ValidationFailure('Image url is required to update'));
    }

    return await repository.updateProfilePictureUrl(
      params.userId,
      params.imageUrl,
    );
  }
}

class UpdateProfilePictureParams extends Equatable {
  final String userId;
  final String imageUrl;

  const UpdateProfilePictureParams({
    required this.userId,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [userId, imageUrl];
}
