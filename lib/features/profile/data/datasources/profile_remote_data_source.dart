import 'dart:io';

import 'package:app/core/errors/exceptions.dart' as core_exception;
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  // Get the profile details of the user
  Future<UserModel> getProfileDetailById(String userId);

  // Update the profile
  Future<UserModel> updateProfile(String userId, UserModel profile);

  // Upload the image to the bucket
  Future<String> uploadAvatar(File avatarFile, String userId);

  // Delete the image from the bucket
  Future<void> deleteAvatar(String avatarUrl);

  // Update the avatar image of the user
  Future<UserModel> updateAvatarUrl(String userId, String avatarUrl);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;
  const ProfileRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> getProfileDetailById(String userId) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException('Failed to get profile detail $e');
    }
  }

  @override
  Future<UserModel> updateProfile(String userId, UserModel profile) async {
    try {
      final response = await supabaseClient
          .from('users')
          .update(profile.toUpdateJson())
          .eq('user_id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException('Failed to update profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar(File avatarFile, String userId) async {
    try {
      final fileExt = avatarFile.path.split('.').last;
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // upload the avatar in the supabase storage, in bucket (avatars) so to say
      await supabaseClient.storage.from('avatars').upload(fileName, avatarFile);

      // Now get the public url
      final url = supabaseClient.storage.from('avatars').getPublicUrl(fileName);

      // Return the url
      return url;
    } catch (e) {
      throw core_exception.ServerException('Failed to upload the avatar : $e');
    }
  }

  @override
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      // First extract the file path from url
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;
      final publicIndex = pathSegments.indexOf('public');

      if (publicIndex != -1 && publicIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(publicIndex + 1).join('/');
        await supabaseClient.storage.from('avatars').remove([filePath]);
      }
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to delete an avatar image : $e',
      );
    }
  }

  @override
  Future<UserModel> updateAvatarUrl(String userId, String avatarUrl) async {
    try {
      final response = await supabaseClient
          .from('users')
          .update({'image_url': avatarUrl})
          .eq('user_id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException('Failed to update the avatar : $e');
    }
  }
}
