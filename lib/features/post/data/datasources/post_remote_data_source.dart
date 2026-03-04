import 'dart:async';
import 'dart:io';

import 'package:app/app/dependency_injection.dart';
import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/core/services/cloudinary_service.dart';
import 'package:app/features/post/data/models/post_image_model.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/data/models/post_video_model.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PostRemoteDataSource {
  // Get all posts for a specific organization
  Future<List<PostModel>> getPostsByOrganizationId(String organizationId);

  // Get all posts for a specific organization
  // Future<List<PostModel>> getPostsWithVideosByOrganizationId(String organizationId);

  // Get all posts for a specific organization
  Future<List<PostImageModel>> getPostsWithImagesByOrganizationId(
    String organizationId,
  );

  // Get all images related to the specific post
  Future<List<PostImageModel>> getAllSpecificPostImagesByPostId(String postId);

  // Get all posts for a specific organization
  Future<List<PostVideoModel>> getPostsWithVideosByOrganizationId(
    String organizationId,
  );

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
  Future<void> removePostImages(List<String> imageUrls);

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

  // Booking related updation
  Future<void> updatePostStatus({
    required String postId,
    required String status,
  });

  // Algorithm implementations
  Future<List<PostModel>> getRelatedPosts({
    required String userId,
    required PostModel currentPost,
    int limit = 10,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient supabaseClient;

  const PostRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PostImageModel>> addPostImages(
    String postId,
    List<String> imageUrls,
  ) async {
    try {
      final imagesToInsert = imageUrls
          .map(
            (url) => {
              'post_id': postId,
              'image_url': url,
              'uploaded_by': supabaseClient.auth.currentUser!.id,
              'updated_by': supabaseClient.auth.currentUser!.id,
            },
          )
          .toList();

      final response = await supabaseClient
          .from('post_images')
          .insert(imagesToInsert)
          .select();
      final data = response as List<dynamic>;

      return data
          .map((item) => PostImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw core_exceptions.ServerException('Failed to add post images: $e');
    }
  }

  @override
  Future<PostVideoModel> addPostVideo(String postId, String videoUrl) async {
    try {
      final videoToInsert = {
        'post_id': postId,
        'video_url': videoUrl,
        'uploaded_by': supabaseClient.auth.currentUser!.id,
        'updated_by': supabaseClient.auth.currentUser!.id,
      };

      final response = await supabaseClient
          .from('post_videos')
          .insert(videoToInsert)
          .select()
          .single();

      return PostVideoModel.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Failed to add post images: $e');
    }
  }

  @override
  Future<bool> canManagePosts(String userId, String organizationId) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select('role, organization_id')
          .eq('user_id', userId)
          .single();

      final role = response['role'] as String?;
      final userOrgId = response['organization_id'] as String?;

      // Admin can manage all posts
      if (role == 'admin') return true;

      // Manager can manage posts in their organization
      if (role == 'manager' && userOrgId == organizationId) return true;

      // Owner can manage posts in their organization
      if (role == 'owner' && userOrgId == organizationId) return true;

      return false;
    } catch (e) {
      throw core_exceptions.ServerException('Failed to check permissions: $e');
    }
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
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final publicIndex = pathSegments.indexOf('public');

      if (publicIndex != -1 && publicIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(publicIndex + 1).join('/');
        await supabaseClient.storage.from('post-images').remove([filePath]);
      }
    } catch (e) {
      throw core_exceptions.ServerException('Failed to delete image: $e');
    }
  }

  @override
  Future<void> deleteImages(List<String> imageUrls) async {
    try {
      final filePaths = <String>[];

      for (final imageUrl in imageUrls) {
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        final publicIndex = pathSegments.indexOf('public');

        if (publicIndex != -1 && publicIndex < pathSegments.length - 1) {
          final filePath = pathSegments.sublist(publicIndex + 1).join('/');
          filePaths.add(filePath);
        }
      }

      if (filePaths.isNotEmpty) {
        await supabaseClient.storage.from('post-images').remove(filePaths);
      }
    } catch (e) {
      throw core_exceptions.ServerException('Failed to delete images: $e');
    }
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
        throw const core_exceptions.PermissionException(
          'Insufficient permissions to delete this post',
        );
      }

      // First, get all images associated with the post to delete them from storage
      final postImagesResponse = await supabaseClient
          .from('post_images')
          .select('image_url')
          .eq('post_id', postId);

      // Collect all image URls to delete
      final imageUrls = <String>[];

      // Add additional images
      for (final imageData in postImagesResponse) {
        final imageUrl = imageData['image_url'] as String?;
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      final postResponse = await supabaseClient
          .from('posts')
          .select()
          .eq('id', postId)
          .maybeSingle();

      // Add primary image also
      final primaryImageUrl = postResponse?['primary_image_url'] as String?;
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
    final postService = DependencyInjection.get<PostServices>();
    try {
      print('Hello');

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

      final post = PostModel.fromJson(response);
      final currentUserId = postService.getCurrentUserId();
      if (currentUserId != null) {
        // print(
        //   'Trigger calling with userId: $currentUserId and post id: ${post.id}',
        // );

        // unawaited(
        //   supabaseClient.rpc(
        //     'add_post_view',
        //     params: {'p_post_id': postId, 'p_user_id': currentUserId},
        //   ),
        // );

        await supabaseClient.rpc(
          'add_post_view',
          params: {'p_post_id': postId, 'p_user_id': currentUserId},
        );

        // try {
        //   final res = await supabaseClient.rpc(
        //     'add_post_view',
        //     params: {'p_post_id': postId, 'p_user_id': currentUserId},
        //   );

        //   print('RPC success: $res');
        // } catch (e) {
        //   print('RPC failed: $e');
        // }
      }

      return post;
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
  Future<List<PostImageModel>> getPostsWithImagesByOrganizationId(
    String organizationId,
  ) async {
    try {
      final response = await supabaseClient
          .from('post_images')
          .select('*, posts!inner(organization_id)')
          .eq('posts.organization_id', organizationId)
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((item) => PostImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw core_exceptions.ServerException('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<PostImageModel>> getAllSpecificPostImagesByPostId(
    String postId,
  ) async {
    try {
      final response = await supabaseClient
          .from('post_images')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((item) => PostImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw core_exceptions.ServerException('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<PostVideoModel>> getPostsWithVideosByOrganizationId(
    String organizationId,
  ) async {
    try {
      final response = await supabaseClient
          .from('post_videos')
          .select('*, posts!inner(organization_id)')
          .eq('posts.organization_id', organizationId)
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;
      return data
          .map((item) => PostVideoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw core_exceptions.ServerException('Failed to fetch posts: $e');
    }
  }

  @override
  Future<void> removePostImages(List<String> imageUrls) async {
    try {
      await supabaseClient
          .from('post_images')
          .delete()
          .inFilter('image_url', imageUrls);
    } catch (e) {
      throw core_exceptions.ServerException(
        'Failed to remove event images: $e',
      );
    }
  }

  @override
  Future<void> removePostVideo(String postId) async {
    try {
      await supabaseClient.from('post_images').delete().eq('id', postId);
    } catch (e) {
      throw core_exceptions.ServerException(
        'Failed to remove event images: $e',
      );
    }
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
        throw const core_exceptions.PermissionException(
          'Insufficient permissions to edit this post',
        );
      }

      final response = await supabaseClient
          .from('posts')
          .update(post.toUpdateJson())
          .eq('id', postId)
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
      // To delete the images from cloudinary, it is little bit hard, so i use the supabase directly,
      // final folderPath = '$organizationId/$postId';
      // final response = await CloudinaryService.instance.cloudinary.uploadFile(
      //   CloudinaryFile.fromFile(
      //     imageFile.path,
      //     folder: folderPath,
      //     resourceType: CloudinaryResourceType.Image,
      //   ),
      // );

      // return response.secureUrl;

      // Generate unique filename
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$organizationId/$postId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload to Supabase Storage
      await supabaseClient.storage
          .from('post-images')
          .upload(fileName, imageFile);

      // Get public URL
      final url = supabaseClient.storage
          .from('post-images')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      // print('Here is the error');
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

  @override
  Future<void> updatePostStatus({
    required String postId,
    required String status,
  }) async {
    try {
      await supabaseClient
          .from('posts')
          .update({'status': status})
          .eq('id', postId);
    } catch (e) {
      throw core_exceptions.ServerException('Failed to update post status: $e');
    }
  }

  // ALGORITHM IMPLEMENTATIONS

  @override
  Future<List<PostModel>> getRelatedPosts({
    required String userId,
    required PostModel currentPost,
    int limit = 10,
  }) async {
    try {
      final interestMap = await _buildInterestMap(userId);

      final response = await supabaseClient
          .from('posts')
          .select('*, post_images(*)')
          .neq('id', currentPost.id)
          .overlaps('tags', currentPost.tags!)
          .limit(limit * 3);

      final List<Map<String, dynamic>> raw = (response as List)
          .cast<Map<String, dynamic>>();

      final scored = raw.map((json) {
        final score = _contentScore(
          tagsRaw: json['tags'],
          amenitiesRaw: json['amenities'],
          freq: interestMap,
          maxFreq: interestMap.isEmpty
              ? 1
              : interestMap.values.reduce((a, b) => a > b ? a : b),
        );

        return MapEntry(json, score);
      }).toList()..sort((a, b) => b.value.compareTo(a.value));

      final posts = scored
          .take(limit)
          .map((e) => PostModel.fromJson(e.key))
          .toList();

      return posts;
    } catch (e) {
      throw core_exceptions.ServerException('Failed to get related posts: $e');
    }
  }

  // Helpers methods
  double _contentScore({
    required dynamic tagsRaw,
    required dynamic amenitiesRaw,
    required Map<String, double> freq,
    required double maxFreq,
  }) {
    if (freq.isEmpty) return 0;

    final signals = <String>[...?_asList(tagsRaw), ...?_asList(amenitiesRaw)];
    if (signals.isEmpty) return 0;

    double total = 0;
    for (final s in signals) {
      total += (freq[s] ?? 0) / maxFreq;
    }

    return (total / signals.length).clamp(0.0, 1.0);
  }

  List<String>? _asList(dynamic raw) {
    if (raw is List) return raw.whereType<String>().toList();
    return null;
  }

  Future<Map<String, double>> _buildInterestMap(String userId) async {
    try {
      final saved = await supabaseClient
          .from('user_saved_posts')
          .select('posts(tags, amenities)')
          .eq('user_id', userId)
          .limit(30);

      final Map<String, double> freq = {};

      void extract(dynamic raw) {
        if (raw is List) {
          for (final item in raw) {
            if (item is String && item.isNotEmpty) {
              freq[item] = (freq[item] ?? 0) + 1.0;
            }
          }
        }
      }

      for (final row in saved as List) {
        final post = row['posts'] as Map<String, dynamic>?;
        if (post == null) continue;
        extract(post['tags']);
        extract(post['amenities']);
      }

      return freq;
    } catch (_) {
      return {};
    }
  }
}


// 

