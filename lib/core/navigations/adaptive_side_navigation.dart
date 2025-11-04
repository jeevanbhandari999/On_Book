import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/navigations/adaptive_navigation.dart';
import 'package:app/core/navigations/responsive_navigation_controller.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/core/navigations/adaptive_app_bar.dart';

/// Adaptive side navigation that provides persistent navigation for tablet and desktop
class AdaptiveSideNavigation extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final NavigationType navigationType;

  const AdaptiveSideNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.navigationType,
  });

  @override
  State<AdaptiveSideNavigation> createState() => _AdaptiveSideNavigationState();
}

class _AdaptiveSideNavigationState extends State<AdaptiveSideNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ResponsiveNavigationController.getNavigationAnimationDuration(
        widget.navigationType,
      ),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          _buildSideNavigation(context),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// Builds the adaptive app bar
  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (!ResponsiveNavigationController.shouldShowAppBar(widget.currentRoute)) {
      return null;
    }

    return AdaptiveAppBar(
      currentRoute: widget.currentRoute,
      navigationType: widget.navigationType,
    );
  }

  /// Builds the persistent side navigation
  Widget _buildSideNavigation(BuildContext context) {
    final width = ResponsiveNavigationController.getSideNavigationWidth(
      widget.navigationType,
    );

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((-width) * (1 - _slideAnimation.value), 0),
          child: Container(
            width: width,
            decoration: _getSideNavigationDecoration(context),
            child: _buildSideNavigationContent(context),
          ),
        );
      },
    );
  }

  /// Gets the decoration for the side navigation
  BoxDecoration _getSideNavigationDecoration(BuildContext context) {
    return BoxDecoration(
      color:
          Theme.of(context).drawerTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: ResponsiveNavigationController.getNavigationElevation(
            widget.navigationType,
          ),
          offset: const Offset(2, 0),
        ),
      ],
    );
  }

  /// Builds the side navigation content
  Widget _buildSideNavigationContent(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildNavigationHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical:
                    ResponsiveNavigationController.getNavigationSectionSpacing(
                      widget.navigationType,
                    ),
              ),
              child: Column(
                children: [
                  _buildPrimaryNavigation(context),
                  ResponsiveNavigationController.getNavigationDivider(
                        context,
                        widget.navigationType,
                      ) ??
                      const SizedBox.shrink(),
                  _buildSecondaryNavigation(context),
                ],
              ),
            ),
          ),
          _buildNavigationFooter(context),
        ],
      ),
    );
  }

  /// Builds the navigation header
  Widget _buildNavigationHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveNavigationController.getNavigationSectionSpacing(
          widget.navigationType,
        ),
      ),
      child: Text('Hello'),
    );
  }

  // /// Builds header content with error handling
  // Widget _buildHeaderContent(BuildContext context) {
  //   try {
  //     return BlocBuilder<AuthBloc, AuthState>(
  //       builder: (context, state) {
  //         if (state is AuthAuthenticated) {
  //           return _buildAuthenticatedHeader(context, state);
  //         }
  //         return _buildDefaultHeader(context);
  //       },
  //     );
  //   } catch (e) {
  //     // AuthBloc not available in context, show default header
  //     if (AppConfig.isDebug) {
  //       print(
  //           '⚠️ AuthBloc not available in adaptive side navigation context: $e');
  //     }
  //     return _buildDefaultHeader(context);
  //   }
  // }

  /// Builds header for authenticated users
  // Widget _buildAuthenticatedHeader(
  //     BuildContext context, AuthAuthenticated state) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // Organization Info (if not admin)
  //       if (state.user.role != UserRole.admin &&
  //           state.organization != null) ...[
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.business,
  //               size: 20,
  //               color: Theme.of(context).primaryColor,
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 state.organization!.name,
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                       fontWeight: FontWeight.w600,
  //                       color: Theme.of(context).primaryColor,
  //                     ),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //       ],

  //       // Admin Logo (if admin)
  //       // if (state.user.role == UserRole.admin) ...[
  //       //   Row(
  //       //     children: [
  //       //       Icon(
  //       //         Icons.admin_panel_settings,
  //       //         size: 24,
  //       //         color: Theme.of(context).primaryColor,
  //       //       ),
  //       //       const SizedBox(width: 8),
  //       //       Text(
  //       //         'Admin Panel',
  //       //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //       //               fontWeight: FontWeight.bold,
  //       //               color: Theme.of(context).primaryColor,
  //       //             ),
  //       //       ),
  //       //     ],
  //       //   ),
  //         const SizedBox(height: 16),
  //       ],

  //       // User Info
  //       Row(
  //         children: [
  //           // User Avatar
  //           CircleAvatar(
  //             radius: 20,
  //             backgroundImage: state.user.avatarUrl != null
  //                 ? NetworkImage(state.user.avatarUrl!)
  //                 : null,
  //             child: state.user.avatarUrl == null
  //                 ? Text(
  //                     (state.user.fullName ?? 'U')[0].toUpperCase(),
  //                     style: const TextStyle(fontSize: 16),
  //                   )
  //                 : null,
  //           ),
  //           const SizedBox(width: 12),

  //           // User Details
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   state.user.fullName ?? 'User',
  //                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 2),
  //                 // Container(
  //                 //   padding:
  //                 //       const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                 //   decoration: BoxDecoration(
  //                 //     color: Theme.of(context).primaryColor.withOpacity(0.1),
  //                 //     borderRadius: BorderRadius.circular(8),
  //                 //   ),
  //                 //   child: Text(
  //                 //     _getRoleDisplayName(state.user.role),
  //                 //     style: Theme.of(context).textTheme.labelSmall?.copyWith(
  //                 //           color: Theme.of(context).primaryColor,
  //                 //           fontWeight: FontWeight.w500,
  //                 //         ),
  //                 //   ),
  //                 // ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  /// Builds default header
  // Widget _buildDefaultHeader(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'OnBook',
  //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //           fontWeight: FontWeight.bold,
  //           color: Theme.of(context).primaryColor,
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         'Community Management',
  //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //           color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(178),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  /// Get display name for user role
  // String _getRoleDisplayName(UserRole role) {
  //   switch (role) {
  //     case UserRole.user:
  //       return 'User';
  //     case UserRole.manager:
  //       return 'Manager';
  //     case UserRole.submanager:
  //       return 'Sub-Manager';
  //     case UserRole.admin:
  //       return 'Admin';
  //   }
  // }

  /// Builds the primary navigation section
  Widget _buildPrimaryNavigation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Main'),
        ...NavigationConfiguration.primaryItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildNavigationItem(context, item, index, true);
        }),
      ],
    );
  }

  /// Builds the secondary navigation section
  Widget _buildSecondaryNavigation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'More'),
        ...NavigationConfiguration.secondaryItems.asMap().entries.map((entry) {
          final index = entry.key + NavigationConfiguration.primaryItems.length;
          final item = entry.value;
          return _buildNavigationItem(context, item, index, false);
        }),
      ],
    );
  }

  /// Builds a section title
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            ResponsiveNavigationController.getNavigationItemPadding(
              widget.navigationType,
            ).horizontal /
            2,
        vertical: 8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(153),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds a navigation item
  Widget _buildNavigationItem(
    BuildContext context,
    NavigationItem item,
    int index,
    bool isPrimary,
  ) {
    final isSelected = item.isActiveForRoute(widget.currentRoute);
    final isHovered = _hoveredIndex == index;
    final shouldEnableHover =
        ResponsiveNavigationController.shouldEnableHoverEffects(
          widget.navigationType,
        );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            ResponsiveNavigationController.getNavigationItemPadding(
              widget.navigationType,
            ).horizontal /
            2,
        vertical:
            ResponsiveNavigationController.getNavigationItemSpacing(
              widget.navigationType,
            ) /
            2,
      ),
      child: MouseRegion(
        onEnter: shouldEnableHover ? (_) => _setHoveredIndex(index) : null,
        onExit: shouldEnableHover ? (_) => _setHoveredIndex(null) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _getItemBackgroundColor(context, isSelected, isHovered),
            borderRadius:
                ResponsiveNavigationController.getNavigationItemBorderRadius(
                  widget.navigationType,
                ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onNavigationItemTapped(context, item),
              borderRadius:
                  ResponsiveNavigationController.getNavigationItemBorderRadius(
                    widget.navigationType,
                  ),
              child: Container(
                constraints: BoxConstraints(
                  minHeight:
                      ResponsiveNavigationController.getMinimumTouchTargetSize(),
                ),
                padding:
                    ResponsiveNavigationController.getNavigationItemPadding(
                      widget.navigationType,
                    ),
                child: _buildNavigationItemContent(context, item, isSelected),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the navigation item content
  Widget _buildNavigationItemContent(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
  ) {
    final semanticProperties =
        ResponsiveNavigationController.getSemanticProperties(
          item,
          widget.navigationType,
          isSelected,
        );

    Widget content = Row(
      children: [
        Icon(
          isSelected ? item.selectedIcon : item.icon,
          size: ResponsiveNavigationController.getNavigationIconSize(
            widget.navigationType,
          ),
          color: _getItemIconColor(context, isSelected, item.isImplemented),
        ),
        SizedBox(
          width:
              ResponsiveNavigationController.getNavigationItemSpacing(
                widget.navigationType,
              ) *
              2,
        ),
        Expanded(
          child: Text(
            item.label,
            style:
                ResponsiveNavigationController.getNavigationTextStyle(
                  context,
                  widget.navigationType,
                  isSelected,
                ).copyWith(
                  color: _getItemTextColor(
                    context,
                    isSelected,
                    item.isImplemented,
                  ),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!item.isImplemented)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Soon',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
      ],
    );

    // Wrap with tooltip for desktop
    if (ResponsiveNavigationController.shouldShowTooltips(
      widget.navigationType,
    )) {
      content = Tooltip(message: item.tooltipText, child: content);
    }

    // Wrap with semantics
    return Semantics(
      label: semanticProperties['label'],
      hint: semanticProperties['hint'],
      button: true,
      enabled: semanticProperties['enabled'],
      selected: semanticProperties['selected'],
      child: content,
    );
  }

  /// Gets the background color for a navigation item
  Color? _getItemBackgroundColor(
    BuildContext context,
    bool isSelected,
    bool isHovered,
  ) {
    if (isSelected) {
      return ResponsiveNavigationController.getSelectionColor(context);
    }
    if (isHovered) {
      return ResponsiveNavigationController.getHoverColor(
        context,
        widget.navigationType,
      );
    }
    return null;
  }

  /// Gets the icon color for a navigation item
  Color _getItemIconColor(
    BuildContext context,
    bool isSelected,
    bool isImplemented,
  ) {
    if (!isImplemented) {
      return Theme.of(context).disabledColor;
    }
    if (isSelected) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).iconTheme.color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        Colors.black;
  }

  /// Gets the text color for a navigation item
  Color _getItemTextColor(
    BuildContext context,
    bool isSelected,
    bool isImplemented,
  ) {
    if (!isImplemented) {
      return Theme.of(context).disabledColor;
    }
    if (isSelected) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  }

  /// Builds the navigation footer
  Widget _buildNavigationFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveNavigationController.getNavigationSectionSpacing(
          widget.navigationType,
        ),
      ),
      child: _buildLogoutButton(context),
    );
  }

  /// Builds the logout button
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// Sets the hovered index
  void _setHoveredIndex(int? index) {
    if (mounted) {
      setState(() {
        _hoveredIndex = index;
      });
    }
  }

  /// Handles navigation item tap
  void _onNavigationItemTapped(BuildContext context, NavigationItem item) {
    // Don't close navigation - this is the key fix for persistent navigation

    if (!item.isImplemented) {
      _showUnimplementedFeatureMessage(context, item);
      return;
    }

    // Don't navigate if we're already on this route
    if (item.isActiveForRoute(widget.currentRoute)) {
      return;
    }

    try {
      context.go(item.route);
    } catch (e) {
      _showNavigationError(context, item);
    }
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

  /// Shows the logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Handles the logout action
  void _handleLogout(BuildContext context) {
    try {
      // Try to get AuthBloc and trigger logout
      // final authManager =
      DependencyInjection.get<AuthBloc>().add(const AuthLogoutRequested());
      // context.read<AuthBloc>().add(const AuthLogoutRequested());
      context.go(RouteConstants.login);
    } catch (e) {
      // Fallback navigation
      // context.go(RouteConstants.login);
    }
  }
}

/// Extension to provide additional side navigation utilities
extension AdaptiveSideNavigationExtension on AdaptiveSideNavigation {
  /// Creates a tablet side navigation
  static AdaptiveSideNavigation tablet({
    required Widget child,
    required String currentRoute,
  }) {
    return AdaptiveSideNavigation(
      currentRoute: currentRoute,
      navigationType: NavigationType.tabletSideNav,
      child: child,
    );
  }

  /// Creates a desktop side navigation
  static AdaptiveSideNavigation desktop({
    required Widget child,
    required String currentRoute,
  }) {
    return AdaptiveSideNavigation(
      currentRoute: currentRoute,
      navigationType: NavigationType.desktopSideNav,
      child: child,
    );
  }
}

/// Helper class for side navigation state management
class SideNavigationState {
  final String currentRoute;
  final NavigationType navigationType;
  final int? hoveredIndex;
  final bool isAnimating;

  const SideNavigationState({
    required this.currentRoute,
    required this.navigationType,
    this.hoveredIndex,
    this.isAnimating = false,
  });

  /// Creates a copy with updated properties
  SideNavigationState copyWith({
    String? currentRoute,
    NavigationType? navigationType,
    int? hoveredIndex,
    bool? isAnimating,
  }) {
    return SideNavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      navigationType: navigationType ?? this.navigationType,
      hoveredIndex: hoveredIndex ?? this.hoveredIndex,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}
