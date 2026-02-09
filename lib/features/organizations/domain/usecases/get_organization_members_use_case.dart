import 'package:app/core/errors/failures.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:app/features/auth/domain/entities/user.dart';

class GetOrganizationMembersUseCase {
  final OrganizationRepository repository;

  GetOrganizationMembersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call(
    GetOrganizationMembersParams params,
  ) async {
    // First validate the required fields
    if (params.organizationId.isEmpty) {
      return const Left(ValidationFailure('Organization id is required'));
    }

    return await repository.getOrganizationMembers(params.organizationId);
  }
}

class GetOrganizationMembersParams extends Equatable {
  final String organizationId;

  const GetOrganizationMembersParams({required this.organizationId});

  @override
  List<Object> get props => [organizationId];
}
