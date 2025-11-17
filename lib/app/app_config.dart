import 'package:app/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseKey => dotenv.env['SUPABASE_KEY'] ?? '';

  // Cloudinary Configuration
  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  // Map Tiler (Map Configuration)
  static String get mapTilerKey => dotenv.env['MAP_TILER_KEY'] ?? '';

  // App Information
  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;

  // Environment configuration
  static bool get isDebug => kDebugMode;
  static bool get isProduction => kReleaseMode;
  static bool get isProfile => kProfileMode;

  // Validation
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
  }

  // Get environment name
  static String get environmentName {
    if (isDebug) return 'Development';
    if (isProfile) return 'Profile';
    if (isProduction) return 'Production';
    return 'Unknown';
  }

  // Get app info string
  static String get appInfo => '$appName v$appVersion ($environmentName)';

  // Initialize configuration
  static Future<void> initialize() async {
    // Load environment variables
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
      }
    }

    // Validate configuration
    if (!isConfigured && kDebugMode) {
      print('Warning: App configuration is incomplete');
      print(
        'Missing: ${supabaseUrl.isEmpty ? 'SUPABASE_URL ' : ''}${supabaseKey.isEmpty ? 'SUPABASE_KEY' : ''}',
      );
    }

    if (kDebugMode) {
      print('App initialized: $appInfo');
      print('Configuration valid: $isConfigured');
    }
  }
}
