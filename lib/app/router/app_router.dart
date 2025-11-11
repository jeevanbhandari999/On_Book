import 'package:app/app/router/route_constants.dart';
import 'package:app/core/navigations/main_tab_navigation_page.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/presentation/pages/create_hotel_organization_page.dart';
import 'package:app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/register_page.dart';
import 'package:app/features/auth/presentation/pages/select_hotel_organization_page.dart';
import 'package:app/features/chat/presentation/pages/chat_user_list_page.dart';
import 'package:app/features/home/presentation/pages/another.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/library/presentation/pages/library_page.dart';
import 'package:app/features/post/presentation/pages/create_post_page.dart';
import 'package:app/features/post/presentation/pages/post_page.dart';
import 'package:app/features/profile/presentation/pages/profile_page.dart';
import 'package:app/features/search/presentation/pages/search_page.dart';
import 'package:app/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    routes: [
      // Splash route (no navigation)
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashPage(),
      ),

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

      // Create hotel/organization page for (role = owner),
      GoRoute(
        path: RouteConstants.createHotelOrganization,
        builder: (context, state) {
          final extraData = state.extra as UserModel?;
          return CreateHotelOrganizationPage(user: extraData);
        },
      ),

      // Selection of hotel/organization page for (manager and staff/worker)
      GoRoute(
        path: RouteConstants.selectHotelOrganization,
        builder: (context, state) {
          final extraData = state.extra as UserModel?;
          return SelectHotelOrganizationPage(user: extraData);
        },
      ),

      // === MAIN SHELL: Only ONE instance ===
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabNavigationPage(
            currentRoute: state.uri.toString(),
            navigationShell: navigationShell, // Pass the shell
          );
        },
        branches: [
          // === Branch 0: Home ===
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.home,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomePage()),
              ),
            ],
          ),

          // === Branch 1: Search ===
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.searchPage,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SearchPage()),
              ),
            ],
          ),

          // === Branch 2: Post ===
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.postPage,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PostPage()),
              ),
            ],
          ),

          // === Branch 3: library ===
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.libraryPage,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LibraryPage()),
              ),
            ],
          ),

          // === Branch 4: Profile ===
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.profilePage,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),

      // Chat related pages
      GoRoute(
        path: RouteConstants.chatUserListPage,
        builder: (context, state) => const ChatUserListPage(),
      ),

      // Check
      GoRoute(
        path: RouteConstants.anotherPage,
        builder: (context, state) => const Another(),
      ),

      // Post related page
      GoRoute(
        path: RouteConstants.createPostPage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          final userId = extraData?['userId'];
          final organizationId = extraData?['organizationId'];
          return CreatePostPage(userId: userId, organizationId: organizationId);
        },
      ),
    ],
  );
}
