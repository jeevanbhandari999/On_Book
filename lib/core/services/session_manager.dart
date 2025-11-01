import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/core/constants/app_constants.dart';

/// Manages user session data with secure storage persistence
///
/// This singleton class handles user authentication state, user data caching,
/// and token management using FlutterSecureStorage for cross-platform persistence.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  UserModel? user;
  bool? isLoggedIn;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal() {
    isLoggedIn = false;
  }

  /// Convenience method to initialize session data from storage
  ///
  /// This method calls [getUserPreference()] and can be used during app initialization
  /// to restore previously saved session data from secure storage.
  Future<void> initializeFromStorage() async {
    try {
      print('🔄 Initializing session data from storage...');
      await getUserPreference();
      print('✅ Session data initialization completed');
    } catch (e) {
      print('❌ Failed to initialize session data from storage: $e');
      // Reset state on initialization failure
      user = null;
      isLoggedIn = false;
    }
  }

  /// Validates if the cached session data is still valid
  ///
  /// Checks if the cached session has required fields and hasn't expired.
  /// This can be used to determine if cached data should be trusted.
  bool isSessionValid() {
    try {
      if (isLoggedIn != true || user == null) {
        return false;
      }

      // Check for required user fields
      if (user!.id.isEmpty || user!.userId.isEmpty) {
        print('⚠️ Cached session missing required user fields');
        return false;
      }

      // Additional validation logic can be added here
      // e.g., check if token is expired, user data is complete, etc.

      return true;
    } catch (e) {
      print('⚠️ Error validating cached session: $e');
      return false;
    }
  }

  /// Saves user data and authentication state to secure storage
  ///
  /// Persists the provided [user] data to FlutterSecureStorage and sets the
  /// authentication state to logged in. This method should be called after
  /// successful authentication or profile updates.
  ///
  /// Throws an exception if storage operations fail.
  Future<void> saveUserPreference(UserModel user) async {
    try {
      print('💾 Saving user preferences to secure storage...');

      final userData = jsonEncode(user.toJson());
      await _secureStorage.write(
        key: AppConstants.userDataKey,
        value: userData,
      );

      await _secureStorage.write(key: 'isLoggedIn', value: 'true');

      // Update in-memory state
      this.user = user;
      isLoggedIn = true;

      print(
        '✅ User preferences saved successfully for user: ${user.userId} and ${user.fullName}',
      );
    } catch (e) {
      print('❌ Failed to save user preferences: $e');
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  /// Clears all user data and authentication state from secure storage
  ///
  /// Removes all persisted user data, tokens, and authentication state from
  /// FlutterSecureStorage. This method should be called during logout or
  /// when the user session needs to be completely cleared.
  ///
  /// Throws an exception if storage operations fail.
  Future<void> clearUserPreference() async {
    try {
      print('🗑️ Clearing user preferences from secure storage...');

      // Clear in-memory state first
      user = null;
      isLoggedIn = false;

      // Clear all stored data
      await _secureStorage.delete(key: AppConstants.userDataKey);
      await _secureStorage.delete(key: AppConstants.userTokenKey);
      await _secureStorage.delete(key: 'isLoggedIn');

      print('✅ User preferences cleared successfully');
    } catch (e) {
      print('❌ Failed to clear user preferences: $e');
      throw Exception('Failed to clear user data: ${e.toString()}');
    }
  }

  /// Retrieves user data and authentication state from secure storage
  ///
  /// Loads previously saved user data and authentication state from
  /// FlutterSecureStorage and updates the in-memory state. This method
  /// should be called during app initialization to restore session data.
  ///
  /// Note: Errors during retrieval are handled gracefully by resetting
  /// the in-memory state to null/false rather than throwing exceptions.
  Future<void> getUserPreference() async {
    try {
      print('📖 Loading user preferences from secure storage...');

      final userData = await _secureStorage.read(key: AppConstants.userDataKey);
      final isLoggedInData = await _secureStorage.read(key: 'isLoggedIn');

      if (userData != null && userData.isNotEmpty) {
        try {
          final userMap = jsonDecode(userData) as Map<String, dynamic>;
          user = UserModel.fromJson(userMap);
          print(
            '✅ User data loaded successfully for user: ${user?.userId ?? 'unknown'} and ${user?.fullName ?? 'Unknown'}',
          );
        } catch (decodeError) {
          print('⚠️ Failed to decode user data: $decodeError');
          user = null;
        }
      } else {
        print('ℹ️ No user data found in storage');
        user = null;
      }

      isLoggedIn = isLoggedInData == 'true';
      print(
        'ℹ️ Login state: ${isLoggedIn == true ? 'logged in' : 'not logged in'}',
      );
    } catch (e) {
      print('❌ Failed to load user preferences: $e');
      // Reset state on error
      user = null;
      isLoggedIn = false;
    }
  }

  /// Retrieves user data from secure storage without updating in-memory state
  ///
  /// Returns a [UserModel] instance if user data exists in storage,
  /// or null if no data is found or an error occurs.
  ///
  /// This method is useful when you need to check stored user data
  /// without affecting the current session state.
  Future<UserModel?> getUserData() async {
    try {
      final userData = await _secureStorage.read(key: AppConstants.userDataKey);
      if (userData != null && userData.isNotEmpty) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('⚠️ Failed to retrieve user data: $e');
      return null;
    }
  }

  /// Retrieves the stored authentication token from secure storage
  ///
  /// Returns the stored access token as a [String] if available,
  /// or null if no token is found or an error occurs.
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.userTokenKey);
      if (token != null && token.isNotEmpty) {
        return token;
      }
      return null;
    } catch (e) {
      print('⚠️ Failed to retrieve token: $e');
      return null;
    }
  }

  /// Saves an authentication token to secure storage
  ///
  /// Persists the provided [token] to FlutterSecureStorage for later retrieval.
  /// This method should be called after successful authentication.
  ///
  /// Throws an exception if the storage operation fails.
  Future<void> saveToken(String token) async {
    try {
      if (token.isEmpty) {
        throw ArgumentError('Token cannot be empty');
      }

      await _secureStorage.write(key: AppConstants.userTokenKey, value: token);
      print('✅ Authentication token saved successfully');
    } catch (e) {
      print('❌ Failed to save authentication token: $e');
      throw Exception('Failed to save token: ${e.toString()}');
    }
  }

  /// Checks if session data has been loaded from storage
  bool get isSessionDataLoaded => user != null || isLoggedIn != null;

  /// Forces a refresh of session data from storage
  Future<void> refreshSessionData() async {
    await getUserPreference();
  }
}
