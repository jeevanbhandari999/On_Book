import 'package:app/core/navigations/adaptive_navigation.dart';
import 'package:app/core/navigations/responsive_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    // Don't show the app bar if it shouldn't be shown for this route
    if (!ResponsiveNavigationController.shouldShowAppBar(currentRoute)) {
      return const SizedBox.shrink();
    }
    final title = ResponsiveNavigationController.getPageTitle(currentRoute);
    return AppBar(
      title: Text(title, style: _getTitleTextStyle(context)),
      automaticallyImplyLeading: automaticallyImplyLeading,
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
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => _handleNotificationsPressed(context),
        tooltip: 'Notifications',
        iconSize: _getIconSize(),
        padding: _getIconPadding(),
        constraints: BoxConstraints(
          minWidth: ResponsiveNavigationController.getMinimumTouchTargetSize(),
          minHeight: ResponsiveNavigationController.getMinimumTouchTargetSize(),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.messenger_outline_outlined),
        onPressed: () => _handleChattingPressed(context),
        tooltip: 'Chat',
        iconSize: _getIconSize(),
        padding: _getIconPadding(),
        constraints: BoxConstraints(
          minWidth: ResponsiveNavigationController.getMinimumTouchTargetSize(),
          minHeight: ResponsiveNavigationController.getMinimumTouchTargetSize(),
        ),
      ),
    ];
  }

  /// Handles notifications button press
  void _handleNotificationsPressed(BuildContext context) {
    // Check if notifications are implemented
    final notificationsItem = NavigationConfiguration.getItemByRoute(
      '/notifications',
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
    final notificationsItem = NavigationConfiguration.getItemByRoute('/chat');
    if (notificationsItem?.isImplemented == true) {
      // Navigate to chat
      // This would be handled by the navigation system
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Navigating to chat...')));
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
        fontSize = 20;
        fontWeight = FontWeight.w600;
        break;
      case NavigationType.tabletSideNav:
        fontSize = 22;
        fontWeight = FontWeight.w600;
        break;
      case NavigationType.desktopSideNav:
        fontSize = 24;
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
    if (centerTitle) return true;

    // Center title on mobile, left-align on tablet/desktop
    return navigationType == NavigationType.mobileBottomNav;
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
        return 24.0;
      case NavigationType.tabletSideNav:
        return 26.0;
      case NavigationType.desktopSideNav:
        return 28.0;
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
