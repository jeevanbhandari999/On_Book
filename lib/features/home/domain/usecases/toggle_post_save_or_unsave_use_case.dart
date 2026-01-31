import 'package:app/core/errors/failures.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class TogglePostSaveOrUnsaveUseCase {
  final HomeRepository repository;
  TogglePostSaveOrUnsaveUseCase(this.repository);

  Future<Either<Failure, void>> call(
    TogglePostSaveOrUnsaveParams params,
  ) async {
    // Validate the required parametrs first
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('Rating id is required'));
    }

    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post id is required'));
    }
    if (params.organizationId.trim().isEmpty) {
      return const Left(ValidationFailure('Organization id is required'));
    }

    return await repository.togglePostSaveOrUnsave(
      params.userId,
      params.postId,
      params.organizationId,
    );
  }
}

class TogglePostSaveOrUnsaveParams extends Equatable {
  final String postId;
  final String userId;
  final String organizationId;

  const TogglePostSaveOrUnsaveParams({
    required this.postId,
    required this.userId,
    required this.organizationId,
  });

  @override
  List<Object> get props => [organizationId, userId, postId];
}
