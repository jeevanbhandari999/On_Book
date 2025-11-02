import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  // User login
  Future<UserModel> login({required String email, required String password});

  // User register
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  // Logout
  Future<void> logout();

  // Get the detail of the current user
  Future<UserModel> getCurrentUser();

  // Forgot password
  Future<void> forgotPassword({required String email});

  // Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  // Update the user profile
  // Future<UserModel> updateProfile({required String userId, String? fullName, String? imageUrl});

  // Change the passowrd
  Future<void> changePassword({required String newPassword});

  // Delete the user account
  Future<void> deleteAccount();

  // Fetch the organization list
  Future<List<OrganizationModel>> fetchOrganizations();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw const ServerException('Login failed');

      // Get profile from 'users' table
      final profile = await _getUserProfile(user.id);
      return profile;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );

      final user = response.user;
      if (user == null) throw const ServerException('Registration failed');

      // Create profile in public.users
      final profileResponse = await client
          .from('users')
          .insert({
            'user_id': user.id,
            'full_name': fullName,
            'role': role,
            // others remain NULL (image_url, phone, etc.)
            // can be edit later
          })
          .select()
          .single();

      return UserModel.fromJson(profileResponse);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw const ServerException('No user logged in');

      return await _getUserProfile(user.id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      // Verify the password-reset token (OTP)
      await client.auth.verifyOTP(token: token, type: OtpType.recovery);

      // Update the password
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw ServerException('Failed to reset password: ${e.toString()}');
    }
  }

  // @override
  // Future<UserModel> updateProfile({
  //   required String userId,
  //   String? fullName,
  //   String? imageUrl,
  // }) async {
  //   try {
  //     final updates = <String, dynamic>{};
  //     if (fullName != null) updates['full_name'] = fullName;
  //     if (imageUrl != null) updates['image_url'] = imageUrl;

  //     await client
  //         .from('users')
  //         .update(updates)
  //         .eq('user_id', userId);

  //     return await _getUserProfile(userId);
  //   } catch (e) {
  //     throw ServerException(e.toString());
  //   }
  // }

  @override
  Future<void> changePassword({required String newPassword}) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw const ServerException('No user');

      // Delete profile + auth user
      await client.from('users').delete().eq('user_id', userId);
      await client.auth.admin.deleteUser(
        userId,
      ); // Needs service role (or use Edge Function)
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Helper: Get full user profile from 'users' table
  Future<UserModel> _getUserProfile(String userId) async {
    final response = await client
        .from('users')
        .select()
        .eq('user_id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  @override
  Future<List<OrganizationModel>> fetchOrganizations() async {
    final response = await client.from('organizations').select();
    return response
        .map((organization) => OrganizationModel.fromJson(organization))
        .toList();
  }
}
