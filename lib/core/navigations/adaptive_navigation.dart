import 'package:app/app/router/route_constants.dart';
import 'package:app/core/navigations/adaptive_side_navigation.dart';
import 'package:app/core/navigations/mobile_bottom_navigation.dart';
import 'package:app/core/navigations/responsive_navigation_controller.dart';
import 'package:flutter/material.dart';

class AdaptiveNavigation extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  const AdaptiveNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AdaptiveNavigation> createState() => _AdaptiveNavigationState();
}

class _AdaptiveNavigationState extends State<AdaptiveNavigation>
    with TickerProviderStateMixin {
  // late AnimationController _transitionController;
  // late Animation<double> _transitionAnimation;
  // NavigationType? _previousNavigationType;
  NavigationType? _currentType;

  // @override
  // void initState() {
  //   super.initState();
  //   _transitionController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 300),
  //   );
  //   _transitionAnimation = CurvedAnimation(
  //     parent: _transitionController,
  //     curve: Curves.easeInOut,
  //   );
  //   _transitionController.forward();
  // }

  // @override
  // void dispose() {
  //   _transitionController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navigationType = ResponsiveNavigationController.getNavigationType(
          constraints.maxWidth,
        );

        // Animate transition when navigation type changes
        // if (_previousNavigationType != null &&
        //     _previousNavigationType != navigationType) {
        //   _animateNavigationTypeChange();
        // }
        // _previousNavigationType = navigationType;

        // return AnimatedBuilder(
        //   animation: _transitionAnimation,
        //   builder: (context, child) {
        //     return _buildNavigationForType(context, navigationType);
        //   },
        // );
        if (_currentType != navigationType) {
          _currentType = navigationType;
        }

        return _buildNavigationShell(navigationType);
      },
    );
  }

  Widget _buildNavigationShell(NavigationType type) {
    switch (type) {
      case NavigationType.mobileBottomNav:
        return MobileBottomNavigation(
          key: const ValueKey('mobile-nav'), // Persistent key
          currentRoute: widget.currentRoute,
          child: widget.child,
        );
      case NavigationType.tabletSideNav:
        return AdaptiveSideNavigation(
          key: const ValueKey('tablet-nav'),
          currentRoute: widget.currentRoute,
          navigationType: NavigationType.tabletSideNav,
          child: widget.child,
        );
      case NavigationType.desktopSideNav:
        return AdaptiveSideNavigation(
          key: const ValueKey('desktop-nav'),
          currentRoute: widget.currentRoute,
          navigationType: NavigationType.desktopSideNav,
          child: widget.child,
        );
    }
  }

  /// Animates the transition when navigation type changes
  // void _animateNavigationTypeChange() {
  //   _transitionController.reset();
  //   _transitionController.forward();
  // }

  // Builds the appropriate navigation components according to the navigation type
  _buildNavigationForType(BuildContext context, NavigationType navigationType) {
    switch (navigationType) {
      case NavigationType.mobileBottomNav:
        return MobileBottomNavigation(
          currentRoute: widget.currentRoute,
          child: widget.child,
        );
      case NavigationType.tabletSideNav:
        return AdaptiveSideNavigation(
          currentRoute: widget.currentRoute,
          navigationType: NavigationType.tabletSideNav,
          child: widget.child,
        );
      case NavigationType.desktopSideNav:
        return AdaptiveSideNavigation(
          currentRoute: widget.currentRoute,
          navigationType: NavigationType.desktopSideNav,
          child: widget.child,
        );
    }
  }
}

