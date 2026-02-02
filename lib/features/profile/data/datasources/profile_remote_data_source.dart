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
  Future<String> uploadProfilePicture(File profilePictureFile, String userId);

  // Delete the image from the bucket
  Future<void> deleteProfilePicture(String profilePictureUrl);

  // Update the profile image of the user
  Future<UserModel> updateProfilePictureUrl(
    String userId,
    String profilePictureUrl,
    String? existingImageUrlToDelete,
  );
  // Update the profile image of the user
  Future<UserModel> deleteProfilePictureUrl(
    String userId,
    String profilePictureUrlToDelete,
  );
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
  Future<String> uploadProfilePicture(
    File profilePictureFile,
    String userId,
  ) async {
    try {
      final fileExt = profilePictureFile.path.split('.').last;
      final fileName =
          '$userId/${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // upload the profile in the supabase storage, in bucket (profiles) so to say
      await supabaseClient.storage
          .from('profiles')
          .upload(fileName, profilePictureFile);

      // Now get the public url
      final url = supabaseClient.storage
          .from('profiles')
          .getPublicUrl(fileName);

      // Return the url
      return url;
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to upload the profile picture : $e',
      );
    }
  }

  @override
  Future<void> deleteProfilePicture(String profilePictureUrl) async {
    try {
      if (profilePictureUrl.isEmpty) return;

      final uri = Uri.parse(profilePictureUrl);
      final pathSegments = uri.pathSegments;

      // Find where the bucket name starts
      final bucketIndex = pathSegments.indexOf('profiles');

      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        // Invalid URL or not our bucket — silently skip or throw
        return;
      }

      // Take everything AFTER the bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Optional: add debug print so you can see what you're deleting
      // print('Attempting to delete storage path: $filePath');

      await supabaseClient.storage.from('profiles').remove([filePath]);
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to delete profile picture from storage: $e',
      );
    }
  }

  @override
  Future<UserModel> updateProfilePictureUrl(
    String userId,
    String profilePictureUrl,
    String? existingImageUrlToDelete,
  ) async {
    try {
      if (existingImageUrlToDelete != null &&
          existingImageUrlToDelete.trim().isNotEmpty) {
        // First delete from the bucket
        await deleteProfilePicture(existingImageUrlToDelete);
      }
      final response = await supabaseClient
          .from('users')
          .update({'image_url': profilePictureUrl})
          .eq('user_id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException('Failed to update the profile : $e');
    }
  }

  @override
  Future<UserModel> deleteProfilePictureUrl(
    String userId,
    String profilePictureUrlToDelete,
  ) async {
    try {
      // First delete from the bucket
      await deleteProfilePicture(profilePictureUrlToDelete);
      final response = await supabaseClient
          .from('users')
          .update({'image_url': null})
          .eq('user_id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException('Failed to update the profile : $e');
    }
  }
}
