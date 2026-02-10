import 'package:app/core/errors/failures.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CanManageOrganizationUseCase {
  final OrganizationRepository repository;

  CanManageOrganizationUseCase(this.repository);

  Future<Either<Failure, bool>> call(CanManageOrganizationParams params) async {
    // First validate the required parameters
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required'));
    }
    if (params.organizationId.trim().isEmpty) {
      return const Left(ValidationFailure('Organization id is requried'));
    }
    try {
      final result = await repository.canManageOrganization(
        params.userId,
        params.organizationId,
      );
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class CanManageOrganizationParams extends Equatable {
  final String userId;
  final String organizationId;

  const CanManageOrganizationParams({
    required this.userId,
    required this.organizationId,
  });

  @override
  List<Object> get props => [userId, organizationId];
}
