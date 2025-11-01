import 'package:app/core/services/session_manager.dart';
import 'package:app/features/auth/auth_dependencies.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DependencyInjection {
  static GetIt get instance => GetIt.instance;

  static Future<void> init() async {
    // Core Services
    _registerCoreServices();

    // Feature services
    await _registerFeatureServices();
  }

  // all core services
  static void _registerCoreServices() {
    // Supabase client
    instance.registerLazySingleton<SupabaseClient>(
      () => Supabase.instance.client,
    );

    // Session Manager
    instance.registerLazySingleton<SessionManager>(() => SessionManager());
    // Initialize session data from storage
    // This ensures the SessionManager's in-memory state is populated with persisted user data
    try {
      final sessionManager = instance<SessionManager>();
      // Initialize session data asynchronously
      sessionManager
          .getUserPreference()
          .then((_) {
            print('✅ Session data initialized successfully');
          })
          .catchError((e) {
            print('⚠️ Failed to initialize session data: $e');
          });
    } catch (e) {
      // Log error but don't crash app initialization
      print('⚠️ Failed to initialize session data: $e');
    }

    // add others core services here as needed
  }

  static Future<void> _registerFeatureServices() async {
    // Auth feature dependencies
    await _registerAuthDependencies();
  }

  // Register auth dependencies
  static Future<void> _registerAuthDependencies() async {
    await AuthDependencies.register(instance);
  }

  static void reset() {
    instance.reset();
  }

  // Helper methods for getting dependencies
  static T get<T extends Object>() => instance.get<T>();

  static T call<T extends Object>() => instance.call<T>();

  static bool isRegistered<T extends Object>() => instance.isRegistered<T>();
}
