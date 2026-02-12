import 'package:app/app/router/route_constants.dart';
import 'package:app/core/navigations/main_tab_navigation_page.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/presentation/pages/create_hotel_organization_page.dart';
import 'package:app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/register_page.dart';
import 'package:app/features/auth/presentation/pages/select_hotel_organization_page.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/presentation/pages/booking_deails_page.dart';
import 'package:app/features/booking/presentation/pages/booking_page.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:app/features/chat/presentation/pages/chat_page.dart';
import 'package:app/features/chat/presentation/pages/chat_user_list_page.dart';
import 'package:app/features/chat/presentation/pages/contacts_page.dart';
import 'package:app/features/customer_review/presentation/pages/customer_review_page.dart';
import 'package:app/features/customer_review/presentation/pages/write_a_review_page.dart';
import 'package:app/features/home/presentation/pages/another.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/library/presentation/pages/library_page.dart';
import 'package:app/features/organizations/presentation/pages/organization_details_page_owner_side.dart';
import 'package:app/features/organizations/presentation/pages/organization_details_page_user_side.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/presentation/pages/create_post_page.dart';
import 'package:app/features/post/presentation/pages/edit_post_page.dart';
import 'package:app/features/post/presentation/pages/post_details_page.dart';
import 'package:app/features/post/presentation/pages/post_page.dart';
import 'package:app/features/profile/presentation/pages/edit_profile_page.dart';
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
                pageBuilder: (context, state) {
                  final extraData = state.extra as UserModel?;
                  final userId = extraData?.userId;
                  return NoTransitionPage(
                    child: HomePage(userId: userId ?? ''),
                  );
                },
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
        builder: (context, state) {
          final userId = state.extra as String;
          return RoomPage(currentUserId: userId);
        },
      ),

      GoRoute(
        path: RouteConstants.contacts,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final organizationId = extra['orgId'] as String;
          final userId = extra['userId'] as String;

          return ContactsPage(
            organizationId: organizationId,
            currentUserId: userId,
          );
        },
      ),

      GoRoute(
        path: RouteConstants.chatPage,
        builder: (context, state) {
          // We expect the 'extra' object to be a Map containing the room and userId
          // OR simply the Room object if you get userId from a global AuthProvider.

          // Approach A: Passing a Map via context.push(..., extra: {'room': room, 'uid': userId})
          final args = state.extra as Map<String, dynamic>;
          final room = args['room'] as Room;
          final userId = args['userId'] as String;

          return ChatPage(room: room, currentUserId: userId);
        },
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

      GoRoute(
        path: RouteConstants.postDetailsPage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          // print(extraData);
          final postId = extraData['postId'] as String;
          final post = extraData['post'];
          final userId = extraData['userId'];
          return PostDetailsPage(postId: postId, post: post, userId: userId);
        },
      ),

      GoRoute(
        path: RouteConstants.editPostPage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          // print(extraData);
          final postId = extraData['postId'];
          final post = extraData['post'];
          final userId = extraData['userId'];
          return EditPostPage(postId: postId, post: post, userId: userId);
        },
      ),

      // Booking routs
      GoRoute(
        path: RouteConstants.bookingFormPage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          // print(extraData);
          final postId = extraData['postId'];
          final userId = extraData['userId'];
          final post = extraData['post'] as Post?;
          final editBooking = extraData['editBooking'] as Booking?;
          return BookingFormScreen(
            postId: postId,
            userId: userId,
            post: post,
            existingBooking: editBooking,
          );
        },
      ),

      GoRoute(
        path: RouteConstants.bookingDetailsPage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          print('The extra data is $extraData');
          final bookingId = extraData['bookingId'] as String;
          final userId = extraData['userId'] as String;
          return BookingDetailsPage(bookingId: bookingId, userId: userId);
        },
      ),

      // GoRoute(
      //   path: RouteConstants.dummyPostPage,
      //   pageBuilder: (context, state) =>
      //       const NoTransitionPage(child: DummyPostPage()),
      // ),

      // GoRoute(
      //   path: RouteConstants.dummyPostPage,
      //   builder: (context, state) {
      //     final extraData = state.extra as Map<String, dynamic>?;
      //     final userId = extraData?['userId'];
      //     final organizationId = extraData?['organizationId'];
      //     return const DummyPostPage();
      //   },
      // ),

      //// Customer review related routes
      // Customer review
      GoRoute(
        path: RouteConstants.customerReviewPage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final post = extraData['post'] as Post;
          final postId = post.id;
          final userId = extraData['userId'] as String;
          return CustomerReviewPage(postId: postId, userId: userId);
        },
      ),

      // Write a review
      GoRoute(
        path: RouteConstants.writeAReviewPage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final post = extraData['post'] as Post;
          final userId = extraData['userId'] as String;
          return WriteAReviewPage(post: post, userId: userId);
        },
      ),

      // Organization related routes
      GoRoute(
        path: RouteConstants.organizationDetailsPageUserSide,
        builder: (context, state) {
          final extraData = state.extra as Map<String, String>;
          final userId = extraData['userId'] as String;
          final organizationId = extraData['organizationId'] as String;
          return OrganizationDetailsPageUserSide(
            organizationId: organizationId,
            userId: userId,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.organizationDetailsPageOwnerSide,
        builder: (context, state) => const OrganizationDetailsPageOwnerSide(),
      ),

      // Profile related page
      GoRoute(
        path: RouteConstants.editProfilePage,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final user = extraData['user'] as User;
          return EditProfilePage(profile: user);
        },
      ),
    ],
  );
}
