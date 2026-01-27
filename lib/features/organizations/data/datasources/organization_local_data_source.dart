import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class OrganizationLocalDataSource {
  // Organizations details
  Future<OrganizationModel?> getCachedOrganizationDetail(String organizationId);

  // Cache the organization details of the user
  Future<void> cacheOrganizationDetail(
    String organizationId,
    String userId,
    OrganizationModel organization,
  );

  // Remove the organization details(specific) from the cache
  Future<void> removeCahceOrganization(String organizationId, String userId);

  // Clear all cached organization details
  Future<void> clearAllCachedOrganizations();

  // Get cache timestamp for the profile, Last update time
  Future<DateTime?> getCacheTimestamp(String userId);

  // Update last cache time
  Future<void> updateCacheTimestamp(String userId);

  // Determine the cache expire date
  Future<bool> isCacheExpired(String userId, {Duration maxAge});
}

class OrganizationLocalDataSourceImpl implements OrganizationLocalDataSource {
  final FlutterSecureStorage secureStorage;

  const OrganizationLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _organizationPrefix = 'organization_';
  static const String _timestampPrefix = 'organization_timestamp_';

  @override
  Future<void> cacheOrganizationDetail(
    String organizationId,
    String userId,
    OrganizationModel organization,
  ) async {
    // TODO: implement cacheOrganizationDetail
    throw UnimplementedError();
  }

  @override
  Future<void> clearAllCachedOrganizations() async {
    // TODO: implement clearAllCachedOrganizations
    throw UnimplementedError();
  }

  @override
  Future<DateTime?> getCacheTimestamp(String userId) async {
    // TODO: implement getCacheTimestamp
    throw UnimplementedError();
  }

  @override
  Future<OrganizationModel?> getCachedOrganizationDetail(
    String organizationId,
  ) async {
    // TODO: implement getCachedOrganizationDetail
    throw UnimplementedError();
  }

  @override
  Future<bool> isCacheExpired(
    String userId, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    // TODO: implement isCacheExpired
    throw UnimplementedError();
  }

  @override
  Future<void> removeCahceOrganization(
    String organizationId,
    String userId,
  ) async {
    // TODO: implement removeCahceOrganization
    throw UnimplementedError();
  }

  @override
  Future<void> updateCacheTimestamp(String userId) async {
    // TODO: implement updateCacheTimestamp
    throw UnimplementedError();
  }
}
