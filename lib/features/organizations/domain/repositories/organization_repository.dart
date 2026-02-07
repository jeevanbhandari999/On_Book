import 'dart:io';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:dartz/dartz.dart';

abstract class OrganizationRepository {
  /// Get all organizations created by user
  // Future<Either<Failure, List<Organization>>> getOrganizations(String userId);

  /// Get single organization detail
  Future<Either<Failure, Organization>> getOrganizationById(
    String organizationId,
  );

  /// Create organization
  Future<Either<Failure, Organization>> createOrganization(
    Organization organization,
  );

  /// Update organization (optionally with new logo)
  Future<Either<Failure, Organization>> updateOrganization(
    Organization organization,
    File? newLogoFile,
    String logoToDelete,
  );

  /// Delete organization
  Future<Either<Failure, void>> deleteOrganization(String organizationId);

  /// Upload organization logo and return url
  Future<Either<Failure, String>> uploadOrganizationLogo(
    File logoFile,
    String organizationId,
  );

  /// Delete logo from storage
  Future<Either<Failure, void>> deleteOrganizationLogo(String logoUrl);

  /// Update logo url only
  Future<Either<Failure, Organization>> updateOrganizationLogoUrl(
    String organizationId,
    String logoUrl,
    String? existingLogoToDelete,
  );

  /// Remove logo url
  Future<Either<Failure, Organization>> deleteOrganizationLogoUrl(
    String organizationId,
    String logoUrlToDelete,
  );

  /// Get cached organizations
  // Future<Either<Failure, List<Organization>?>> getCachedOrganizations(
  //   String userId,
  // );

  /// Cache organizations locally
  Future<Either<Failure, void>> cacheOrganizations(
    String userId,
    List<Organization> organizations,
  );

  /// Clear cached organizations for user
  Future<Either<Failure, void>> clearCachedOrganizations(String userId);

  /// Clear all cached organizations
  Future<Either<Failure, void>> clearAllCachedOrganizations();
}
