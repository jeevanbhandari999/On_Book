import 'dart:convert';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ProfileLocalDataSource {
  // Profiles details
  // Get the profile detail of the user through cache
  Future<UserModel?> getCachedProfileDetail(String userId);

  // Cache the profile detail of the user
  Future<void> cacheProfileDetail(String userId, UserModel profile);

  // Remove the profile detail(specific) from the cache
  Future<void> removeCachedProfile(String userId);

  // Clear all cached profiles detail
  Future<void> clearAllCachedProfiles();

  // Organizations details

  // Get cache timestamp for the profile, Last update time
  Future<DateTime?> getCacheTimestamp(String userId);

  // Update last cache time
  Future<void> updateCacheTimestamp(String userId);

  // Determine the cache expire date
  Future<bool> isCacheExpired(String userId, {Duration maxAge});
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final FlutterSecureStorage secureStorage;

  // Keys for the storage
  static const String _profilePrefix = 'profile_';
  static const String _timestampPrefix = 'profile_timestamp_';

  ProfileLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> cacheProfileDetail(String userId, UserModel profile) async {
    final key = '$_profilePrefix$userId';
    final value = jsonEncode(profile.toJson());

    await secureStorage.write(key: key, value: value);
    await updateCacheTimestamp(userId);
  }

  @override
  Future<UserModel?> getCachedProfileDetail(String userId) async {
    final key = '$_profilePrefix$userId';
    final value = await secureStorage.read(key: key);
    if (value == null) {
      return null;
    }

    final map = jsonDecode(value) as Map<String, dynamic>;
    return UserModel.fromJson(map);
  }

  @override
  Future<void> removeCachedProfile(String userId) async {
    final key = '$_profilePrefix$userId';
    final timestampKey = '$_timestampPrefix$userId';
    await secureStorage.delete(key: key);
    await secureStorage.delete(key: timestampKey);
  }

  @override
  Future<void> clearAllCachedProfiles() async {
    final allKeys = await secureStorage.readAll();

    final profileKeys = allKeys.keys.where(
      (key) =>
          key.startsWith(_profilePrefix) || key.startsWith(_timestampPrefix),
    );

    for (final key in profileKeys) {
      await secureStorage.delete(key: key);
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String userId) async {
    final timestampKey = '$_timestampPrefix$userId';
    final value = await secureStorage.read(key: timestampKey);
    // if (value == null) {
    //   return null;
    // }
    // DateTime.tryParse(value);
    // return null;
    value != null ? DateTime.tryParse(value) : null;
    return null; // to get rid of warning of not returning null.
  }

  @override
  Future<void> updateCacheTimestamp(String userId) async {
    final timestampKey = '$_timestampPrefix$userId';
    final now = DateTime.now().toIso8601String();
    await secureStorage.write(key: timestampKey, value: now);
  }

  @override
  Future<bool> isCacheExpired(
    String userId, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final timestamp = await getCacheTimestamp(userId);
    if (timestamp == null) {
      return true;
    }
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff > maxAge;
  }
}
