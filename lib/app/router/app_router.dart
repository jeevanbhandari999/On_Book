import 'package:app/app/router/route_constants.dart';
import 'package:app/core/navigations/main_tab_navigation_page.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/presentation/pages/create_hotel_organization_page.dart';
import 'package:app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/register_page.dart';
import 'package:app/features/auth/presentation/pages/select_hotel_organization_page.dart';
import 'package:app/features/booking/presentation/pages/booking_deails_page.dart';
import 'package:app/features/booking/presentation/pages/booking_page.dart';
import 'package:app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:app/features/chat/presentation/pages/chat_page.dart';
import 'package:app/features/chat/presentation/pages/contacts_page.dart';
import 'package:app/features/chat/presentation/pages/initial_chat_placeholder_page.dart';
import 'package:app/features/customer_review/presentation/pages/customer_review_page.dart';
import 'package:app/features/customer_review/presentation/pages/write_a_review_page.dart';
import 'package:app/features/home/presentation/pages/another.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/library/presentation/pages/library_page.dart';
import 'package:app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:app/features/organizations/presentation/pages/organization_details_page_owner_side.dart';
import 'package:app/features/organizations/presentation/pages/organization_details_page_user_side.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/presentation/pages/create_post_page.dart';
import 'package:app/features/post/presentation/pages/edit_post_page.dart';
import 'package:app/features/post/presentation/pages/post_details_page.dart';
import 'package:app/features/post/presentation/pages/post_page.dart';
import 'package:app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:app/features/profile/presentation/pages/profile_page.dart';
import 'package:app/features/profile/presentation/pages/view_user_profile_page.dart';
import 'package:app/features/search/presentation/pages/search_page.dart';
import 'package:app/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    routes: [
      /// Splash
      GoRoute(
        path: RouteConstants.splash,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashPage(),
      ),

      /// Register
      GoRoute(
        path: RouteConstants.register,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterPage(),
      ),

      /// Login
      GoRoute(
        path: RouteConstants.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),

      /// Forgot Password
      GoRoute(
        path: RouteConstants.forgotPassword,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      /// Create Organization
      GoRoute(
        path: RouteConstants.createHotelOrganization,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final user = state.extra as UserModel?;
          return CreateHotelOrganizationPage(user: user);
        },
      ),

      /// Select Organization
      GoRoute(
        path: RouteConstants.selectHotelOrganization,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final user = state.extra as UserModel?;
          return SelectHotelOrganizationPage(user: user);
        },
      ),

      /// MAIN SHELL
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabNavigationPage(
            currentRoute: state.uri.toString(),
            navigationShell: navigationShell,
          );
        },
        branches: [
          /// HOME
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: RouteConstants.home,
                pageBuilder: (context, state) {
                  final user = state.extra as UserModel?;
                  return NoTransitionPage(
                    child: HomePage(userId: user?.userId ?? ''),
                  );
                },
              ),
            ],
          ),

          /// SEARCH
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.searchPage,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SearchPage()),
              ),
            ],
          ),

          /// POST
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.postPage,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PostPage()),
              ),
            ],
          ),

          /// LIBRARY
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.libraryPage,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LibraryPage()),
              ),
            ],
          ),

          /// PROFILE
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

      /// Chat User List
      GoRoute(
        path: RouteConstants.chatUserListPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final userId = state.extra as String;
          return RoomPage(currentUserId: userId);
        },
      ),

      /// Initial Chat Placeholder
      GoRoute(
        path: RouteConstants.initialChatPlaceholderPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return InitialChatPlaceholderPage(
            organizationId: extra['organizationId'],
            userId: extra['userId'],
            targetUserId: extra['targetUserId'],
          );
        },
      ),

      /// Contacts
      GoRoute(
        path: RouteConstants.contacts,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ContactsPage(
            organizationId: extra['orgId'],
            currentUserId: extra['userId'],
          );
        },
      ),

      /// Chat Page
      GoRoute(
        path: RouteConstants.chatPage,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return NoTransitionPage(
            child: ChatPage(room: args['room'], currentUserId: args['userId']),
          );
        },
      ),

      /// Another test page
      GoRoute(
        path: RouteConstants.anotherPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Another(),
      ),

      /// Create Post
      GoRoute(
        path: RouteConstants.createPostPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CreatePostPage(
            userId: extra?['userId'],
            organizationId: extra?['organizationId'],
          );
        },
      ),

      /// Post Details
      GoRoute(
        path: RouteConstants.postDetailsPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PostDetailsPage(
            postId: extra['postId'],
            post: extra['post'],
            userId: extra['userId'],
          );
        },
      ),

      /// Edit Post
      GoRoute(
        path: RouteConstants.editPostPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return EditPostPage(
            postId: extra['postId'],
            post: extra['post'],
            userId: extra['userId'],
          );
        },
      ),

      /// Booking Form
      GoRoute(
        path: RouteConstants.bookingFormPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingFormScreen(
            postId: extra['postId'],
            userId: extra['userId'],
            post: extra['post'],
            existingBooking: extra['editBooking'],
          );
        },
      ),

      /// Booking Details
      GoRoute(
        path: RouteConstants.bookingDetailsPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingDetailsPage(
            bookingId: extra['bookingId'],
            userId: extra['userId'],
          );
        },
      ),

      /// Customer Review
      GoRoute(
        path: RouteConstants.customerReviewPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final post = extra['post'] as Post;
          return CustomerReviewPage(
            postId: post.id,
            post: post,
            userId: extra['userId'],
          );
        },
      ),

      /// Write Review
      GoRoute(
        path: RouteConstants.writeAReviewPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WriteAReviewPage(post: extra['post'], userId: extra['userId']);
        },
      ),

      /// Organization user side
      GoRoute(
        path: RouteConstants.organizationDetailsPageUserSide,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return OrganizationDetailsPageUserSide(
            organizationId: extra['organizationId']!,
            userId: extra['userId']!,
          );
        },
      ),

      /// Organization owner side
      GoRoute(
        path: RouteConstants.organizationDetailsPageOwnerSide,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OrganizationDetailsPageOwnerSide(),
      ),

      /// Edit profile
      GoRoute(
        path: RouteConstants.editProfilePage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return EditProfilePage(profile: extra['user'] as User);
        },
      ),

      /// View user profile
      GoRoute(
        path: RouteConstants.viewUserProfilePage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return ViewUserProfilePage(
            userId: extra['userId']!,
            currentUserId: extra['currentUserId']!,
          );
        },
      ),

      /// Notifications Page
      GoRoute(
        path: RouteConstants.notificationsPage,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final userId = state.extra as String;
          return NotificationPage(userId: userId);
        },
      ),
    ],
  );
}