// Enhanced navigation Items Data with accessibility support
class NavigationItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String? semanticLabel;
  final List<String>? childRoutes;
  final bool isImplemented;
  final String? tooltip;
  final String? description;

  const NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.semanticLabel,
    this.childRoutes,
    this.isImplemented = true,
    this.tooltip,
    this.description,
  });

  // Accessibility label getter
  String get accessibilityLabel => semanticLabel ?? 'Navigate to $label';

  // Tooltip text for hover states (desktop)
  String get tooltipText => tooltip ?? label;

  // Description for screen readers
  String get accessibilityDescription =>
      description ?? 'Navigate to $label section';

  // Get accessibility hint based on implementation status
  String get accessibilityHint {
    if (!isImplemented) {
      return '$label is not yet available';
    }
    if (hasChildRoutes) {
      return '$label section with ${childRoutes!.length} subsections';
    }
    return 'Navigate to $label';
  }

  // Check if this item is active for the given route
  bool isActiveForRoute(String currentRoute) {
    return NavigationConfiguration.isRouteActive(route, currentRoute);
  }

  // Check if this item has child routes
  bool get hasChildRoutes => childRoutes != null && childRoutes!.isNotEmpty;

  // Get child routes
  List<String> get childRoutesList => childRoutes ?? [];

  // Get semantic role for accessibility
  String get semanticRole => 'button';

  // Check if item should be announced to screen readers
  bool get shouldAnnounceToScreenReader => true;

  // Get state description for screen readers
  String getStateDescription(bool isActive) {
    if (!isImplemented) return 'unavailable';
    if (isActive) return 'selected';
    return 'unselected';
  }

  // Create a copy with updated properties
  NavigationItem copyWith({
    String? route,
    String? label,
    IconData? icon,
    IconData? selectedIcon,
    String? semanticLabel,
    List<String>? childRoutes,
    bool? isImplemented,
    String? tooltip,
    String? description,
  }) {
    return NavigationItem(
      route: route ?? this.route,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      childRoutes: childRoutes ?? this.childRoutes,
      isImplemented: isImplemented ?? this.isImplemented,
      tooltip: tooltip ?? this.tooltip,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem &&
        other.route == route &&
        other.label == label &&
        other.icon == icon &&
        other.selectedIcon == selectedIcon &&
        other.semanticLabel == semanticLabel &&
        other.isImplemented == isImplemented &&
        other.tooltip == tooltip &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      route,
      label,
      icon,
      selectedIcon,
      semanticLabel,
      isImplemented,
      tooltip,
      description,
    );
  }

  @override
  String toString() {
    return 'NavigationItem(reoue: $route, label: $label, isImplemented: $isImplemented)';
  }
}

// Enhanced Navigation Configuration
class NavigationConfiguration {
  // Primary navigation items(bottom nav on mobile, main rail on desktop/tablet)
  static const List<NavigationItem> primaryItems = [
    NavigationItem(
      route: RouteConstants.home,
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      semanticLabel: 'Navigate to Home',
      tooltip: 'Go to Home page',
      description: 'Navigate to the main home dashboard',
      childRoutes: ['/'],
      isImplemented: true,
    ),

    NavigationItem(
      route: RouteConstants.searchPage,
      label: 'Search',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search_rounded,
      semanticLabel: 'Navigate to Search',
      tooltip: 'Go to Search page',
      description: 'Navigate to the search interface',
      childRoutes: ['/'],
      isImplemented: true,
    ),

    NavigationItem(
      route: RouteConstants.postPage,
      label: 'Create',
      icon: Icons.add_circle_outline,
      selectedIcon: Icons.add_circle_rounded,
      semanticLabel: 'Navigate to Create',
      tooltip: 'Add or create new content',
      description: 'Navigate to content creation dashboard',
      childRoutes: ['/'],
      isImplemented: true,
    ),

    NavigationItem(
      route: RouteConstants.libraryPage,
      label: 'Library',
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books_rounded,
      semanticLabel: 'Navigate to Library',
      tooltip: 'Go to your Library',
      description: 'Access your saved books or media',
      childRoutes: ['/'],
      isImplemented: true,
    ),

    NavigationItem(
      route: RouteConstants.profilePage,
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
      semanticLabel: 'Navigate to Profile',
      tooltip: 'Go to Profile page',
      description: 'View and edit your profile',
      childRoutes: ['/'],
      isImplemented: true,
    ),
  ];
  static const List<NavigationItem> secondaryItems = [
    NavigationItem(
      route: RouteConstants.libraryPage,
      label: 'Library',
      icon: Icons.video_library_outlined,
      selectedIcon: Icons.video_library,
      semanticLabel: 'Navigate to Library',
      tooltip: 'Go to your Library',
      description: 'Access your saved books or media',
      childRoutes: ['/'],
      isImplemented: true,
    ),

    NavigationItem(
      route: RouteConstants.chatUserListPage,
      label: 'Chat',
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble_outline,
      semanticLabel: 'Navigate to Chat',
      tooltip: 'Go to chat page',
      description: 'View and edit your chatting',
      childRoutes: ['/'],
      isImplemented: true,
    ),
  ];

