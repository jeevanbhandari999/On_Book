import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:app/core/errors/failures.dart';

class GetOrganizationDetailByPostOrganizationIdUseCase {
  final HomeRepository repository;

  GetOrganizationDetailByPostOrganizationIdUseCase(this.repository);

  Future<Either<Failure, Organization>> call(GetOrganizationDetailByPostOrganizationIdParams params) async {
    return await repository.getOrganizationDetailByPostOrganizationId(
      params.organizationId,
    );
  }
}

class GetOrganizationDetailByPostOrganizationIdParams extends Equatable {
  final String organizationId;

  const GetOrganizationDetailByPostOrganizationIdParams({
    required this.organizationId,
  });

  @override
  List<Object> get props => [organizationId];
}