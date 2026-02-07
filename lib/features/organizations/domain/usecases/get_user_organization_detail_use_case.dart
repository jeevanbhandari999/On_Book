import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetUserOrganizationDetailUseCase {
  final OrganizationRepository repository;

  GetUserOrganizationDetailUseCase(this.repository);

  /// Fetch the organization of the user by organizationId
  Future<Either<Failure, Organization>> call(
    GetUserOrganizationDetailParams params,
  ) async {
    return repository.getOrganizationById(params.organizationId);
  }
}

class GetUserOrganizationDetailParams extends Equatable {
  final String organizationId;
  final String? userId;

  const GetUserOrganizationDetailParams({
    required this.organizationId,
    this.userId,
  });

  @override
  List<Object?> get props => [organizationId, userId];
}
