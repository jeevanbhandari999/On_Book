import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/services/auth_service.dart';

// Service to handle organization ID retrieval for events
class PostServices {
  final AuthService _authService;

  PostServices({required AuthService authService}) : _authService = authService;

  // Get the current user's organization ID
  // Returns null if user is not authenticated or doesn't have an organization
  Future<String?> getCurrentUserOrganizationId() async {
    return await _authService.getCurrentUserOrganizationId();
  }

  // Get the current user's organization ID or throw an exception
  // Use this when organization ID is required for the operation
  Future<String> getRequiredOrganizationId() async {
    final organizationId = await getCurrentUserOrganizationId();
    if (organizationId == null || organizationId.isEmpty) {
      throw Exception(
        'Organization ID is required. Please ensure you are logged in and have an organization assigned.',
      );
    }
    return organizationId;
  }

  // Check if the current user has an organization ID
  Future<bool> hasOrganizationId() async {
    final organizationId = await getCurrentUserOrganizationId();
    return organizationId != null && organizationId.isNotEmpty;
  }

  // Get organization ID with fallback
  // Returns the provided fallback if user doesn't have an organization ID
  Future<String> getOrganizationIdWithFallback(String fallback) async {
    final organizationId = await getCurrentUserOrganizationId();
    return organizationId ?? fallback;
  }

  // Get the current user ID
  String? getCurrentUserId() {
    return _authService.getCurrentUserId();
  }

  Future<String?> getCurrentUserTupleId() async {
    final currentUserTupleId = await _authService.getCurrentUserTuppleId();
    return currentUserTupleId;
  }

  // Get the current user ID or throw an exception
  // Use this when user ID is required for the operation
  String getRequiredUserId() {
    final userId = getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is required. Please ensure you are logged in.');
    }
    return userId;
  }

  Future<String> getRequiredUserTupleId() async {
    final userTupleId = await getCurrentUserTupleId();
    if (userTupleId == null || userTupleId.isEmpty) {
      throw Exception('User ID is required. Please ensure you are logged in.');
    }
    return userTupleId;
  }

  // Get the curent user role
  Future<UserRole> getCurrentUserRole() async {
    final currentUserData = await _authService.getCurrentUserProfile();
    if (currentUserData == null) {
      throw Exception(
        'Unable to get the user profile, Please ensure you are logged in.',
      );
    }
    return currentUserData.role;
  }

  // Get the organization details of the user
  Future<OrganizationModel?> getCurrentUserOrganization() async {
    final currentOrganizationData = await _authService.getUserOrganization();
    if (currentOrganizationData == null) {
      throw Exception(
        'Unable to get the user organization, Please ensure you are logged in - and create or joined to an organization',
      );
    }
    return currentOrganizationData;
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final userProfile = await _authService.getCurrentUserProfile();
      if (userProfile == null) {
        throw Exception(
          'Unable to get the user profile, Please ensure you are logged in.',
        );
      }
      return userProfile;
    } catch (e) {
      // Don't throw exception for missing profile, just return null
      if (e.toString().contains('No rows returned') ||
          e.toString().contains('not found')) {
        return null;
      }
      throw Exception('Failed to get current user profile: ${e.toString()}');
    }
  }
}
