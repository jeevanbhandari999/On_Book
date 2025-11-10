class RouteConstants {
  // App routes
  static const String splash = '/splash';
  static const String home = '/home';
  static const String homeSecond = '/homeSecond';

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String createHotelOrganization = '/create-hotel-organization';
  static const String selectHotelOrganization = '/select-hotel-organization';

  // Search routes
  static const String searchPage = '/search';
  static const String anotherPage = '/anotherPage';

  // Post routes
  static const String dummyPostPage =
      '/dummyPostPage'; // this page is for those whose role is not the owner and don't have the authorize to add posts about their hotels, in simple world it's a welcome like page
  static const String postPage = '/postPage';
  static const String createPostPage = '/createPostPage';

  // Library routes
  static const String libraryPage = '/libraryPage';

  // Profile routes
  static const String profilePage = '/profilePage';

  // Chat routes
  static const String chatUserListPage = '/chatUserListPage';
}
