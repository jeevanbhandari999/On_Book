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
      print('$e while uploading');

      throw core_exception.ServerException(
        'Failed to upload the profile picture : $e',
      );
    }
  }

  @override
  Future<void> deleteProfilePicture(String profilePictureUrl) async {
    try {
      // First extract the file path from url
      final uri = Uri.parse(profilePictureUrl);
      final pathSegments = uri.pathSegments;
      final publicIndex = pathSegments.indexOf('public');

      if (publicIndex != -1 && publicIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(publicIndex + 1).join('/');
        await supabaseClient.storage.from('profiles').remove([filePath]);
      }
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to delete an profile image : $e',
      );
    }
  }

  @override
  Future<UserModel> updateProfilePictureUrl(
    String userId,
    String profilePictureUrl,
  ) async {
    try {
      final response = await supabaseClient
          .from('users')
          .update({'image_url': profilePictureUrl})
          .eq('user_id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('$e while updating');

      throw core_exception.ServerException('Failed to update the profile : $e');
    }
  }
}
