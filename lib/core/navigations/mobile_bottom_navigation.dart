import 'package:app/core/navigations/adaptive_app_bar.dart';
import 'package:app/core/navigations/adaptive_navigation.dart';
import 'package:app/core/navigations/responsive_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// Enhanced mobile bottom navigation that handles landscape orientation and integrates with the new navigation architecture
class MobileBottomNavigation extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  const MobileBottomNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MobileBottomNavigation> createState() => _MobileBottomNavigationState();
}

class _MobileBottomNavigationState extends State<MobileBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: ResponsiveNavigationController.getNavigationAnimationDuration(
        NavigationType.mobileBottomNav,
      ),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: widget.child,
          bottomNavigationBar: _buildBottomNavigationBar(context, orientation),
        );
      },
    );
  }

  // Builds the adaptive app bar
  _buildAppBar(BuildContext context) {
    if (!ResponsiveNavigationController.shouldShowAppBar(widget.currentRoute)) {
      return null;
    }
    return AdaptiveAppBar(
      currentRoute: widget.currentRoute,
      navigationType: NavigationType.mobileBottomNav,
      // backgroundColor: Colors.transparent,
    );
  }

  // Builds the bottom navigation bar with orientations support
  _buildBottomNavigationBar(BuildContext context, Orientation orientation) {
    if (!ResponsiveNavigationController.shouldShowBottomNavigation(
      NavigationType.mobileBottomNav,
    )) {
      return null;
    }

    // return _buildBottomNavigationBarContent(context, orientation);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 100),
          child: _buildBottomNavigationBarContent(context, orientation),
        );
      },
    );
  }

  // Builds the actual bottom navigation bar content
  _buildBottomNavigationBarContent(
    BuildContext context,
    Orientation orientation,
  ) {
    final implementedItems = NavigationConfiguration.implementedPrimaryItems;

    // In landscape mode, show a more compact navigation
    if (orientation == Orientation.landscape) {
      return _buildLandscapeBottomNavigationBar(context, implementedItems);
    }

    // Portrait mode - standard bottom navigation
    return _buildPortraitBottomNavigationBar(context, implementedItems);
  }

  /// Builds bottom navigation for portrait orientation
  // Widget _buildPortraitBottomNavigationBar(
  //   BuildContext context,
  //   List<NavigationItem> items,
  // ) {
  //   final currentIndex = NavigationConfiguration.getPrimaryIndex(
  //     widget.currentRoute,
  //   );
  //   final safeIndex = currentIndex.clamp(0, items.length - 1);

  //   return BottomNavigationBar(
  //     type: BottomNavigationBarType.fixed,
  //     currentIndex: safeIndex,
  //     onTap: (index) => _onNavigationItemTapped(context, index),
  //     elevation: ResponsiveNavigationController.getNavigationElevation(
  //       NavigationType.mobileBottomNav,
  //     ),
  //     selectedItemColor: Theme.of(context).primaryColor,
  //     unselectedItemColor: Theme.of(context).unselectedWidgetColor,
  //     selectedFontSize: 12,
  //     unselectedFontSize: 10,
  //     iconSize: ResponsiveNavigationController.getNavigationIconSize(
  //       NavigationType.mobileBottomNav,
  //     ),
  //     items: items
  //         .map((item) => _buildBottomNavigationBarItem(context, item))
  //         .toList(),
  //   );
  // }

  /// Builds bottom navigation for portrait orientation
  Widget _buildPortraitBottomNavigationBar(
    BuildContext context,
    List<NavigationItem> items,
  ) {
    final currentIndex = NavigationConfiguration.getPrimaryIndex(
      widget.currentRoute,
    );
    final safeIndex = currentIndex.clamp(0, items.length - 1);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            theme.bottomNavigationBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = safeIndex == index;

            return Expanded(
              child: InkWell(
                // borderRadius: BorderRadius.circular(8),
                onTap: () => _onNavigationItemTapped(context, index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top border indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor.withAlpha(31)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.unselectedWidgetColor,
                        size:
                            ResponsiveNavigationController.getNavigationIconSize(
                              NavigationType.mobileBottomNav,
                            ),
                      ),
                    ),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.unselectedWidgetColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds bottom navigation for landscape orientation
  Widget _buildLandscapeBottomNavigationBar(
    BuildContext context,
    List<NavigationItem> items,
  ) {
    return Container(
      height: 60, // Reduced height for landscape
      decoration: BoxDecoration(
        color:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildLandscapeNavigationItem(context, item, index);
          }).toList(),
        ),
      ),
    );
  }

  /// Builds a landscape navigation item
  Widget _buildLandscapeNavigationItem(
    BuildContext context,
    NavigationItem item,
    int index,
  ) {
    final currentIndex = NavigationConfiguration.getPrimaryIndex(
      widget.currentRoute,
    );
    final implementedItems = NavigationConfiguration.implementedPrimaryItems;
    final safeCurrentIndex = currentIndex.clamp(0, implementedItems.length - 1);
    final isSelected = safeCurrentIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigationItemTapped(context, index),
        borderRadius:
            ResponsiveNavigationController.getNavigationItemBorderRadius(
              NavigationType.mobileBottomNav,
            ),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 20, // Smaller icon for landscape
                color: isSelected
                    ? theme.primaryColor
                    : theme.unselectedWidgetColor,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10, // Smaller text for landscape
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.unselectedWidgetColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a bottom navigation bar item
  // BottomNavigationBarItem _buildBottomNavigationBarItem(
  //   BuildContext context,
  //   NavigationItem item,
  // ) {
  //   return BottomNavigationBarItem(
  //     icon: _buildNavigationIcon(context, item, false),
  //     activeIcon: _buildNavigationIcon(context, item, true),
  //     label: item.label,
  //     tooltip: item.tooltipText,
  //   );
  // }

  /// Builds a navigation icon with proper accessibility support
  // Widget _buildNavigationIcon(
  //   BuildContext context,
  //   NavigationItem item,
  //   bool isActive,
  // ) {
  //   final icon = isActive ? item.selectedIcon : item.icon;
  //   final semanticProperties =
  //       ResponsiveNavigationController.getSemanticProperties(
  //         item,
  //         NavigationType.mobileBottomNav,
  //         isActive,
  //       );

  //   return Semantics(
  //     label: semanticProperties['label'],
  //     hint: semanticProperties['hint'],
  //     button: true,
  //     enabled: semanticProperties['enabled'],
  //     selected: semanticProperties['selected'],
  //     child: Container(
  //       constraints: BoxConstraints(
  //         minWidth: ResponsiveNavigationController.getMinimumTouchTargetSize(),
  //         minHeight: ResponsiveNavigationController.getMinimumTouchTargetSize(),
  //       ),
  //       child: Icon(
  //         icon,
  //         size: ResponsiveNavigationController.getNavigationIconSize(
  //           NavigationType.mobileBottomNav,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Handles navigation item tap with proper feedback and state management
  void _onNavigationItemTapped(BuildContext context, int index) {
    // Provide haptic feedback
    _provideHapticFeedback();

    // Get the navigation item
    final items = NavigationConfiguration.implementedPrimaryItems;
    if (index >= items.length) return;

    final item = items[index];

    // Handle unimplemented routes
    if (!item.isImplemented) {
      _showUnimplementedFeatureMessage(context, item);
      return;
    }

    // Navigate to the selected route
    _navigateToRoute(context, item);

    // Animate the selection change
    _animateSelectionChange();
  }

  /// Provides haptic feedback for navigation interactions
  void _provideHapticFeedback() {
    // Use light impact for navigation taps
    HapticFeedback.lightImpact();
  }

  /// Shows a message for unimplemented features
  void _showUnimplementedFeatureMessage(
    BuildContext context,
    NavigationItem item,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.label} coming soon!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Navigates to the specified route
  void _navigateToRoute(BuildContext context, NavigationItem item) {
    // Don't navigate if we're already on this route
    if (item.isActiveForRoute(widget.currentRoute)) {
      return;
    }
    try {
      context.go(item.route);
    } catch (e) {
      // Handle navigation errors gracefully
      _showNavigationError(context, item);
    }
  }

  /// Shows a navigation error message
  void _showNavigationError(BuildContext context, NavigationItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to navigate to ${item.label}'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Animates the selection change
  void _animateSelectionChange() {
    _animationController.reset();
    _animationController.forward();
  }
}

/// Extension to provide additional mobile navigation utilities
extension MobileBottomNavigationExtension on MobileBottomNavigation {
  /// Creates a mobile navigation with animation
  static Widget withAnimation({
    required Widget child,
    required String currentRoute,
    Duration? animationDuration,
  }) {
    return AnimatedSwitcher(
      duration: animationDuration ?? const Duration(milliseconds: 200),
      child: MobileBottomNavigation(
        key: ValueKey(currentRoute),
        currentRoute: currentRoute,
        child: child,
      ),
    );
  }
}

// Helper class for mobile navigation state management
class MobileNavigationState {
  final String currentRoute;
  final int selectedIndex;
  final bool isLandscape;
  final List<NavigationItem> availableItems;

  const MobileNavigationState({
    required this.currentRoute,
    required this.selectedIndex,
    required this.isLandscape,
    required this.availableItems,
  });

  /// Creates navigation state from current context
  factory MobileNavigationState.fromContext(
    BuildContext context,
    String currentRoute,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return MobileNavigationState(
      currentRoute: currentRoute,
      selectedIndex: NavigationConfiguration.getPrimaryIndex(currentRoute),
      isLandscape: isLandscape,
      availableItems: NavigationConfiguration.implementedPrimaryItems,
    );
  }

  /// Creates a copy with updated properties
  MobileNavigationState copyWith({
    String? currentRoute,
    int? selectedIndex,
    bool? isLandscape,
    List<NavigationItem>? availableItems,
  }) {
    return MobileNavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isLandscape: isLandscape ?? this.isLandscape,
      availableItems: availableItems ?? this.availableItems,
    );
  }
}
