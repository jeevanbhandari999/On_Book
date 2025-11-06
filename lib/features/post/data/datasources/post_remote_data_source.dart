import 'dart:io';

import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/core/services/cloudinary_service.dart';
import 'package:app/features/post/data/models/post_image_model.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/data/models/post_video_model.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PostRemoteDataSource {
  // Get all posts for a specific organization
  Future<List<PostModel>> getPostsByOrganizationId(String organizationId);

  // Get a specific post by its Id
  Future<PostModel> getPostById(String postId);

  // Create a new post
  Future<PostModel> createPost(PostModel post);

  // Update an existing post
  Future<PostModel> updatePost(String postId, PostModel post);

  // Delete an post
  Future<void> deletePost(String postId);

  // Search posts for an organization
  Future<List<PostModel>> searchPosts(String organizationId, String query);

  // Upload a single image to storage(cloudinary)
  Future<String> uploadImage(
    File imageFile,
    String organizationId,
    String postId,
  );

  // Upload multiple images to storage(cloudinary)
  Future<List<String>> uploadImages(
    List<File> imageFiles,
    String organizationId,
    String postId,
  );

  // Delete an image from storage
  Future<void> deleteImage(String imageUrl);

  // Delete multiple images from storage
  Future<void> deleteImages(List<String> imageUrls);

  // Add additional images to an post
  Future<List<PostImageModel>> addPostImages(
    String postId,
    List<String> imageUrls,
  );

  // Remove additional images from a post
  Future<void> removePostImages(List<String> imageIds);

  // upload a single video to storage
  Future<String> uploadVideo(
    File videoFile,
    String organizationId,
    String postId,
  );

  // Delete a video form storage
  Future<void> deleteVideo(String videoUrl);

  // Add post video
  Future<PostVideoModel> addPostVideo(String postId, String videoUrl);

  // Remove post video
  Future<void> removePostVideo(String postId);

  // Check user permissions for post operations
  Future<bool> canManagePosts(String userId, String organizationId);

  // Subscribe to real-time post updates
  Stream<List<PostModel>> subscribeToPosts(String organizationId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient supabaseClient;

  const PostRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PostImageModel>> addPostImages(
    String postId,
    List<String> imageUrls,
  ) {
    // TODO: implement addPostImages
    throw UnimplementedError();
  }

  @override
  Future<PostVideoModel> addPostVideo(String postId, String videoUrl) {
    // TODO: implement addPostVideo
    throw UnimplementedError();
  }

  @override
  Future<bool> canManagePosts(String userId, String organizationId) async {
    // // Get the current user to verify permissions
    // final user = supabaseClient.auth.currentUser;
    // if (user == null) {
    throw const core_exceptions.AuthException('User not authenticated');
    // }

    // // Check user permissions
    // final canCreate = await canManagePosts(userId, organizationId)
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    try {
      // Get the current user to verify permissions
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const core_exceptions.AuthException('User not authenticated');
      }

      // Check user permissions
      final canCreate = await canManagePosts(user.id, post.organizationId);
      if (!canCreate) {
        throw const core_exceptions.PermissionException(
          'Insufficient permissions to create posts',
        );
      }

      final response = await supabaseClient
          .from('posts')
          .insert(post.toCreateJson())
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      if (e is core_exceptions.AuthException ||
          e is core_exceptions.PermissionException) {
        rethrow;
      }
      throw core_exceptions.ServerException('Failed to create post: $e');
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) {
    // TODO: implement deleteImage
    throw UnimplementedError();
  }

  @override
  Future<void> deleteImages(List<String> imageUrls) {
    // TODO: implement deleteImages
    throw UnimplementedError();
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      // Get current user to verify permissions
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const core_exceptions.AuthException('User not authenticated');
      }

      // Check user permissions for this specific event
      final canDelete = await _canEditDeleteEvent(user.id, postId);
      if (!canDelete) {
        throw core_exceptions.PermissionException(
          'Insufficient permissions to delete this post',
        );
      }

      // First, get all images associated with the post to delete them from storage
      final postImagesResponse = await supabaseClient
          .from('post_images')
          .select('image_url')
          .eq('post_id', postId);

      final postResponse = await supabaseClient
          .from('posts')
          .select('primary_image_url')
          .eq('id', postId)
          .single();

      // Collect all image URls to delete
      final imageUrls = <String>[];

      // Add additional images
      for (final imageData in postImagesResponse) {
        final imageUrl = imageData['image_url'] as String?;
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      // Add primary image also
      final primaryImageUrl = postResponse['primary_image_url'] as String?;
      if (primaryImageUrl != null) {
        imageUrls.add(primaryImageUrl);
      }

      // Delete images from storage
      if (imageUrls.isNotEmpty) {
        await deleteImages(imageUrls);
      }

      // Delete the post (this will cascade delete post_image due to FK constraints)
      // TODO FK
      // TODO ratings, likes and others related to the posts later on
      await supabaseClient.from('posts').delete().eq('id', postId);
    } catch (e) {
      if (e is core_exceptions.AuthException ||
          e is core_exceptions.PermissionException) {
        rethrow;
      }
      throw core_exceptions.ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<void> deleteVideo(String videoUrl) {
    // TODO: implement deleteVideo
    throw UnimplementedError();
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select('''
            *,
            post_images (
              id,
              post_id,
              image_url,
              uploaded_by,
              updated_by,
              created_at,
              updated_at
            )
          ''')
          .eq('id', postId)
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getPostsByOrganizationId(
    String organizationId,
  ) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select('''
            *,
            post_images (
              id,
              post_id,
              image_url,
              uploaded_by,
              updated_by,
              created_at,
              updated_at
            )
          ''')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw core_exceptions.ServerException('Failed to fetch posts: $e');
    }
  }

  @override
  Future<void> removePostImages(List<String> imageIds) {
    // TODO: implement removePostImages
    throw UnimplementedError();
  }

  @override
  Future<void> removePostVideo(String postId) {
    // TODO: implement removePostVideo
    throw UnimplementedError();
  }

  @override
  Future<List<PostModel>> searchPosts(
    String organizationId,
    String query,
  ) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select('''
            *,
            post_images (
              id,
              post_id,
              image_url,
              uploaded_by,
              updated_by,
              created_at,
              updated_at
            )
          ''')
          .eq('organization_id', organizationId)
          .ilike('title', '%$query%')
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw core_exceptions.ServerException('Failed to search Posts: $e');
    }
  }

  @override
  Stream<List<PostModel>> subscribeToPosts(String organizationId) {
    try {
      return supabaseClient
          .from('posts')
          .stream(primaryKey: ['id'])
          .eq('organization_id', organizationId)
          .order('created_at', ascending: true)
          .map((data) => data.map((item) => PostModel.fromJson(item)).toList());
    } catch (e) {
      throw core_exceptions.ServerException('Failed to subscribe to posts: $e');
    }
  }

  @override
  Future<PostModel> updatePost(String postId, PostModel post) async {
    try {
      // Get current user to verify permissions
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const core_exceptions.AuthException('User not authenticated');
      }

      // Check user permissions for this specific event
      final canEdit = await _canEditDeleteEvent(user.id, postId);
      if (!canEdit) {
        throw core_exceptions.PermissionException(
          'Insufficient permissions to edit this post',
        );
      }

      final response = await supabaseClient
          .from('posts')
          .update(post.toUpdateJson())
          .eq('post_id', postId)
          .select('''
            *,
            post_images (
              id,
              post_id,
              image_url,
              uploaded_by,
              updated_by,
              created_at,
              updated_at
            )
          ''')
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      if (e is core_exceptions.AuthException ||
          e is core_exceptions.PermissionException) {
        rethrow;
      }
      throw core_exceptions.ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<String> uploadImage(
    File imageFile,
    String organizationId,
    String postId,
  ) async {
    try {
      final folderPath = '$organizationId/$postId';
      final response = await CloudinaryService.instance.cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folderPath,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw core_exceptions.ServerException('Filed to upload image: $e');
    }
  }

  @override
  Future<List<String>> uploadImages(
    List<File> imageFiles,
    String organizationId,
    String postId,
  ) async {
    try {
      final urls = <String>[];

      for (final imageFile in imageFiles) {
        final url = await uploadImage(imageFile, organizationId, postId);
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw core_exceptions.ServerException('Failed to upload images: $e');
    }
  }

  @override
  Future<String> uploadVideo(
    File videoFile,
    String organizationId,
    String postId,
  ) async {
    try {
      final folderPath = '$organizationId/$postId';
      final response = await CloudinaryService.instance.cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          videoFile.path,
          folder: folderPath,
          resourceType: CloudinaryResourceType.Video,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw core_exceptions.ServerException('Filed to upload image: $e');
    }
  }

  /// Helper method to check if user can delete a specific post
  Future<bool> _canEditDeleteEvent(String userId, String postId) async {
    try {
      // Get post details
      final postResponse = await supabaseClient
          .from('posts')
          .select('organization_id')
          .eq('id', postId)
          .single();

      final organizationId = postResponse['organization_id'] as String;
      return await canManagePosts(userId, organizationId);
    } catch (e) {
      return false;
    }
  }
}
