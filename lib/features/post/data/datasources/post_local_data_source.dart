import 'dart:convert';

import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class PostLocalDataSource {
  // Get cached posts for a specific organization
  Future<List<PostModel>?> getCachedPosts(String organizationId);

  // Cache posts for a specific organization
  Future<void> cachePosts(String organizationId, List<PostModel> posts);

  // Get a specific cached post by Id
  Future<PostModel?> getCachedPost(String postId);

  // Cache a single post
  Future<void> cachePost(PostModel post);

  // Remove a cached post
  Future<void> removeCachedPost(String postId);

  // Clear all cached posts for an organization
  Future<void> clearCachedPosts(String organizationId);

  // Clear all cached posts
  Future<void> clearAllCachedPosts();

  // Get cachetimestamp for an organization
  Future<DateTime?> getCacheTimestamp(String organizationId);

  // Update cache Timestamp for an organization
  Future<void> updateCacheTimestamp(String organizationId);

  // Check if cache is expired for an organization
  Future<bool> isCacheExpired(
    String organizationId, {
    Duration maxAge = const Duration(hours: 1),
  });

  // Get cached search results
  Future<List<PostModel>?> getCacheSearchResults(
    String organizationId,
    String query,
  );

  // Cache search results
  Future<void> cacheSearchResults(
    String organizationId,
    String query,
    List<PostModel> results,
  );

  // Clear cached search results
  Future<void> clearCachedSearchResults(String organizationId);
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final FlutterSecureStorage secureStorage;

  // Storage keys
  static const String _postsPrefix = 'posts_';
  static const String _postPrefix = 'post_';
  static const String _timestampPrifix = 'post_timestamp_';
  static const String _searchPrefix = 'post_search_';

  PostLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> cachePost(PostModel post) async {
    try {
      final key = '$_postPrefix${post.id}';
      final postJson = jsonEncode(post.toJson());

      await secureStorage.write(key: key, value: postJson);
    } catch (e) {
      throw CacheException('Failed to cache Post: $e');
    }
  }

  @override
  Future<void> cachePosts(String organizationId, List<PostModel> posts) async {
    try {
      final key = '$_postsPrefix$organizationId';
      final postsJson = jsonEncode(posts.map((post) => post.toJson()).toList());

      await secureStorage.write(key: key, value: postsJson);

      // Also create a individual posts for a quick access
      for (final post in posts) {
        await cachePost(post);
      }

      // Update cache timestamp
      await updateCacheTimestamp(organizationId);
    } catch (e) {
      throw CacheException('Failed to cache Posts: $e');
    }
  }

  @override
  Future<void> cacheSearchResults(
    String organizationId,
    String query,
    List<PostModel> results,
  ) async {
    try {
      final key = '$_searchPrefix${organizationId}_${query.toLowerCase()}';
      final resultJson = jsonEncode(
        results.map((post) => post.toJson()).toList(),
      );

      await secureStorage.write(key: key, value: resultJson);
    } catch (e) {
      throw CacheException('Failed to cache search results: $e');
    }
  }

  @override
  Future<void> clearAllCachedPosts() async {
    try {
      // Get all keys
      final allKeys = await secureStorage.readAll();

      // Filter keys only related to the posts
      final postKeys = allKeys.keys.where(
        (key) =>
            key.startsWith(_postPrefix) ||
            key.startsWith(_postsPrefix) ||
            key.startsWith(_timestampPrifix) ||
            key.startsWith(_searchPrefix),
      );

      // Delete all posts related keys
      for (final key in postKeys) {
        await secureStorage.delete(key: key);
      }
    } catch (e) {
      throw CacheException('Failed to clear all cached posts: $e');
    }
  }

  @override
  Future<void> clearCachedPosts(String organizationId) async {
    try {
      // Clear organization posts list
      final key = '$_postsPrefix$organizationId';
      await secureStorage.delete(key: key);

      // Clear timestamp
      final timestampKey = '$_timestampPrifix$organizationId';
      await secureStorage.delete(key: timestampKey);

      // Clear search results
      await clearCachedSearchResults(organizationId);
    } catch (e) {
      throw CacheException('Failed to clear cached posts: $e');
    }
  }

  @override
  Future<void> clearCachedSearchResults(String organizationId) async {
    try {
      // Get all keys
      final allKeys = await secureStorage.readAll();

      // Filter search keys for this organization
      final searchKeys = allKeys.keys.where(
        (key) => key.startsWith('$_searchPrefix$organizationId'),
      );

      // Delete all search keys for this organization
      for (final key in searchKeys) {
        await secureStorage.delete(key: key);
      }
    } catch (e) {
      throw CacheException('Failed to clear cached search results: $e');
    }
  }

  @override
  Future<List<PostModel>?> getCacheSearchResults(
    String organizationId,
    String query,
  ) async {
    try {
      final key = '$_searchPrefix${organizationId}_${query.toLowerCase()}';
      final resultsJson = await secureStorage.read(key: key);

      if (resultsJson != null) {
        final resultsList = jsonDecode(resultsJson) as List<dynamic>;
        return resultsList
            .map(
              (postJson) =>
                  PostModel.fromJson(postJson as Map<String, dynamic>),
            )
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached search results: $e');
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String organizationId) async {
    try {
      final key = '$_timestampPrifix$organizationId';
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
  Future<PostModel?> getCachedPost(String postId) async {
    try {
      final key = '$_postPrefix$postId';
      final postJson = await secureStorage.read(key: key);
      if (postJson != null) {
        final postMap = jsonDecode(postJson) as Map<String, dynamic>;
        return PostModel.fromJson(postMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get the cached post: $e');
    }
  }

  @override
  Future<List<PostModel>?> getCachedPosts(String organizationId) async {
    try {
      final key = '$_postsPrefix$organizationId';
      final postsJson = await secureStorage.read(key: key);

      if (postsJson != null) {
        final postsList = jsonDecode(postsJson) as List<dynamic>;
        return postsList
            .map(
              (postJson) =>
                  PostModel.fromJson(postJson as Map<String, dynamic>),
            )
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get the cached posts: $e');
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
        // No cache exists, consider it expired
        return true;
      }

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference > maxAge;
    } catch (e) {
      // On error, just consider that the cache expired
      return true;
    }
  }

  @override
  Future<void> removeCachedPost(String postId) async {
    try {
      final key = '$_postPrefix$postId';
      await secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException('Failed to remove the cached post: $e');
    }
  }

  @override
  Future<void> updateCacheTimestamp(String organizationId) async {
    try {
      final key = '$_timestampPrifix$organizationId';
      final timestamp = DateTime.now().toIso8601String();

      await secureStorage.write(key: key, value: timestamp);
    } catch (e) {
      throw CacheException('Failed to update the cache timestamp: $e');
    }
  }
}
