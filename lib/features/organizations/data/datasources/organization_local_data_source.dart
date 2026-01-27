import 'dart:convert';

import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class OrganizationLocalDataSource {
  // Organizations details
  Future<OrganizationModel?> getCachedOrganizationDetail(String organizationId);

  // Cache the organization details of the user
  Future<void> cacheOrganizationDetail(
    String organizationId,
    OrganizationModel organization,
  );

  // Remove the organization details(specific) from the cache
  Future<void> removeCahceOrganization(String organizationId);

  // Clear all cached organization details
  Future<void> clearAllCachedOrganizations();

  // Get cache timestamp for the profile, Last update time
  Future<DateTime?> getCacheTimestamp(String organizationId);

  // Update last cache time
  Future<void> updateCacheTimestamp(String organizationId);

  // Determine the cache expire date
  Future<bool> isCacheExpired(String organizationId, {Duration maxAge});
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
    OrganizationModel organization,
  ) async {
    try {
      final key = '$_organizationPrefix$organizationId';
      final value = jsonEncode(organization.toJson());

      await secureStorage.write(key: key, value: value);
      await updateCacheTimestamp(organizationId);
    } catch (e) {
      throw const CacheException('Failed to cache the organization details');
    }
  }

  @override
  Future<void> clearAllCachedOrganizations() async {
    try {
      final allKeys = await secureStorage.readAll();

      final profileKeys = allKeys.keys.where(
        (key) =>
            key.startsWith(_organizationPrefix) ||
            key.startsWith(_timestampPrefix),
      );

      for (final key in profileKeys) {
        await secureStorage.delete(key: key);
      }
    } catch (e) {
      throw const CacheException(
        'Failed to clear all cached organization details',
      );
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String organizationId) async {
    try {
      final timestampKey = '$_timestampPrefix$organizationId';
      final value = await secureStorage.read(key: timestampKey);

      value != null ? DateTime.tryParse(value) : null;
      return null; // to get rid of warning of not returning null.
    } catch (e) {
      throw const CacheException('Failed to get cache timestamp');
    }
  }

  @override
  Future<OrganizationModel?> getCachedOrganizationDetail(
    String organizationId,
  ) async {
    try {
      final key = '$_organizationPrefix$organizationId';
      final value = await secureStorage.read(key: key);
      if (value == null) {
        return null;
      }

      final map = jsonDecode(value) as Map<String, dynamic>;
      return OrganizationModel.fromJson(map);
    } catch (e) {
      throw const CacheException('Failed to get cache organization details');
    }
  }

  @override
  Future<bool> isCacheExpired(
    String organizationId, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final timestamp = await getCacheTimestamp(organizationId);
      if (timestamp == null) {
        return true;
      }
      final now = DateTime.now();
      final diff = now.difference(timestamp);
      return diff > maxAge;
    } catch (e) {
      throw const CacheException('Failed to check expired cache');
    }
  }

  @override
  Future<void> removeCahceOrganization(String organizationId) async {
    try {
      final key = '$_organizationPrefix$organizationId';
      final timestampKey = '$_timestampPrefix$organizationId';
      await secureStorage.delete(key: key);
      await secureStorage.delete(key: timestampKey);
    } catch (e) {
      throw const CacheException('Failed to remove cached organization');
    }
  }

  @override
  Future<void> updateCacheTimestamp(String organizationId) async {
    try {
      final timestampKey = '$_timestampPrefix$organizationId';
      final now = DateTime.now().toIso8601String();
      await secureStorage.write(key: timestampKey, value: now);
    } catch (e) {
      throw const CacheException('Failed to update cache timestamp');
    }
  }
}
