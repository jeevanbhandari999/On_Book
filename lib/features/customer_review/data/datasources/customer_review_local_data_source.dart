import 'dart:convert';

import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/customer_review/data/models/rating_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class CustomerReviewLocalDataSource {
  // Get the cached customer reviews related to the specific post
  Future<List<RatingModel>?> getCachedUserRatingsRelatedToThePost(
    String postId,
  );

  // Cache the user rating related to the post
  Future<void> cacheUseRatingRelatedToThePost(
    String postId,
    List<RatingModel> ratings,
  );

  // Clear cache user ratings related to the post
  Future<void> clearCachedUserRatings(String postId);

  // Get cache timestamp for an ratings
  Future<DateTime?> getCacheTimestamp(String postId);

  // Update cache timestamp for an ratingd
  Future<void> updateCacheTimestamp(String postId);

  // Check if cache is expired for an organization
  Future<bool> isCacheExpired(
    String postId, {
    Duration maxAge = const Duration(hours: 1),
  });

  // Clear all cached ratings
  Future<void> clearAllCachedUserRatings();

  // TODO. for single rating details view with cache id needed
}

class CustomerReviewLocalDataSourceImpl
    implements CustomerReviewLocalDataSource {
  final FlutterSecureStorage secureStorage;

  CustomerReviewLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Storage keys
  static const String _ratingsPrefix = 'user_ratings_';
  static const String _timestampPrefix = 'user_rating_timestamp';

  @override
  Future<void> cacheUseRatingRelatedToThePost(
    String postId,
    List<RatingModel> ratings,
  ) async {
    try {
      final key = '$_ratingsPrefix$postId';
      final jsonString = jsonEncode(
        ratings.map((rating) => rating.toJson()).toList(),
      );
      await secureStorage.write(key: key, value: jsonString);
    } catch (e) {
      throw CacheException('Failed to cache the user rating: $e');
    }
  }

  @override
  Future<void> clearAllCachedUserRatings() async {
    try {
      final allKeys = await secureStorage.readAll();

      final ratingKeys = allKeys.keys.where(
        (key) =>
            key.startsWith(_ratingsPrefix) || key.startsWith(_timestampPrefix),
      );
      for (final key in ratingKeys) {
        await secureStorage.delete(key: key);
      }
    } catch (e) {
      throw CacheException('Failed to clear all cached ratings: $e');
    }
  }

  @override
  Future<void> clearCachedUserRatings(String postId) async {
    try {
      final key = '$_ratingsPrefix$postId';
      await secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException(
        'Failed to clear cached user ratings related to this post: $e',
      );
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String postId) async {
    try {
      final key = '$_timestampPrefix$postId';
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
  Future<List<RatingModel>?> getCachedUserRatingsRelatedToThePost(
    String postId,
  ) async {
    try {
      final key = '$_ratingsPrefix$postId';
      final ratingJsonString = await secureStorage.read(key: key);
      if (ratingJsonString == null) return null;

      final List<dynamic> ratingList = jsonDecode(ratingJsonString);
      return ratingList
          .map((rating) => RatingModel.fromJson(rating as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(
        'Failed to get the cached user rating relate to this post: $e',
      );
    }
  }

  @override
  Future<bool> isCacheExpired(
    String postId, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final timestamp = await getCacheTimestamp(postId);
      if (timestamp == null) {
        return true;
      }
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference > maxAge;
    } catch (e) {
      return true;
    }
  }

  @override
  Future<void> updateCacheTimestamp(String postId) async {
    try {
      final key = '$_timestampPrefix$postId';
      final timestamp = DateTime.now().toIso8601String();

      await secureStorage.write(key: key, value: timestamp);
    } catch (e) {
      throw CacheException('Failed to update cache timestamp: $e');
    }
  }
}
