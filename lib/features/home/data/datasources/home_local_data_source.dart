import 'dart:convert';

import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class HomeLocalDataSource {
  // Get cached posts for a specific user
  Future<List<PostModel>?> getCachedPosts(String userId);

  // Cache posts for the specific user
  Future<void> cachePosts(String userId, List<PostModel> posts);

  // Remove all cached posts for specific users
  Future<void> clearCachedPosts(String userId);

  // Clear all cachedPosts
  Future<void> clearAllCachedPosts();

  // Get cache timestamp for a specific user
  Future<DateTime?> getCacheTimestamp(String userId);

  // Update cache timestamp for a specific user
  Future<void> updateCacheTimestamp(String userId);

  // Check if cache is expired for a specific user
  Future<bool> isCacheExpired(
    String userId, {
    Duration maxAge = const Duration(hours: 1),
  });
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final FlutterSecureStorage secureStorage;

  // Storage keys
  static const String _homePostsPrefix = 'home_posts_';
  static const String _homeTimestampPrefix = 'home_post_timestamp_';

  HomeLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();
  @override
  Future<void> cachePosts(String userId, List<PostModel> posts) async {
    try {
      final key = '$_homePostsPrefix$userId';
      final postJson = jsonEncode(
        posts.map((postModel) => postModel.toJson()).toList(),
      );

      await secureStorage.write(key: key, value: postJson);

      // Update the timestamp too
      await updateCacheTimestamp(userId);
    } catch (e) {
      throw CacheException('Failed to cache home page posts: $e');
    }
  }

  @override
  Future<void> clearAllCachedPosts() async {
    try {
      // First get all keys
      final allKeys = await secureStorage.readAll();

      // Filter the related keys to the home page posts
      final homePostsKeys = allKeys.keys.where(
        (key) =>
            key.startsWith(_homePostsPrefix) ||
            key.startsWith(_homeTimestampPrefix),
      );

      // Delete all home page posts related to these keys
      for (final key in homePostsKeys) {
        await secureStorage.delete(key: key);
      }
    } catch (e) {
      throw CacheException('Failed to clear all home page posts: $e');
    }
  }

  @override
  Future<void> clearCachedPosts(String userId) async {
    try {
      // Clear home page posts lists
      final key = '$_homePostsPrefix$userId';
      await secureStorage.delete(key: key);

      // Clear timestamp
      final timestampKey = '$_homeTimestampPrefix$userId';
      await secureStorage.delete(key: timestampKey);
    } catch (e) {
      throw CacheException('Failed to clear home page posts: $e');
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String userId) async {
    try {
      final key = '$_homeTimestampPrefix$userId';
      final timestampString = await secureStorage.read(key: key);

      if (timestampString != null) {
        return DateTime.parse(timestampString);
      }

      return null;
    } catch (e) {
      throw CacheException('Failed to get cache timestamp: $e');
    }
  }

  @override
  Future<List<PostModel>?> getCachedPosts(String userId) async {
    try {
      final key = '$_homePostsPrefix$userId';
      final homePostsJson = await secureStorage.read(key: key);
      if (homePostsJson != null) {
        final homePostList = jsonDecode(homePostsJson) as List<dynamic>;

        return homePostList
            .map(
              (homePost) =>
                  PostModel.fromJson(homePost as Map<String, dynamic>),
            )
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cache home page posts: $e');
    }
  }

  @override
  Future<bool> isCacheExpired(
    String userId, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final timestamp = await getCacheTimestamp(userId);
      if (timestamp == null) {
        // No cache exists, consider it expired
        return true;
      }

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference > maxAge;
    } catch (e) {
      // Onerror just consider the cache expired
      return true;
    }
  }

  @override
  Future<void> updateCacheTimestamp(String userId) async {
    try {} catch (e) {
      throw CacheException('Failed to clear all home page posts: $e');
    }
  }
}
