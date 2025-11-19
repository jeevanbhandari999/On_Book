import 'package:app/app/router/route_constants.dart';
import 'package:app/core/navigations/adaptive_navigation.dart';
import 'package:app/core/navigations/responsive_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final NavigationType navigationType;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final TextStyle? titleTextStyle;
  final bool showBackArrow;
  final VoidCallback? onBackPressed;

  const AdaptiveAppBar({
    super.key,
    required this.currentRoute,
    required this.navigationType,
    this.onMenuPressed,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.titleTextStyle,
    this.showBackArrow = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show the app bar if it shouldn't be shown for this route
    if (!ResponsiveNavigationController.shouldShowAppBar(currentRoute)) {
      return const SizedBox.shrink();
    }
    // final title = ResponsiveNavigationController.getPageTitle(currentRoute);
    final mainTitle = 'Onbook';
    return AppBar(
      title: Row(
        children: [
          // Logo icon of the application
          ClipRect(
            clipBehavior: Clip.hardEdge,
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(100),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'OB',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(mainTitle, style: _getTitleTextStyle(context)),
          ),
        ],
      ),
      // automaticallyImplyLeading: automaticallyImplyLeading,
      automaticallyImplyLeading: showBackArrow,
      leading:
          showBackArrow
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null,
      actions: _buildActions(context),
      backgroundColor: backgroundColor ?? _getBackgroundColor(context),
      foregroundColor: foregroundColor ?? _getForegroundColor(context),
      elevation: elevation ?? _getElevation(),
      centerTitle: _shouldCenterTitle(),
      toolbarHeight: ResponsiveNavigationController.getAppBarHeight(
        navigationType,
      ),
      titleSpacing: _getTitleSpacing(),
      leadingWidth: _getLeadingWidth(),
      actionsPadding: _getActionsPadding(),
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: _getSystemOverlayStyle(context),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    ResponsiveNavigationController.getAppBarHeight(navigationType),
  );

  // Build the actions list with default and custom actions
  _buildActions(BuildContext context) {
    final defaultActions = _getDefaultActions(context);
    final customActions = actions ?? [];

    return [
      ...defaultActions,
      ...customActions,
      SizedBox(width: _getActionsEndPadding()),
    ];
  }

  /// Gets the default actions for the app bar
  List<Widget> _getDefaultActions(BuildContext context) {
    return [
      Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _handleNotificationsPressed(context),
            tooltip: 'Notifications',
            iconSize: _getIconSize(),
            padding: _getIconPadding(),
            constraints: BoxConstraints(
              minWidth:
                  ResponsiveNavigationController.getMinimumTouchTargetSize(),
              minHeight:
                  ResponsiveNavigationController.getMinimumTouchTargetSize(),
            ),
          ),

          // Red dot Notification badge
          Positioned(
            right: 2,
            top: 2,
            child: Builder(
              builder: (context) {
                // Will be replace later with actual count
                const int count = 120;
                final String displayCount =
                    count > 99 ? '99+' : count.toString();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      displayCount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.messenger_outline_outlined),
            onPressed: () => _handleChattingPressed(context),
            tooltip: 'Chat',
            iconSize: _getIconSize(),
            padding: _getIconPadding(),
            constraints: BoxConstraints(
              minWidth:
                  ResponsiveNavigationController.getMinimumTouchTargetSize(),
              minHeight:
                  ResponsiveNavigationController.getMinimumTouchTargetSize(),
            ),
          ),

          // Red dot new chats
          Positioned(
            right: 2,
            top: 2,
            child: Builder(
              builder: (context) {
                const int count = 7;
                final String displayCount =
                    count > 99 ? '99+' : count.toString();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      displayCount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ];
  }

  /// Handles notifications button press
  void _handleNotificationsPressed(BuildContext context) {
    // Check if notifications are implemented
    final notificationsItem = NavigationConfiguration.getItemByRoute(
      '/notificationsPage',
    );
    if (notificationsItem?.isImplemented == true) {
      // Navigate to notifications
      // This would be handled by the navigation system
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigating to notifications...')),
      );
    } else {
      // Show coming soon message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications coming soon!')),
      );
    }
  }

  /// Handles chatting button press
  void _handleChattingPressed(BuildContext context) {
    // Check if notifications are implemented
    final chatItem = NavigationConfiguration.getItemByRoute(
      '/chatUserListPage',
    );
    if (chatItem?.isImplemented == true) {
      // Navigate to chat
      // This would be handled by the navigation system
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Navigating to chat...')));
      context.push(RouteConstants.chatUserListPage);
    } else {
      // Show coming soon message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('chat coming soon!')));
    }
  }

  /// Gets the title text style based on navigation type
  TextStyle? _getTitleTextStyle(BuildContext context) {
    if (titleTextStyle != null) return titleTextStyle;

    final theme = Theme.of(context);
    final baseStyle =
        theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;

    double fontSize;
    FontWeight fontWeight;

    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        fontSize = 26;
        fontWeight = FontWeight.w600;
        break;
      case NavigationType.tabletSideNav:
        fontSize = 28;
        fontWeight = FontWeight.w600;
        break;
      case NavigationType.desktopSideNav:
        fontSize = 30;
        fontWeight = FontWeight.w600;
        break;
    }

    return baseStyle?.copyWith(fontSize: fontSize, fontWeight: fontWeight) ??
        TextStyle(fontSize: fontSize, fontWeight: fontWeight);
  }

  /// Gets the background color based on navigation type
  Color? _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor;

    final theme = Theme.of(context);
    return theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
  }

  /// Gets the foreground color based on navigation type
  Color? _getForegroundColor(BuildContext context) {
    if (foregroundColor != null) return foregroundColor;

    final theme = Theme.of(context);
    return theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
  }

  /// Gets the elevation based on navigation type
  double _getElevation() {
    if (elevation != null) return elevation!;

    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 4.0;
      case NavigationType.tabletSideNav:
        return 2.0;
      case NavigationType.desktopSideNav:
        return 1.0;
    }
  }

  /// Determines if the title should be centered
  bool _shouldCenterTitle() {
    // if user manually give the center title then true
    if (centerTitle) return true;
    // Else always align left
    return false;
    // Center title on mobile, left-align on tablet/desktop
    // return navigationType == NavigationType.mobileBottomNav;
  }

  /// Gets the title spacing based on navigation type
  double _getTitleSpacing() {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 16.0;
      case NavigationType.tabletSideNav:
        return 20.0;
      case NavigationType.desktopSideNav:
        return 24.0;
    }
  }

  /// Gets the leading width based on navigation type
  double _getLeadingWidth() {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 56.0;
      case NavigationType.tabletSideNav:
        return 0; // No leading on tablet
      case NavigationType.desktopSideNav:
        return 0; // No leading on desktop
    }
  }

  /// Gets the icon size for app bar icons
  double _getIconSize() {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 26.0;
      case NavigationType.tabletSideNav:
        return 28.0;
      case NavigationType.desktopSideNav:
        return 30.0;
    }
  }

  /// Gets the icon padding for app bar icons
  EdgeInsets _getIconPadding() {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return const EdgeInsets.all(8.0);
      case NavigationType.tabletSideNav:
        return const EdgeInsets.all(10.0);
      case NavigationType.desktopSideNav:
        return const EdgeInsets.all(12.0);
    }
  }

  /// Gets the actions padding
  EdgeInsets _getActionsPadding() {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return const EdgeInsets.only(right: 8.0);
      case NavigationType.tabletSideNav:
        return const EdgeInsets.only(right: 12.0);
      case NavigationType.desktopSideNav:
        return const EdgeInsets.only(right: 16.0);
    }
  }

  /// Gets the end padding for actions
  double _getActionsEndPadding() {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 8.0;
      case NavigationType.tabletSideNav:
        return 12.0;
      case NavigationType.desktopSideNav:
        return 16.0;
    }
  }

  /// Gets the system overlay style for the app bar
  SystemUiOverlayStyle? _getSystemOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }
}

