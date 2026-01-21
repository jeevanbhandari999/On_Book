import 'package:app/core/services/session_manager.dart';
import 'package:app/features/auth/auth_dependencies.dart';
import 'package:app/features/booking/booking_dependencies.dart';
import 'package:app/features/customer_review/customer_review_dependencies.dart';
import 'package:app/features/home/home_dependencies.dart';
import 'package:app/features/library/library_dependencies.dart';
import 'package:app/features/post/post_dependencies.dart';
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

    // Post feature depenencies
    await _registerPostDependencies();

    // Home feature depenencies
    await _registerHomeDependencies();

    // Booking feature dependencies
    await _registerBookingDependencies();

    // Library feature dependencies
    await _registerLibraryDependencies();

    // Customer review dependencies
    await _registerCustomerReviewDependencies();
  }

  // Register auth dependencies
  static Future<void> _registerAuthDependencies() async {
    await AuthDependencies.register(instance);
  }

  // Regisetr post dependencies
  static Future<void> _registerPostDependencies() async {
    await PostDependencies.register(instance);
  }

  // Register home dependencies
  static Future<void> _registerHomeDependencies() async {
    await HomeDependencies.register(instance);
  }

  // Register booking dependencies
  static Future<void> _registerBookingDependencies() async {
    await BookingDependencies.register(instance);
  }

  // Register library dependencies
  static Future<void> _registerLibraryDependencies() async {
    await LibraryDependencies.register(instance);
  }

  // Register Customer review dependencies
  static Future<void> _registerCustomerReviewDependencies() async {
    await CustomerReviewDependencies.register(instance);
  }

  static void reset() {
    instance.reset();
  }

  // Helper methods for getting dependencies
  static T get<T extends Object>() => instance.get<T>();

  static T call<T extends Object>() => instance.call<T>();

  static bool isRegistered<T extends Object>() => instance.isRegistered<T>();
}
