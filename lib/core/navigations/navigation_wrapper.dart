import 'package:app/core/navigations/adaptive_navigation.dart';
import 'package:app/core/navigations/responsive_navigation_controller.dart';
import 'package:flutter/material.dart';

/// Enhanced NavigationWrapper that provides intelligent route-based navigation
/// display with improved error handling and state management
class NavigationWrapper extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final bool showNavigation;
  final VoidCallback? onNavigationError;
  final Widget? fallbackWidget;

  const NavigationWrapper({
    super.key,
    required this.child,
    required this.currentRoute,
    this.showNavigation = true,
    this.onNavigationError,
    this.fallbackWidget,
  });

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  // String? _previousRoute; // Reserved for future route-change animations
  bool _hasNavigationError = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(NavigationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when route changes
    if (oldWidget.currentRoute != widget.currentRoute) {
      _animateRouteChange();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildContent(context),
        );
      },
    );
  }

  /// Builds the main content with navigation logic
  Widget _buildContent(BuildContext context) {
    try {
      final navigationDecision = _makeNavigationDecision();

      if (_hasNavigationError) {
        return _buildErrorFallback(context);
      }

      if (!navigationDecision.shouldShow) {
        return widget.child;
      }

      // Wrap with AuthBloc provider for navigation components
      return AdaptiveNavigation(
        currentRoute: widget.currentRoute,
        child: widget.child,
      );
    } catch (e) {
      _handleNavigationError(e);
      return _buildErrorFallback(context);
    }
  }

  /// Makes navigation decision based on current route and device type
  NavigationDecision _makeNavigationDecision() {
    try {
      // Get screen width for navigation type determination
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final navigationType = ResponsiveNavigationController.getNavigationType(
        screenWidth,
      );

      // Determine if navigation should be shown based on route
      final noNavigationRoutes = [
        '/splash',
        '/login',
        '/register',
        '/forgot-password',
        '/complete-profile',
        '/create-organization',
      ];

      final shouldShow =
          widget.showNavigation &&
          !noNavigationRoutes.any(
            (route) => widget.currentRoute.startsWith(route),
          );

      return NavigationDecision(
        shouldShow: shouldShow,
        navigationType: navigationType,
      );
    } catch (e) {
      _handleNavigationError(e);
      return NavigationDecision(shouldShow: false);
    }
  }

  /// Handles navigation errors gracefully
  void _handleNavigationError(dynamic error) {
    _hasNavigationError = true;
    widget.onNavigationError?.call();
  }

  /// Builds error fallback widget
  Widget _buildErrorFallback(BuildContext context) {
    return widget.fallbackWidget ??
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Navigation Error',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unable to load navigation',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasNavigationError = false;
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
  }

  /// Animates route changes
  void _animateRouteChange() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }
}

/// Navigation decision data class
class NavigationDecision {
  final bool shouldShow;
  final NavigationType navigationType;

  NavigationDecision({
    required this.shouldShow,
    this.navigationType = NavigationType.mobileBottomNav,
  });
}

