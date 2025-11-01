import 'package:app/app/router/route_constants.dart';
import 'package:app/core/navigations/navigation_wrapper.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/presentation/pages/create_hotel_organization_page.dart';
import 'package:app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/register_page.dart';
import 'package:app/features/home/presentation/pages/another.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/home/presentation/pages/home_second.dart';
import 'package:app/features/search/presentation/pages/search_page.dart';
import 'package:app/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    routes: [
      // Splash route
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Register page
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // Login page
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Forgot password page
      GoRoute(
        path: RouteConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Create hotel/organization page for (role = owner, and selection of hotel/organization for manager and staff)
      GoRoute(
        path: RouteConstants.createHotelOrganization,
        builder: (context, state) {
          final extraData = state.extra as UserModel?;
          return CreateHotelOrganizationPage(user: extraData);
        },
      ),

      // Home route
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => NavigationWrapper(
          currentRoute: state.uri.toString(),
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: RouteConstants.homeSecond,
        builder: (context, state) => NavigationWrapper(
          currentRoute: state.uri.toString(),
          child: const HomePage1(),
        ),
      ),

      GoRoute(
        path: RouteConstants.searchPage,
        builder: (context, state) => NavigationWrapper(
          currentRoute: state.uri.toString(),
          child: const SearchPage(),
        ),
      ),

      // Check
      GoRoute(
        path: RouteConstants.anotherPage,
        builder: (context, state) => const Another(),
      ),
    ],
  );
}
