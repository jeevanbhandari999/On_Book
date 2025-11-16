import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/core/services/session_manager.dart';
import 'package:app/app/dependency_injection.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Register new user with role and organization support
  Future<UserModel?> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    Map<String, dynamic>? organizationDetails,
    String? organizationId,
  }) async {
    try {
      // 1. Register user with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role.value},
      );

      if (response.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      // 2. Handle organization logic for managers
      if (role == UserRole.manager && organizationDetails != null) {
        // Organization will be created after email confirmation and profile completion
        // For now, just return the user info
      } else if (role == UserRole.worker && organizationId != null) {
        // Worker will be assigned to organization after profile completion
      }

      final now = DateTime.now();

      // 2. INSERT INTO profiles TABLE IMMEDIATELY
      final profileData = {
        'user_id': response.user!.id,
        'full_name': fullName,
        'role': role.value,
        'organization_id': organizationId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final profileResponse = await _supabase
          .from('users')
          .insert(profileData)
          .select()
          .single();

      // 3. Return full UserModel from DB
      return UserModel.fromJson({
        'user_id': response.user!.id,
        ...profileResponse,
      });
    } on AuthException catch (e) {
      print('❌ Registration AuthException: ${e.message}');
      print('❌ Status Code: ${e.statusCode}');

      // Handle specific registration errors
      if (e.message.toLowerCase().contains('user already registered') ||
          e.message.toLowerCase().contains('email already registered') ||
          e.message.toLowerCase().contains('duplicate key value') ||
          e.message.toLowerCase().contains('already exists')) {
        throw Exception(
          'An account with this email already exists. Please log in or use a different email.',
        );
      } else if (e.message.contains('Failed to fetch') ||
          e.message.contains('ClientException')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      print('❌ Registration General Exception: ${e.toString()}');

      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      } else {
        throw Exception('Registration failed: ${e.toString()}');
      }
    }
  }

  // Login with email and password
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Run network diagnostics before attempting login
      // print('🔧 Running network diagnostics...');
      // final diagnostics = await NetworkHelper.runNetworkDiagnostics();
      // print('📊 Network Diagnostics: $diagnostics');

      // // Use smart connectivity check that considers platform limitations
      // final hasReliableConnection = await NetworkHelper.hasReliableConnection();
      // if (!hasReliableConnection) {
      //   throw Exception(
      //       'No internet connection. Please check your network settings.');
      // }

      // if (!diagnostics['canReachSupabase']) {
      //   throw Exception(
      //       'Cannot reach Supabase servers. Please try again later.');
      // }

      print('🔧 Attempting login for: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Login response received');

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      print('✅ User found: ${response.user!.id}');

      if (response.user!.emailConfirmedAt == null) {
        throw Exception('Email not confirmed. Please check your inbox.');
      }

      print('✅ Email confirmed, getting user profile...');

      // Get user profile from database
      final userProfile = await _getUserProfile(response.user!.id);

      if (userProfile == null) {
        print(
          '⚠️ User profile not found, creating basic user model for profile completion',
        );
        // Profile not found - create basic user model for profile completion
        final role = UserRoleExtension.fromString(
          response.user!.userMetadata?['role'] as String? ?? 'user',
        );

        return UserModel(
          id: response.user!.id,
          userId: response.user!.id,
          email: email,
          fullName: response.user!.userMetadata?['full_name'] as String,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      print('✅ User profile retrieved successfully');

      // Persist session data to secure storage
      try {
        final sessionManager = DependencyInjection.get<SessionManager>();
        await sessionManager.saveUserPreference(userProfile);

        // Save access token if available
        final accessToken = _supabase.auth.currentSession?.accessToken;
        if (accessToken != null) {
          await sessionManager.saveToken(accessToken);
        }
        print('✅ Session data persisted successfully');
      } catch (e) {
        print('⚠️ Failed to persist session data: $e');
        // Don't throw exception here as login was successful
      }

      return userProfile;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      print('❌ Status Code: ${e.statusCode}');

      // Handle specific auth errors
      if (e.message.contains('Invalid login credentials')) {
        throw Exception(
          'Invalid email or password. Please check your credentials.',
        );
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('Please confirm your email address before logging in.');
      } else if (e.message.contains('Failed to fetch') ||
          e.message.contains('ClientException')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      print('❌ General Exception: ${e.toString()}');

      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException')) {
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      } else {
        throw Exception('Login failed: ${e.toString()}');
      }
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();

      // Clear persisted session data
      try {
        final sessionManager = DependencyInjection.get<SessionManager>();
        await sessionManager.clearUserPreference();
        print('✅ Session data cleared successfully');
      } catch (e) {
        print('⚠️ Failed to clear session data: $e');
        // Don't throw exception here as logout was successful
      }
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Get user profile from database
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); // Use maybeSingle instead of single to handle missing profile

      if (response == null) {
        // Profile not found - return null instead of throwing exception
        return null;
      }

      return UserModel.fromJson({
        'id': userId,
        'email': currentUser?.email ?? '',
        ...response,
      });
    } catch (e) {
      // Only throw exception for actual errors, not missing profile
      if (e.toString().contains('No rows returned') ||
          e.toString().contains('not found')) {
        return null; // Profile not found
      }
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Complete user profile after email confirmation
  Future<UserModel> completeProfile({
    required String fullName,
    String? phone,
    String? address,
    String? imageUrl,
    String? organizationId,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final now = DateTime.now();
      final role = UserRoleExtension.fromString(
        currentUser!.userMetadata?['role'] as String? ?? 'user',
      );

      final profileData = {
        'user_id': currentUser!.id,
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'image_url': imageUrl,
        'role': role.value,
        'organization_id': organizationId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('users')
          .insert(profileData)
          .select()
          .single();

      final userModel = UserModel.fromJson({
        'user_id': currentUser!.id,
        ...response,
      });

      // Update cached session data with new profile information
      try {
        final sessionManager = DependencyInjection.get<SessionManager>();
        await sessionManager.saveUserPreference(userModel);
        print('✅ Profile completion session data updated');
      } catch (e) {
        print('⚠️ Failed to update session data after profile completion: $e');
        // Don't throw exception here as profile completion was successful
      }

      return userModel;
    } catch (e) {
      throw Exception('Failed to complete profile: ${e.toString()}');
    }
  }

  // Create organization (for managers)
  Future<OrganizationModel> createOrganization({
    required String name,
    String? logoUrl,
    String? address,
    String? phone,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final now = DateTime.now();

      final orgData = {
        'name': name,
        'logo_url': logoUrl,
        'address': address,
        'phone': phone,
        'created_by': currentUser!.id,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('organizations')
          .insert(orgData)
          .select()
          .single();

      // if (response == null) {
      //   throw Exception('Failed to create organization');
      // }

      // // Get the created organization
      // final orgResponse = await _supabase
      //     .from('organizations')
      //     .select()
      //     .eq('id', response)
      //     .single();

      final organization = OrganizationModel.fromJson(response);

      // try to update the users table( insert the organization id to the organizationId column )
      try {} catch (e) {
        print('Failed to update the profile $e');
        throw Exception('Failed to update the organization id');
      }
      updateProfile(organizationId: organization.id);
      // Update cached session data with new organization information
      try {
        final sessionManager = DependencyInjection.get<SessionManager>();
        final currentUser = await getCurrentUserProfile();
        if (currentUser != null) {
          // Update user with organization ID
          final updatedUser = currentUser.copyWith(
            organizationId: organization.id,
          );
          await sessionManager.saveUserPreference(updatedUser);
          print('✅ Organization creation session data updated');
        }
      } catch (e) {
        print(
          '⚠️ Failed to update session data after organization creation: $e',
        );
        // Don't throw exception here as organization creation was successful
      }

      return organization;
    } catch (e) {
      throw Exception('Failed to create organization: ${e.toString()}');
    }
  }

  // Get organization for current user
  Future<OrganizationModel?> getUserOrganization() async {
    try {
      // if (currentUser == null) return null;

      // // Get user profile first
      // final profile = await _getUserProfile(currentUser!.id);
      // if (profile?.organizationId == null) return null;

      if (currentUser == null) {
        return null;
      }
      final profile = await _getUserProfile(currentUser!.id);
      if (profile == null) {
        return null;
      }
      final orgId = profile.organizationId;
      if (orgId == null) {
        return null;
      }

      // Get organization details
      final response = await _supabase
          .from('organizations')
          .select()
          .eq('id', profile.organizationId!)
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user organization: ${e.toString()}');
    }
  }

  // Get current user's organization ID
  Future<String?> getCurrentUserOrganizationId() async {
    try {
      if (currentUser == null) return null;

      // Get user profile first
      final profile = await _getUserProfile(currentUser!.id);
      return profile?.organizationId;
    } catch (e) {
      // Don't throw exception, just return null if there's an error
      return null;
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return currentUser?.id;
  }

  // Get current user EMAIL
  String? getCurrentUserEmail() {
    return currentUser?.email;
  }

  // since supabase announcements table store the tuple id(default id) in created_by instead of the user_id so this method needs
  Future<String?> getCurrentUserTuppleId() async {
    try {
      if (currentUser == null) return null;

      // Get user profile first
      final profile = await _getUserProfile(currentUser!.id);
      return profile?.id;
    } catch (e) {
      // Don't throw exception, just return null if there's an error
      return null;
    }
  }

  // Update user profile
  Future<UserModel?> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    String? imageUrl,
    String? organizationId,
  }) async {
    try {
      if (currentUser == null) return null;

      final updateData = {'updated_at': DateTime.now().toIso8601String()};

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (organizationId != null) {
        updateData['organization_id'] = organizationId;
      }

      final response = await _supabase
          .from('users')
          .update(updateData)
          .eq('user_id', currentUser!.id)
          .select()
          .single();

      return UserModel.fromJson({'id': currentUser!.id, ...response});
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (currentUser == null) return null;
      return await _getUserProfile(currentUser!.id);
    } catch (e) {
      // Don't throw exception for missing profile, just return null
      if (e.toString().contains('No rows returned') ||
          e.toString().contains('not found')) {
        return null;
      }
      throw Exception('Failed to get current user profile: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Check if user needs to complete profile
  Future<bool> needsProfileCompletion() async {
    try {
      if (currentUser == null) return false;

      final response = await _supabase
          .from('users')
          .select('id')
          .eq('user_id', currentUser!.id)
          .maybeSingle();

      return response == null;
    } catch (e) {
      return true; // Assume needs completion if error
    }
  }

  // Fetch the organizations
  Future<List<OrganizationModel>> fetchOrganizations() async {
    final response = await _supabase.from('organizations').select();
    // print('response form the backend : $response');
    return response
        .map((organization) => OrganizationModel.fromJson(organization))
        .toList();
  }
}
