import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeleteProfilePictureUseCase {
  final ProfileRepository repository;

  DeleteProfilePictureUseCase(this.repository);

  Future<Either<Failure, User>> call(DeleteProfilePictureParams params) async {
    // validate the required parameters first
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required'));
    }

    if (params.imageUrlToDelete.trim().isEmpty) {
      return const Left(ValidationFailure('Image url is required to delete'));
    }

    return await repository.deleteProfilePictureUrl(
      params.userId,
      params.imageUrlToDelete,
    );
  }
}

class DeleteProfilePictureParams extends Equatable {
  final String userId;
  final String imageUrlToDelete;

  const DeleteProfilePictureParams({
    required this.userId,
    required this.imageUrlToDelete,
  });

  @override
  List<Object> get props => [userId, imageUrlToDelete];
}
