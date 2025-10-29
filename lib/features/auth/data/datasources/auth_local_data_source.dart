import 'dart:convert';
import 'package:app/core/constants/app_constants.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  // Get cached user
  Future<UserModel?> getCachedUser();

  // Cache the user
  Future<void> cacheUser(UserModel user);

  // Clear the cache data
  Future<void> clearCache();

  // Get token
  Future<String?> getToken();

  // Cache the taken
  Future<void> cacheToken(String token);

  // Claer the token
  Future<void> clearToken();

  // Check if logged in or not
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

    @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = await secureStorage.read(key: AppConstants.userDataKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: userJson,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: AppConstants.userTokenKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await secureStorage.write(
        key: AppConstants.userTokenKey,
        value: token,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await secureStorage.delete(key: AppConstants.userTokenKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final user = await getCachedUser();
      return token != null && user != null;
    } catch (e) {
      return false;
    }
  }
}
