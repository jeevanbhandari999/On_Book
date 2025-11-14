import 'dart:io';

import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/data/datasources/post_local_data_source.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_image.dart';
import 'package:app/features/post/domain/entities/post_video.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;

  const PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Post>>> getPostsByOrganizationId(
    String organizationId,
  ) async {
    try {
      // Check if cache is expired
      final isCacheExpired = await localDataSource.isCacheExpired(
        organizationId,
      );
      if (!isCacheExpired) {
        // try to get the cached posts first
        final cachedPosts = await localDataSource.getCachedPosts(
          organizationId,
        );
        if (cachedPosts != null && cachedPosts.isNotEmpty) {
          return Right(
            cachedPosts.map((postModel) => postModel.toEntity()).toList(),
          );
        }
      }

      // fetch from remote if cache is expired or empty
      final postModels = await remoteDataSource.getPostsByOrganizationId(
        organizationId,
      );

      // Cache the fetched posts from the remote for offline support
      await localDataSource.cachePosts(organizationId, postModels);

      return Right(
        postModels.map((postModel) => postModel.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      // Try to return the cache data on server exception
      try {
        final cachedPosts = await localDataSource.getCachedPosts(
          organizationId,
        );
        if (cachedPosts != null && cachedPosts.isNotEmpty) {
          return Right(
            cachedPosts.map((postModel) => postModel.toEntity()).toList(),
          );
        }
      } catch (_) {
        // Ignore these cache errors when server is also failing
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Again try to rturn the cached data in network error
      try {
        final cachedPosts = await localDataSource.getCachedPosts(
          organizationId,
        );
        if (cachedPosts != null && cachedPosts.isNotEmpty) {
          return Right(
            cachedPosts.map((postModel) => postModel.toEntity()).toList(),
          );
        }
      } catch (_) {
        // Ignore these cache errors when network is also failing
      }
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostImage>>> getPostsWithImagesByOrganizationId(
    String organizationId,
  ) async {
    try {
      // Check if cache is expired
      // final isCacheExpired = await localDataSource.isCacheExpired(
      //   organizationId,
      // );
      // if (!isCacheExpired) {
      //   // try to get the cached posts first
      //   final cachedPosts = await localDataSource.getCachedPosts(
      //     organizationId,
      //   );
      //   if (cachedPosts != null && cachedPosts.isNotEmpty) {
      //     return Right(
      //       cachedPosts.map((postModel) => postModel.toEntity()).toList(),
      //     );
      //   }
      // }

      // fetch from remote if cache is expired or empty
      final postImageModels = await remoteDataSource
          .getPostsWithImagesByOrganizationId(organizationId);

      // Cache the fetched posts from the remote for offline support
      // await localDataSource.cachePosts(organizationId, postImageModels);

      return Right(
        postImageModels.map((postImageModel) => postImageModel.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      // Try to return the cache data on server exception
      // try {
      //   final cachedPosts = await localDataSource.getCachedPosts(
      //     organizationId,
      //   );
      //   if (cachedPosts != null && cachedPosts.isNotEmpty) {
      //     return Right(
      //       cachedPosts.map((postModel) => postModel.toEntity()).toList(),
      //     );
      //   }
      // } catch (_) {
      //   // Ignore these cache errors when server is also failing
      // }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Again try to rturn the cached data in network error
      // try {
      //   final cachedPosts = await localDataSource.getCachedPosts(
      //     organizationId,
      //   );
      //   if (cachedPosts != null && cachedPosts.isNotEmpty) {
      //     return Right(
      //       cachedPosts.map((postModel) => postModel.toEntity()).toList(),
      //     );
      //   }
      // } catch (_) {
      //   // Ignore these cache errors when network is also failing
      // }
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }


   @override
  Future<Either<Failure, List<PostVideo>>> getPostsWithVideosByOrganizationId(
    String organizationId,
  ) async {
    try {
      // Check if cache is expired
      // final isCacheExpired = await localDataSource.isCacheExpired(
      //   organizationId,
      // );
      // if (!isCacheExpired) {
      //   // try to get the cached posts first
      //   final cachedPosts = await localDataSource.getCachedPosts(
      //     organizationId,
      //   );
      //   if (cachedPosts != null && cachedPosts.isNotEmpty) {
      //     return Right(
      //       cachedPosts.map((postModel) => postModel.toEntity()).toList(),
      //     );
      //   }
      // }

      // fetch from remote if cache is expired or empty
      final postImageModels = await remoteDataSource
          .getPostsWithVideosByOrganizationId(organizationId);

      // Cache the fetched posts from the remote for offline support
      // await localDataSource.cachePosts(organizationId, postImageModels);

      return Right(
        postImageModels.map((postImageModel) => postImageModel.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      // Try to return the cache data on server exception
      // try {
      //   final cachedPosts = await localDataSource.getCachedPosts(
      //     organizationId,
      //   );
      //   if (cachedPosts != null && cachedPosts.isNotEmpty) {
      //     return Right(
      //       cachedPosts.map((postModel) => postModel.toEntity()).toList(),
      //     );
      //   }
      // } catch (_) {
      //   // Ignore these cache errors when server is also failing
      // }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Again try to rturn the cached data in network error
      // try {
      //   final cachedPosts = await localDataSource.getCachedPosts(
      //     organizationId,
      //   );
      //   if (cachedPosts != null && cachedPosts.isNotEmpty) {
      //     return Right(
      //       cachedPosts.map((postModel) => postModel.toEntity()).toList(),
      //     );
      //   }
      // } catch (_) {
      //   // Ignore these cache errors when network is also failing
      // }
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(String postId) async {
    try {
      //Try to get cached post first
      final cachedPost = await localDataSource.getCachedPost(postId);
      if (cachedPost != null) {
        return Right(cachedPost.toEntity());
      }

      // Fetch from remote if not cached
      final postModel = await remoteDataSource.getPostById(postId);

      // Cache the fetched post
      await localDataSource.cachePost(postModel);

      return Right(postModel.toEntity());
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
  Future<Either<Failure, Post>> createPost(
    Post post,
    List<File> additionalImages,
  ) async {
    try {
      // Validate post data
      final validationResult = await validatePost(post);
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected validation result'),
        );
      }

      // Convert entity to model
      final postModel = PostModel.fromEntity(post);

      // Create post remotely
      final createPostModel = await remoteDataSource.createPost(postModel);

      // Upload additional images if provided
      if (additionalImages.isNotEmpty) {
        final imageUrls = await remoteDataSource.uploadImages(
          additionalImages,
          post.organizationId,
          createPostModel.id,
        );

        // Add images to the posts
        final postImages = await remoteDataSource.addPostImages(
          createPostModel.id,
          imageUrls,
        );

        // Update the post model with additional images
        final updatedPostModel = createPostModel.copyWith(
          additionalImages: postImages,
        );

        // Ceche the created post
        await localDataSource.cachePost(createPostModel);

        // Invalidate organization posts cache
        await localDataSource.clearCachedPosts(post.organizationId);

        return Right(updatedPostModel.toEntity());
      }

      // Cache the created post
      await localDataSource.cachePost(createPostModel);

      // Invalidate organization posts cache
      await localDataSource.clearCachedPosts(post.organizationId);

      return Right(createPostModel.toEntity());
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
  Future<Either<Failure, Post>> createPostWithVideo(
    Post post,
    File videoFile,
  ) async {
    try {
      // Validate post data
      final validationResult = await validatePost(post);
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected validation result'),
        );
      }

      // Convert entity to model
      final postModel = PostModel.fromEntity(post);

      // Create post remotely
      final createPostModel = await remoteDataSource.createPost(postModel);

      final videoUrl = await remoteDataSource.uploadVideo(
        videoFile,
        post.organizationId,
        createPostModel.id,
      );

      await remoteDataSource.addPostVideo(createPostModel.id, videoUrl);

      // Update the post model with video
      final updatedPostModel = createPostModel.copyWith(videoUrl: videoUrl);

      // Ceche the created post
      await localDataSource.cachePost(createPostModel);

      // Invalidate organization posts cache
      await localDataSource.clearCachedPosts(post.organizationId);

      return Right(updatedPostModel.toEntity());
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
  Future<Either<Failure, Post>> updatePost(
    Post post,
    List<File> newImages,
    List<String> imagesToDelete,
    File newVideoFile,
    String videoToDelete,
  ) async {
    try {
      // Validate post data
      final validationResult = await validatePost(post);
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected validation result'),
        );
      }

      // Convert entity to model
      final postModel = PostModel.fromEntity(post);

      // Delete the specified images if provided
      if (imagesToDelete.isNotEmpty) {
        await remoteDataSource.deleteImages(imagesToDelete);

        // Remove from event_images table
        final imageIdsToRemove = <String>[];
        for (final imageUrl in imagesToDelete) {
          // TODO
          // Find image IDs that match the URLs (this would need to be implemented)
          // For now, we'll rely on the remote data source to handle this
        }
      }

      // Upload new images if provided
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        newImageUrls = await remoteDataSource.uploadImages(
          newImages,
          post.organizationId,
          post.id,
        );
        // Add new images to the post
        await remoteDataSource.addPostImages(post.id, newImageUrls);
      }

      // Update post remotely
      final updatedPostModel = await remoteDataSource.updatePost(
        post.id,
        postModel,
      );

      // Cache the updated post
      await localDataSource.cachePost(updatedPostModel);

      // Invalidate organization posts cache
      await localDataSource.clearCachedPosts(post.organizationId);

      return Right(updatedPostModel.toEntity());
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
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      // Get post details for organization Id
      final postResult = await getPostById(postId);
      if (postResult.isLeft()) {
        return postResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected post result'),
        );
      }

      final post = postResult.fold(
        (_) => throw Exception('Post not found.'),
        (post) => post,
      );

      // Delete post remotely
      await remoteDataSource.deletePost(postId);

      // Remove from local cache
      await localDataSource.removeCachedPost(postId);

      // Invalidate organization events cache
      await localDataSource.clearCachedPosts(post.organizationId);

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts(
    String organizationId,
    String query,
  ) async {
    try {
      // Check cached search results first
      final cachedResults = await localDataSource.getCacheSearchResults(
        organizationId,
        query,
      );
      if (cachedResults != null && cachedResults.isNotEmpty) {
        return Right(cachedResults.map((model) => model.toEntity()).toList());
      }

      // Search remotely
      final postModels = await remoteDataSource.searchPosts(
        organizationId,
        query,
      );

      // Cache search results
      await localDataSource.cacheSearchResults(
        organizationId,
        query,
        postModels,
      );

      return Right(postModels.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, String>> uploadImage(
    File imageFile,
    String organizationId,
    String postId,
  ) async {
    try {
      final imageUrl = await remoteDataSource.uploadImage(
        imageFile,
        organizationId,
        postId,
      );
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadImages(
    List<File> imageFiles,
    String organizationId,
    String postId,
  ) async {
    try {
      final imageUrls = await remoteDataSource.uploadImages(
        imageFiles,
        organizationId,
        postId,
      );
      return Right(imageUrls);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    try {
      await remoteDataSource.deleteImage(imageUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImages(List<String> imageUrls) async {
    try {
      await remoteDataSource.deleteImages(imageUrls);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadVideo(
    File videoFile,
    String organizationId,
    String postId,
  ) async {
    try {
      final videoUrl = await remoteDataSource.uploadVideo(
        videoFile,
        organizationId,
        postId,
      );
      return Right(videoUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVideo(String videoUrl) async {
    try {
      await remoteDataSource.deleteVideo(videoUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getCachedPosts(
    String organizationId,
  ) async {
    try {
      final cachedPosts = await localDataSource.getCachedPosts(organizationId);
      if (cachedPosts != null) {
        return Right(cachedPosts.map((model) => model.toEntity()).toList());
      }
      return const Right([]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cachePosts(
    String organizationId,
    List<Post> posts,
  ) async {
    try {
      final postModels = posts
          .map((post) => PostModel.fromEntity(post))
          .toList();
      await localDataSource.cachePosts(organizationId, postModels);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedPosts(String organizationId) async {
    try {
      await localDataSource.clearCachedPosts(organizationId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Post>>> subscribeToPosts(String organizationId) {
    try {
      return remoteDataSource
          .subscribeToPosts(organizationId)
          .map(
            (postModels) => Right<Failure, List<Post>>(
              postModels.map((model) => model.toEntity()).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> canManagePosts(
    String userId,
    String organizationId,
  ) async {
    try {
      final canManage = await remoteDataSource.canManagePosts(
        userId,
        organizationId,
      );
      return Right(canManage);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canCreatePost(
    String userId,
    String organizationId,
  ) async {
    try {
      return canManagePosts(userId, organizationId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canEditPost(
    String userId,
    String postId,
  ) async {
    try {
      //First of all get posts to find the organization id
      final postResult = await getPostById(postId);
      if (postResult.isLeft()) {
        return postResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected post result'),
        );
      }

      final post = postResult.fold(
        (_) => throw Exception('Post not found'),
        (post) => post,
      );

      return canManagePosts(userId, post.organizationId);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canDeletePost(
    String userId,
    String postId,
  ) async {
    // Same as can edit post
    try {
      return canEditPost(userId, postId);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> validatePost(Post post) async {
    try {
      final errors = <String>[];

      // Basic validations
      if (post.title.trim().isEmpty) {
        errors.add('Post title is required');
      }

      if (post.organizationId.trim().isEmpty) {
        errors.add('Organization ID is required');
      }

      // YouTube URL validation
      if (post.youtubeUrl != null && post.youtubeUrl!.isNotEmpty) {
        try {
          final uri = Uri.parse(post.youtubeUrl!);
          if (!(uri.host.contains('youtube.com') ||
                  uri.host.contains('youtu.be')) ||
              !uri.hasScheme ||
              !(uri.scheme == 'http' || uri.scheme == 'https')) {
            errors.add('Invalid YouTube URL format');
          }
        } catch (e) {
          errors.add('Invalid YouTube URL format');
        }
      }

      if (errors.isNotEmpty) {
        return Left(ValidationFailure(errors.join(', ')));
      }

      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPostsCount(String organizationId) async {
    try {
      final posts = await remoteDataSource.getPostsByOrganizationId(
        organizationId,
      );
      return Right(posts.length);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPaginatedPosts(
    String organizationId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final allPosts = await remoteDataSource.getPostsByOrganizationId(
        organizationId,
      );

      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= allPosts.length) {
        return const Right([]);
      }

      final paginatedPosts = allPosts.sublist(
        startIndex,
        endIndex > allPosts.length ? allPosts.length : endIndex,
      );

      return Right(paginatedPosts.map((post) => post.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
