import 'package:app/core/navigations/adaptive_navigation.dart';
import 'package:app/core/responsive/screen_break_points.dart';
import 'package:flutter/material.dart';

// Enum to defining the different navigation layout type
enum NavigationType { mobileBottomNav, tabletSideNav, desktopSideNav }

// Controller class that centralizes responsive navigation logic and provides device specific navigation behavior

class ResponsiveNavigationController {
  // Determines the appropriate navigation type based on screen width
  static NavigationType getNavigationType(double screenWidth) {
    final deviceType = ScreenBreakPoints.getDeviceType(screenWidth);

    switch (deviceType) {
      case DeviceType.mobile:
        return NavigationType.mobileBottomNav;
      case DeviceType.tablet:
        return NavigationType.tabletSideNav;
      case DeviceType.desktop:
        return NavigationType.desktopSideNav;
      case DeviceType.largeDesktop:
        return NavigationType.desktopSideNav;
    }
  }

  // Determines if the app bar should be shown for the given route
  static bool shouldShowAppBar(String currentRoute) {
    // Don't show app bar on pages that have their own app bar or shouldn't have one
    // Base auth/system routes
    final noAppBarRoutePrefixes = <String>[
      '/splash',
      '/login',
      '/register',

      // Feature routes where pages provide their own AppBar
    ];

    return !noAppBarRoutePrefixes.any(
      (route) => currentRoute.startsWith(route),
    );
  }

  /// Gets the appropriate page title for the current route
  static String getPageTitle(String currentRoute) {
    return NavigationConfiguration.getRouteTitle(currentRoute);
  }

