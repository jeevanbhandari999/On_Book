import 'dart:io';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/organizations/data/datasources/organization_local_data_source.dart';
import 'package:app/features/organizations/data/datasources/organization_remote_data_source.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:dartz/dartz.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationLocalDataSource localDataSource;
  final OrganizationRemoteDataSource remoteDataSource;

  OrganizationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Organization>> getOrganizationById(
    String organizationId,
  ) async {
    try {
      final cachedOrg = await localDataSource.getCachedOrganizationDetail(
        organizationId,
      );
      if (cachedOrg != null) {
        return Right(cachedOrg.toEntity());
      }

      final orgModel = await remoteDataSource.getOrganizationById(
        organizationId,
      );
      await localDataSource.cacheOrganizationDetail(orgModel.id, orgModel);

      return Right(orgModel.toEntity());
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Organization>> createOrganization(
    Organization organization,
  ) async {
    try {
      final orgModel = OrganizationModel.fromEntity(organization);
      final createdOrg = await remoteDataSource.createOrganization(orgModel);

      await localDataSource.cacheOrganizationDetail(createdOrg.id, createdOrg);

      return Right(createdOrg.toEntity());
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Organization>> updateOrganization(
    Organization organization,
    File? newLogoFile,
    String logoToDelete,
  ) async {
    try {
      final orgModel = OrganizationModel.fromEntity(organization);

      if (logoToDelete.isNotEmpty) {
        await remoteDataSource.deleteOrganizationLogo(logoToDelete);
      }

      if (newLogoFile != null) {
        final newLogoUrl = await remoteDataSource.uploadOrganizationLogo(
          newLogoFile,
          organization.id,
        );
        orgModel.copyWith(logoUrl: newLogoUrl);
      }

      final updatedOrg = await remoteDataSource.updateOrganization(
        orgModel.id,
        orgModel,
      );

      await localDataSource.cacheOrganizationDetail(updatedOrg.id, updatedOrg);

      return Right(updatedOrg.toEntity());
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrganization(
    String organizationId,
  ) async {
    try {
      await remoteDataSource.deleteOrganization(organizationId);
      await localDataSource.removeCahceOrganization(organizationId);

      return const Right(null);
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadOrganizationLogo(
    File logoFile,
    String organizationId,
  ) async {
    try {
      final url = await remoteDataSource.uploadOrganizationLogo(
        logoFile,
        organizationId,
      );
      return Right(url);
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrganizationLogo(String logoUrl) async {
    try {
      await remoteDataSource.deleteOrganizationLogo(logoUrl);
      return const Right(null);
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Organization>> updateOrganizationLogoUrl(
    String organizationId,
    String logoUrl,
    String? existingLogoToDelete,
  ) async {
    try {
      final updatedOrg = await remoteDataSource.updateOrganizationLogoUrl(
        organizationId,
        logoUrl,
        existingLogoToDelete,
      );

      await localDataSource.cacheOrganizationDetail(updatedOrg.id, updatedOrg);

      return Right(updatedOrg.toEntity());
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Organization>> deleteOrganizationLogoUrl(
    String organizationId,
    String logoUrlToDelete,
  ) async {
    try {
      final updatedOrg = await remoteDataSource.deleteOrganizationLogoUrl(
        organizationId,
        logoUrlToDelete,
      );

      await localDataSource.cacheOrganizationDetail(updatedOrg.id, updatedOrg);

      return Right(updatedOrg.toEntity());
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // // Local cache methods
  // @override
  // Future<Either<Failure, List<Organization>?>> getCachedOrganizations(
  //   String userId,
  // ) async {
  //   // Currently single organization per user → can return empty list or null
  //   return const Right(null);
  // }

  @override
  Future<Either<Failure, void>> cacheOrganizations(
    String userId,
    List<Organization> organizations,
  ) async {
    // We only cache single organization, iterate and cache individually if needed
    try {
      for (var org in organizations) {
        await localDataSource.cacheOrganizationDetail(
          org.id,
          OrganizationModel.fromEntity(org),
        );
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedOrganizations(String userId) async {
    try {
      await localDataSource.clearAllCachedOrganizations();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllCachedOrganizations() async {
    try {
      await localDataSource.clearAllCachedOrganizations();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getOrganizationMembers(
    String organizationId,
  ) async {
    try {
      final membersModel = await remoteDataSource.getOrganizationMembers(
        organizationId,
      );
      final members = membersModel
          .map((memberModel) => memberModel.toEntity())
          .toList();
      return Right(members);
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canManageOrganization(
    String userId,
    String organizationId,
  ) async {
    try {
      final canManage = await remoteDataSource.canManageOrganization(
        userId,
        organizationId,
      );
      return Right(canManage);
    } on SocketException catch (_) {
      return const Left(NetworkFailure('No internet connection'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
