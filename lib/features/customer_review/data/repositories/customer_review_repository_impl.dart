import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/data/datasources/customer_review_local_data_source.dart';
import 'package:app/features/customer_review/data/datasources/customer_review_remote_data_source.dart';
import 'package:app/features/customer_review/data/models/rating_model.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
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
    try {
      final models = ratings.map(RatingModel.fromEntity).toList();
      await localDataSource.cacheUseRatingRelatedToThePost(postId, models);
      await localDataSource.updateCacheTimestamp(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedRatingsRelatedToThePost(
    String postId,
  ) async {
    try {
      await localDataSource.clearCachedUserRatings(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Rating>> createRating(
    String userId,
    String postId,
    Rating rating,
  ) async {
    try {
      final model = RatingModel.fromEntity(rating);
      final result = await remoteDataSource.createRating(userId, postId, model);
      await localDataSource.clearCachedUserRatings(postId);

      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Rating>>> getAllCachedUserRatingsRelatedToThePost(
    String postId,
  ) async {
    try {
      final cached = await localDataSource.getCachedUserRatingsRelatedToThePost(
        postId,
      );

      if (cached == null) {
        return const Left(CacheFailure('No cached ratings'));
      }

      return Right(cached.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Rating>>> getAllUserRatingsRelatedToThePost(
    String postId,
    String? userId,
  ) async {
    try {
      final isExpired = await localDataSource.isCacheExpired(postId);

      if (!isExpired) {
        final cached = await localDataSource
            .getCachedUserRatingsRelatedToThePost(postId);
        if (cached != null) {
          return Right(cached.map((e) => e.toEntity()).toList());
        }
      }

      final remote = await remoteDataSource.getUserRatingRelatedToThePost(
        postId,
      );

      await localDataSource.cacheUseRatingRelatedToThePost(postId, remote);
      await localDataSource.updateCacheTimestamp(postId);

      return Right(remote.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Rating>>> getPaginatedUserRatingRelatedToThePost(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // TODO
      throw UnimplementedError();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isRatingOwnerLoggedIn(String userId) async {
    try {
      final result = await remoteDataSource.isRatingOwnerLoggedIn(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Rating>>> subscribeToRatings(String postId) {
    throw Exception();
  }

  @override
  Future<Either<Failure, Rating>> updateRating(
    String ratingId,
    String userId,
    Rating existingRating,
  ) async {
    try {
      final model = RatingModel.fromEntity(existingRating);

      final updated = await remoteDataSource.updateRating(
        ratingId,
        userId,
        model,
      );

      await localDataSource.clearCachedUserRatings(existingRating.postId);

      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getReactionCounts(
    String ratingId,
  ) async {
    try {
      final count = await remoteDataSource.getReactionCounts(ratingId);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ReviewReaction>>> streamReactions(
    String ratingId,
  ) {
    try {
      return remoteDataSource
          .streamReactions(ratingId)
          .map<Either<Failure, List<ReviewReaction>>>(
            (models) => Right(models.map((m) => m.toEntity()).toList()),
          )
          .handleError((error) {
            if (error is ServerException) {
              return Left(ServerFailure(error.message));
            } else if (error is NetworkException) {
              return Left(NetworkFailure(error.message));
            } else if (error is AuthException) {
              return Left(AuthFailure(error.message));
            } else {
              return Left(UnknownFailure(error.toString()));
            }
          });
    } catch (e) {
      return Stream.value(Left(UnknownFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> toggleReaction({
    required String ratingId,
    required String userId,
    required ReviewReactionType reaction,
  }) async {
    try {
      await remoteDataSource.toggleReaction(
        ratingId: ratingId,
        userId: userId,
        reaction: reaction,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
