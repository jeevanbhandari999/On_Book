import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class GetOrganizationListBasedOnGlobalScoreUseCase {
  final HomeRepository repository;
  GetOrganizationListBasedOnGlobalScoreUseCase(this.repository);

  Future<Either<Failure, List<Organization>>> call() async {
    return repository.getOrganizationsBasedOnUserAndOthersPreferences();
  }
}