  // Gets the appropriate side navigation width based on navigation type
  static double getSideNavigationWidth(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 0; // No side navigation on mobile
      case NavigationType.tabletSideNav:
        return 280;
      case NavigationType.desktopSideNav:
        return 300;
    }
  }

  // Determines if the navigation should be persistent (always visible)
  static bool isNavigationPersistent(NavigationType navigationType) {
    return navigationType == NavigationType.tabletSideNav ||
        navigationType == NavigationType.desktopSideNav;
  }

  // Gets the appropriate app bar height based on device type
  static double getAppBarHeight(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return kToolbarHeight;
      case NavigationType.tabletSideNav:
        return kToolbarHeight + 4; // Slightly taller for tablet
      case NavigationType.desktopSideNav:
        return kToolbarHeight + 8; // Taller for desktop
    }
  }

  /// Determines the appropriate minimum touch target size
  static double getMinimumTouchTargetSize() {
    return 44.0; // Accessibility guideline minimum
  }

  /// Gets the appropriate bottom navigation height
  static double getBottomNavigationHeight() {
    return kBottomNavigationBarHeight;
  }

  /// Determines if bottom navigation should be shown
  static bool shouldShowBottomNavigation(NavigationType navigationType) {
    return navigationType == NavigationType.mobileBottomNav;
  }

  /// Gets the appropriate content padding based on navigation type
  static EdgeInsets getContentPadding(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return EdgeInsets.zero; // No extra padding on mobile
      case NavigationType.tabletSideNav:
        return const EdgeInsets.only(left: 280); // Account for side nav
      case NavigationType.desktopSideNav:
        return const EdgeInsets.only(left: 300); // Account for wider side nav
    }
  }

  /// Gets the appropriate navigation item spacing based on navigation type
  static double getNavigationItemSpacing(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 0; // Bottom nav handles its own spacing
      case NavigationType.tabletSideNav:
        return 4;
      case NavigationType.desktopSideNav:
        return 6;
    }
  }

  /// Gets the appropriate navigation item padding based on navigation type
  static EdgeInsets getNavigationItemPadding(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case NavigationType.tabletSideNav:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case NavigationType.desktopSideNav:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    }
  }

  /// Gets the appropriate icon size based on navigation type
  static double getNavigationIconSize(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 24;
      case NavigationType.tabletSideNav:
        return 26;
      case NavigationType.desktopSideNav:
        return 28;
    }
  }

  /// Gets the appropriate text style for navigation items
  static TextStyle getNavigationTextStyle(
    BuildContext context,
    NavigationType navigationType,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium;

    double fontSize;
    FontWeight fontWeight;

    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        fontSize = 12;
        fontWeight = isSelected ? FontWeight.w600 : FontWeight.w400;
        break;
      case NavigationType.tabletSideNav:
        fontSize = 14;
        fontWeight = isSelected ? FontWeight.w600 : FontWeight.w500;
        break;
      case NavigationType.desktopSideNav:
        fontSize = 15;
        fontWeight = isSelected ? FontWeight.w600 : FontWeight.w500;
        break;
    }

    return baseStyle?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: isSelected ? theme.primaryColor : null,
        ) ??
        TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: isSelected ? theme.primaryColor : null,
        );
  }

  /// Determines if hover effects should be enabled
  static bool shouldEnableHoverEffects(NavigationType navigationType) {
    return navigationType == NavigationType.desktopSideNav;
  }

  /// Gets the appropriate hover color for navigation items
  static Color? getHoverColor(
    BuildContext context,
    NavigationType navigationType,
  ) {
    if (!shouldEnableHoverEffects(navigationType)) return null;

    return Theme.of(context).primaryColor.withAlpha(20);
  }

  /// Gets the appropriate selection color for navigation items
  static Color? getSelectionColor(BuildContext context) {
    return Theme.of(context).primaryColor.withAlpha(30);
  }

  /// Gets the appropriate divider configuration for navigation sections
  static Widget? getNavigationDivider(
    BuildContext context,
    NavigationType navigationType,
  ) {
    if (navigationType == NavigationType.mobileBottomNav) {
      return null; // No dividers in bottom navigation
    }

    return Divider(
      height: navigationType == NavigationType.desktopSideNav ? 24 : 20,
      thickness: 1,
      color: Theme.of(context).dividerColor.withAlpha(127),
    );
  }

  // Gets the appropriate spacing between navigation sections
  static double getNavigationSectionSpacing(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 0;
      case NavigationType.tabletSideNav:
        return 16;
      case NavigationType.desktopSideNav:
        return 20;
    }
  }

  /// Determines the appropriate animation duration for navigation transitions
  static Duration getNavigationAnimationDuration(
    NavigationType navigationType,
  ) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return const Duration(milliseconds: 200);
      case NavigationType.tabletSideNav:
        return const Duration(milliseconds: 250);
      case NavigationType.desktopSideNav:
        return const Duration(milliseconds: 300);
    }
  }

  /// Gets the appropriate border radius for navigation items
  static BorderRadius getNavigationItemBorderRadius(
    NavigationType navigationType,
  ) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return BorderRadius.circular(0); // No border radius for bottom nav
      case NavigationType.tabletSideNav:
        return BorderRadius.circular(8);
      case NavigationType.desktopSideNav:
        return BorderRadius.circular(10);
    }
  }

  /// Gets the appropriate semantic properties for navigation items
  static Map<String, dynamic> getSemanticProperties(
    NavigationItem item,
    NavigationType navigationType,
    bool isSelected,
  ) {
    return {
      'label': item.accessibilityLabel,
      'hint': item.accessibilityHint,
      'role': item.semanticRole,
      'state': item.getStateDescription(isSelected),
      'enabled': item.isImplemented,
      'selected': isSelected,
    };
  }

  // Gets the appropriate elevation for navigation components
  static double getNavigationElevation(NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return 8; // Standard bottom nav elevation
      case NavigationType.tabletSideNav:
        return 4; // Subtle elevation for side nav
      case NavigationType.desktopSideNav:
        return 2; // Minimal elevation for desktop
    }
  }

  /// Determines if navigation items should show tooltips
  static bool shouldShowTooltips(NavigationType navigationType) {
    return navigationType == NavigationType.desktopSideNav;
  }
}
