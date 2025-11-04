import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:get_it/get_it.dart';

class PostDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources

    // Services
    getIt.registerLazySingleton<PostServices>(
      () => PostServices(authService: getIt<AuthService>()),
    );
  }
}
