import 'dart:io';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_image.dart';
import 'package:app/features/post/domain/entities/post_video.dart';
import 'package:dartz/dartz.dart';

abstract class PostRepository {
  // Get all posts for a specific organization
  Future<Either<Failure, List<Post>>> getPostsByOrganizationId(
    String organizationId,
  );

  // Get all post's images for a specific organization
  Future<Either<Failure, List<PostImage>>> getPostsWithImagesByOrganizationId(
    String organizationId,
  );


  // Get all post's videos for a specific organization
  Future<Either<Failure, List<PostVideo>>> getPostsWithVideosByOrganizationId(
    String organizationId,
  );

  // Get a specific posts by its Id
  Future<Either<Failure, Post>> getPostById(String postId);

  // Create a new post with optional additional images
  Future<Either<Failure, Post>> createPost(
    Post post,
    List<File> additionalImages,
  );

  // Create a new post with short video
  Future<Either<Failure, Post>> createPostWithVideo(Post post, File videoFile);

  // Update an existing post
  Future<Either<Failure, Post>> updatePost(
    Post post,
    List<File> newImages,
    List<String> imagesToDelete,
    File newVideoFile,
    String videoToDelete,
  );

  // Delete a post and all associated data
  Future<Either<Failure, void>> deletePost(String postId);

  // Search posts within an organization
  Future<Either<Failure, List<Post>>> searchPosts(
    String organizationId,
    String query,
  );

  // Upload a single image and return the URl
  Future<Either<Failure, String>> uploadImage(
    File imageFile,
    String organizationId,
    String postId,
  );

  // Upload a multiple images and return their URls
  Future<Either<Failure, List<String>>> uploadImages(
    List<File> imageFiles,
    String organizationId,
    String postId,
  );

  // Upload a video and return the URL
  Future<Either<Failure, String>> uploadVideo(
    File videoFile,
    String organizationId,
    String postId,
  );

  // Delete an image from storage
  Future<Either<Failure, void>> deleteImage(String imageUrl);

  // Delete multiple images from storage
  Future<Either<Failure, void>> deleteImages(List<String> imageUrls);

  // Delete a video from storage
  Future<Either<Failure, void>> deleteVideo(String videoUrl);

  // Get cached posts for offline supports
  Future<Either<Failure, List<Post>>> getCachedPosts(String organizationId);

  // Cache posts locally
  Future<Either<Failure, void>> cachePosts(
    String organizationId,
    List<Post> posts,
  );

  // Clear cached posts for an organization
  Future<Either<Failure, void>> clearCachedPosts(String organizationId);

  // Subscribe to real time posts updates
  Stream<Either<Failure, List<Post>>> subscribeToPosts(String organizationId);

  // Check if user has permission to manage posts
  Future<Either<Failure, bool>> canManagePosts(
    String userId,
    String organizationId,
  );

  // Check if the user has permission to create posts
  Future<Either<Failure, bool>> canCreatePost(
    String userId,
    String organizationId,
  );

  // Check if the user can edit the post
  Future<Either<Failure, bool>> canEditPost(String userId, String postId);

  // Check if the user can delete the post
  Future<Either<Failure, bool>> canDeletePost(String userId, String postId);

  // Validate the post data before operations
  Future<Either<Failure, void>> validatePost(Post post);

  // Get posts counts for an organizaton
  Future<Either<Failure, int>> getPostsCount(String organizationId);

  // Get posts with pagination
  Future<Either<Failure, List<Post>>> getPaginatedPosts(
    String organizationId, {
    int page = 1,
    int limit = 20,
  });
}
