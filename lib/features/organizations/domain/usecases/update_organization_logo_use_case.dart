import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateOrganizationLogoUseCase {
  final OrganizationRepository repository;

  UpdateOrganizationLogoUseCase(this.repository);

  Future<Either<Failure, Organization>> call(
    UpdateOrganizationLogoParams params,
  ) async {
    // validate the required parameters first
    if (params.organizationId.trim().isEmpty) {
      return const Left(ValidationFailure('Organization id is required'));
    }

    if (params.logoUrl.trim().isEmpty) {
      return const Left(ValidationFailure('Logo url is required to update'));
    }

    return await repository.updateOrganizationLogoUrl(
      params.organizationId,
      params.logoUrl,
      params.existingLogoToDelte,
    );
  }
}

class UpdateOrganizationLogoParams extends Equatable {
  final String organizationId;
  final String logoUrl;
  final String? existingLogoToDelte;

  const UpdateOrganizationLogoParams({
    required this.organizationId,
    required this.logoUrl,
    this.existingLogoToDelte,
  });

  @override
  List<Object?> get props => [organizationId, logoUrl, existingLogoToDelte];
}