// Extension to provide additional context-aware app bar utilities
extension AdaptiveAppBarExtension on AdaptiveAppBar {
  // Create an app bar for mobile navigation
  static AdaptiveAppBar mobile({
    required String currentRoute,
    List<Widget>? actions,
  }) {
    return AdaptiveAppBar(
      currentRoute: currentRoute,
      navigationType: NavigationType.mobileBottomNav,
      actions: actions,
    );
  }

  // Create an app bar for tablet navigation
  static AdaptiveAppBar tablet({
    required String currentRoute,
    List<Widget>? actions,
  }) {
    return AdaptiveAppBar(
      currentRoute: currentRoute,
      navigationType: NavigationType.mobileBottomNav,
      actions: actions,
    );
  }

  // Create an app bar for desktop navigation
  static AdaptiveAppBar desktop({
    required String currentRoute,
    List<Widget>? actions,
  }) {
    return AdaptiveAppBar(
      currentRoute: currentRoute,
      navigationType: NavigationType.mobileBottomNav,
      actions: actions,
    );
  }
}

// Helper class for app bar context information
class AppBarContext {
  final String route;
  final NavigationType navigationType;
  final bool shouldShow;
  final String title;

  const AppBarContext({
    required this.route,
    required this.navigationType,
    required this.shouldShow,
    required this.title,
  });

  /// Creates app bar context from current route and screen width
  factory AppBarContext.fromRoute(String route, double screenWidth) {
    final navigationType = ResponsiveNavigationController.getNavigationType(
      screenWidth,
    );

    return AppBarContext(
      route: route,
      navigationType: navigationType,
      shouldShow: ResponsiveNavigationController.shouldShowAppBar(route),
      title: ResponsiveNavigationController.getPageTitle(route),
    );
  }

  /// Creates an adaptive app bar from this context
  AdaptiveAppBar createAppBar({List<Widget>? actions}) {
    return AdaptiveAppBar(
      currentRoute: route,
      navigationType: navigationType,
      actions: actions,
    );
  }
}
