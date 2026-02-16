import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeleteOrganizationLogoUseCase {
  final OrganizationRepository repository;

  DeleteOrganizationLogoUseCase(this.repository);

  Future<Either<Failure, Organization>> call(
    DeleteOrganizationLogoParams params,
  ) async {
    // validate the required parameters first
    if (params.organizationId.trim().isEmpty) {
      return const Left(ValidationFailure('Organization id is required'));
    }

    if (params.logoUrlToDelete.trim().isEmpty) {
      return const Left(ValidationFailure('Logo url is required to delete'));
    }

    return await repository.deleteOrganizationLogoUrl(
      params.organizationId,
      params.logoUrlToDelete,
    );
  }
}

class DeleteOrganizationLogoParams extends Equatable {
  final String organizationId;
  final String logoUrlToDelete;

  const DeleteOrganizationLogoParams({
    required this.organizationId,
    required this.logoUrlToDelete,
  });

  @override
  List<Object> get props => [organizationId, logoUrlToDelete];
}
