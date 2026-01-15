import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/data/datasources/customer_review_local_data_source.dart';
import 'package:app/features/customer_review/data/datasources/customer_review_remote_data_source.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/repositories/customer_review_repository.dart';
import 'package:dartz/dartz.dart';

class CustomerReviewRepositoryImpl implements CustomerReviewRepository {
  final CustomerReviewLocalDataSource localDataSource;
  final CustomerReviewRemoteDataSource remoteDataSource;

  const CustomerReviewRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> cacheUserRatingsRelatedToThePost(
    String postId,
    List<Rating> ratings,
  ) async {
    // TODO: implement cacheUserRatingsRelatedToThePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> clearCachedRatingsRelatedToThePost(
    String postId,
  ) async {
    // TODO: implement clearCachedRatingsRelatedToThePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Rating>> createRating(
    String userId,
    String postId,
    Rating rating,
  ) async {
    // TODO: implement createRating
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Rating>>> getAllCachedUserRatingsRelatedToThePost(
    String postId,
  ) async {
    // TODO: implement getAllCachedUserRatingsRelatedToThePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Rating>>> getAllUserRatingsRelatedToThePost(
    String postId,
  ) async {
    // TODO: implement getAllUserRatingsRelatedToThePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Rating>>> getPaginatedUserRatingRelatedToThePost(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: implement getPaginatedUserRatingRelatedToThePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> isRatingOwnerLoggedIn(String userId) async {
    // TODO: implement isRatingOwnerLoggedIn
    throw UnimplementedError();
  }

  @override
  Stream<Either<Failure, List<Rating>>> subscribeToRatings(String postId) {
    // TODO: implement subscribeToRatings
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Rating>> updateRating(
    String ratingId,
    String userId,
    Rating existingRating,
  ) async {
    // TODO: implement updateRating
    throw UnimplementedError();
  }
}
