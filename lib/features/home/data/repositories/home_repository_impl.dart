import 'package:app/app/dependency_injection.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/data/datasources/home_local_data_source.dart';
import 'package:app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:app/features/home/domain/entities/saved_post.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;
  final HomeRemoteDataSource remoteDataSource;

  const HomeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // @override
  // Future<Either<Failure, void>> bookmarkPost(String postId) {
  //   // TODO: implement bookmarkPost
  //   throw UnimplementedError();
  // }

  @override
  Future<Either<Failure, void>> cachePosts(
    String userId,
    List<Post> posts,
  ) async {
    try {
      final postModels = posts
          .map((post) => PostModel.fromEntity(post))
          .toList();

      await localDataSource.cachePosts(userId, postModels);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedPosts(String userId) async {
    try {
      await localDataSource.clearCachedPosts(userId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getCachedPosts(String userId) async {
    try {
      final cachedPosts = await localDataSource.getCachedPosts(userId);
      if (cachedPosts != null) {
        return Right(cachedPosts.map((post) => post.toEntity()).toList());
      }
      return const Right([]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({String? nextCursor, List<Post> posts})>>
  getNearByPosts({
    required String userId,
    double? latitude,
    double? longitude,
    int limit = 15,
    String? cursor,
  }) async {
    try {
      // First check is cache is expired
      final isCacheExpired = await localDataSource.isCacheExpired(userId);
      // print(isCacheExpired);
      if (!isCacheExpired) {
        // Try to get the caches posts first
        final cachePosts = await localDataSource.getCachedPosts(userId);
        if (cachePosts != null && cachePosts.isNotEmpty) {
          final posts = cachePosts
              .map((postModel) => postModel.toEntity())
              .toList();
          return Right((posts: posts, nextCursor: null));
        }
      }

      // Fetch from remote if cache is expired or empty
      final remotePostModels = await remoteDataSource.getNearByPosts(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        cursor: cursor,
      );

      return remotePostModels.fold(
        (failure) {
          return Left(failure);
        },
        (data) async {
          // Save cache only for FIRST page
          if (cursor != null) {
            await localDataSource.cachePosts(userId, data.posts);
          }

          // Fetch the images related to the post
          final postRepo = DependencyInjection.get<PostRepository>();
          final enrichedPosts = await Future.wait(
            data.posts.map((post) async {
              final imagesResult = await postRepo
                  .getAllSpecificPostImagesByPostId(post.id);

              final additionalImageUrls = imagesResult.fold(
                (failure) => <String>[],
                (imgs) => imgs.map((e) => e.imageUrl).toList(),
              );

              // 3) Attach the images safely
              return post.toEntity().copyWith(
                additionalImagesForHomeFeed: additionalImageUrls,
              );
            }),
          );

          // final postEntities = data.posts
          //     .map((post) => post.toEntity())
          //     .toList();

          // print(postEntities);

          return Right((posts: enrichedPosts, nextCursor: data.nextCursor));
        },
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getRecommendedPosts({
    required String userId,
    int limit = 15,
  }) {
    // TODO: implement getRecommendedPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> likePost(String postId) {
    // TODO: implement likePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Post>>> refreshHomePage(String userId) {
    // TODO: implement refreshHomePage
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String postId) {
    // TODO: implement removeBookmark
    throw UnimplementedError();
  }

  @override
  Stream<Either<Failure, List<Post>>> subscribeToPosts(String userId) {
    try {
      // TODO
      throw UnimplementedError();
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost(String postId) {
    // TODO: implement unlikePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Organization>>
  getOrganizationDetailByPostOrganizationId(String organizationId) async {
    try {
      final remoteOrganizationDetails = await remoteDataSource
          .getOrganizationDetailByPostOrganizationId(organizationId);
      return remoteOrganizationDetails.fold(
        (failure) => Left(failure),
        (orgDetail) => Right(orgDetail.toEntity()),
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Organization>>>
  getOrganizationsBasedOnUserAndOthersPreferences({String? userId}) async {
    try {
      final response = await remoteDataSource
          .getOrganizationsBasedOnUserAndOthersPreferences();
      return response.fold(
        (failure) => Left(failure),
        (orgDetails) =>
            Right(orgDetails.map((orgDetail) => orgDetail.toEntity()).toList()),
      );
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> togglePostSaveOrUnsave(
    String userId,
    String postId,
    String organizationId,
  ) async {
    try {
      await remoteDataSource.togglePostSaveOrUnsave(
        userId,
        postId,
        organizationId,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<SavedPost>>> streamReactions(String userId) {
    try {
      return remoteDataSource
          .streamReactions(userId)
          .map<Either<Failure, List<SavedPost>>>(
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
}
