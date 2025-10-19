import 'package:app/core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseKey => dotenv.env['SUPABASE_KEY'] ?? '';

  // App Information
  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;

  // Validation
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
  }
}
