import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetCurrentUserProfileUseCase {
  final ProfileRepository repository;

  GetCurrentUserProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(GetCurrentUserProfileParams params) async {
    // Validate the required field first
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required '));
    }

    return await repository.getUserProfileDetailById(params.userId);
  }
}

class GetCurrentUserProfileParams extends Equatable {
  final String userId;

  const GetCurrentUserProfileParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