  // Route titles mapping for dynamic page title management
  static const Map<String, String> routeTitles = {
    '/': 'Home',
    '/home': 'Home',
    '/searchPage': 'Search',
    '/postPage': 'Create',
    '/libraryPage': 'Library',
    '/profilePage': 'Profile',
  };

  // Get page title for current route with support for dynamic titles
  static String getRouteTitle(String currentRoute) {
    // Check for exact match first
    if (routeTitles.containsKey(currentRoute)) {
      return routeTitles[currentRoute]!;
    }

    // Check for pattern matches with dynamic segments
    for (final entry in routeTitles.entries) {
      if (_matchesRoutePattern(entry.key, currentRoute)) {
        return _generateDynamicTitle(entry.value, currentRoute);
      }
    }

    // Fallback: try to extract title from route path
    return _generateTitleFromRoute(currentRoute);
  }

  // Get navigation item by route
  static NavigationItem? getItemByRoute(String route) {
    return _findNavigationItem(route);
  }

  // Get current index for primary navigation with improved route matching
  static int getPrimaryIndex(String currentRoute) {
    final implementedItems = implementedPrimaryItems;
    for (int i = 0; i < implementedItems.length; i++) {
      if (isRouteActive(implementedItems[i].route, currentRoute)) {
        return i;
      }
    }
    // Ensure we return a valid index within bounds
    return 0; // Default to first implemented item
    // final routes = [
    //   RouteConstants.home,
    //   RouteConstants.searchPage,
    //   RouteConstants.postPage,
    //   RouteConstants.libraryPage,
    //   RouteConstants.profilePage,
    // ];
    // return routes
    //     .indexWhere((r) => currentRoute.startsWith(r))
    //     .clamp(0, routes.length - 1);
  }

  // Enhanced route matching that supports nested routes and child routes
  static bool isRouteActive(String itemRoute, String currentRoute) {
    // Handle root route special case
    if (itemRoute == RouteConstants.home || itemRoute == '/') {
      return currentRoute == '/' || currentRoute == '/home';
    }

    // Direct route match
    if (currentRoute == itemRoute) {
      return true;
    }

    // Check if current route starts with item route (for nested routes)
    if (currentRoute.startsWith(itemRoute)) {
      // Ensure it's a proper path segment match, not just a prefix
      final remainingPath = currentRoute.substring(itemRoute.length);
      return remainingPath.isEmpty || remainingPath.startsWith('/');
    }

    // Check child routes for the item
    final item = _findNavigationItem(itemRoute);
    if (item?.childRoutes != null) {
      for (final childRoute in item!.childRoutes!) {
        if (_matchesRoutePattern(childRoute, currentRoute)) {
          return true;
        }
      }
    }

    return false;
  }

  // Helper method to find navigation item by route
  static NavigationItem? _findNavigationItem(String route) {
    // Check primary items
    for (final item in primaryItems) {
      if (item.route == route) return item;
    }
    // Check secondary items
    for (final item in secondaryItems) {
      if (item.route == route) return item;
    }
    return null;
  }

  // Helper method to match route patterns (supports :param syntax)
  static bool _matchesRoutePattern(String pattern, String route) {
    // Handle exact matches first
    if (pattern == route) return true;

    // Convert pattern to regex for parameter matching
    final regexPattern = pattern
        .replaceAll(RegExp(r':[\w]+'), r'[^/]+') // Replace :param with [^/]+
        .replaceAll('/', r'\/'); // Escape forward slashes

    final regex = RegExp('^$regexPattern\$');
    return regex.hasMatch(route);
  }

  // Generate dynamic title for routes with parameters
  static String _generateDynamicTitle(String baseTitle, String currentRoute) {
    // For now, return base title. Can be enhanced to extract IDs and create
    // more specific titles like "Group: Group Name" or "Event: Event Name"
    return baseTitle;
  }

  // Generate title from route path as fallback
  static String _generateTitleFromRoute(String route) {
    if (route == '/' || route.isEmpty) return 'Home';

    // Remove leading slash and split by slash
    final segments = route.substring(1).split('/');
    final lastSegment = segments.last;

    // Convert kebab-case or snake_case to Title Case
    return lastSegment
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  // Get implemented navigation items only
  static List<NavigationItem> get implementedPrimaryItems =>
      primaryItems.where((item) => item.isImplemented).toList();

  static List<NavigationItem> get implementedSecondaryItems =>
      secondaryItems.where((item) => item.isImplemented).toList();
}
