import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:dartz/dartz.dart';

abstract class CustomerReviewRepository {
  // Get all user rating data related to the post
  Future<Either<Failure, List<Rating>>> getAllUserRatingsRelatedToThePost(
    String postId,
    String? userId,
  );

  // Create a new rating, or rate a post
  Future<Either<Failure, Rating>> createRating(
    String userId,
    String postId,
    Rating rating,
  );

  // Update rating data by the user
  Future<Either<Failure, Rating>> updateRating(
    String ratingId,
    String userId,
    Rating existingRating,
  );

  // Check whether the logged in user have already rated the post
  Future<Either<Failure, bool>> isRatingOwnerLoggedIn(String userId);

  // Get all cached user ratings data related to the post
  Future<Either<Failure, List<Rating>>> getAllCachedUserRatingsRelatedToThePost(
    String postId,
  );

  // Cache ratings data locally
  Future<Either<Failure, void>> cacheUserRatingsRelatedToThePost(
    String postId,
    List<Rating> ratings,
  );

  // Clear cached ratings data related to the post
  Future<Either<Failure, void>> clearCachedRatingsRelatedToThePost(
    String postId,
  );

  // Subscribe to real time rating updates
  Stream<Either<Failure, List<Rating>>> subscribeToRatings(String postId);

  // Check if the user can update the rating
  // TODO

  // Get ratings data with pagination
  Future<Either<Failure, List<Rating>>> getPaginatedUserRatingRelatedToThePost(
    String postId, {
    int page = 1,
    int limit = 20,
  });
}
