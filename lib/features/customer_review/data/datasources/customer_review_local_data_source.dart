import 'package:app/features/customer_review/data/models/rating_model.dart';

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
}
