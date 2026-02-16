import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/navigations/adaptive_app_bar.dart';
import 'package:app/core/navigations/adaptive_navigation.dart';
import 'package:app/core/navigations/responsive_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainTabNavigationPage extends StatefulWidget {
  final String currentRoute;
  final StatefulNavigationShell navigationShell;
  const MainTabNavigationPage({
    super.key,
    required this.currentRoute,
    required this.navigationShell,
  });

  @override
  State<MainTabNavigationPage> createState() => _MainTabNavigationPageState();
}

class _MainTabNavigationPageState extends State<MainTabNavigationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<NavigationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = NavigationConfiguration.implementedPrimaryItems;
    _tabController = TabController(
      initialIndex: NavigationConfiguration.getPrimaryIndex(
        widget.currentRoute,
      ),
      length: _items.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void didUpdateWidget(MainTabNavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      final newIndex = NavigationConfiguration.getPrimaryIndex(
        widget.currentRoute,
      );
      _tabController.animateTo(newIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.navigationShell.goBranch(newIndex, initialLocation: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    final index = _tabController.index;
    final item = _items[index];
    if (!item.isImplemented) {
      _showUnimplementedFeatureMessage(context, item);
      return;
    }
    // if (!item.isActiveForRoute(widget.currentRoute)) {
    //   context.go(item.route);
    // }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.navigationShell.goBranch(index);
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return PopScope(
          canPop:
              widget.currentRoute ==
              RouteConstants
                  .home, // Only allow pop on Home, if the active route is not home then navigate to the home once when user back instead of exiting the app completely
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop && widget.currentRoute != RouteConstants.home) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go(RouteConstants.home);
                }
              });
            }
          },
          child: Scaffold(
            // appBar: _buildAppBar(context),
            body: widget.navigationShell,
            // body: TabBarView(
            //   controller: _tabController,
            //   children: _items.map((item) {
            // return _getPageForRoute(item.route);
            //   }).toList(),
            // ),
            bottomNavigationBar: _buildBottomNavigationBar(
              context,
              orientation,
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (!ResponsiveNavigationController.shouldShowAppBar(widget.currentRoute)) {
      return null;
    }
    // Check if the current route is a primary tab route
    final isPrimaryTabRoute = _items.any(
      (item) => item.route == widget.currentRoute || widget.currentRoute == '/',
    );
    return AdaptiveAppBar(
      currentRoute: widget.currentRoute,
      navigationType: NavigationType.mobileBottomNav,
      showBackArrow:
          !isPrimaryTabRoute, // Hide back arrow for primary tab routes
      onBackPressed: () {
        context.go(RouteConstants.home); // Navigate to home for nested routes
      },
    );
  }

  Widget? _buildBottomNavigationBar(
    BuildContext context,
    Orientation orientation,
  ) {
    if (!ResponsiveNavigationController.shouldShowBottomNavigation(
      NavigationType.mobileBottomNav,
    )) {
      return null;
    }

    return orientation == Orientation.landscape
        ? _buildLandscapeBottomNavigationBar(context)
        : _buildPortraitBottomNavigationBar(context);
  }

  // Widget _buildPortraitBottomNavigationBar(BuildContext context) {
  //   final theme = Theme.of(context);

  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color:
  //           theme.bottomNavigationBarTheme.backgroundColor ??
  //           theme.colorScheme.surface,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withAlpha(13),
  //           blurRadius: 6,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: _items.asMap().entries.map((entry) {
  //           final index = entry.key;
  //           final item = entry.value;
  //           final isSelected = _tabController.index == index;

  //           return Expanded(
  //             child: InkWell(
  //               onTap: () => _tabController.animateTo(index),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   // Top indicator bar
  //                   AnimatedContainer(
  //                     duration: const Duration(milliseconds: 250),
  //                     height: 3,
  //                     decoration: BoxDecoration(
  //                       color: isSelected
  //                           ? theme.primaryColor
  //                           : Colors.transparent,
  //                       borderRadius: const BorderRadius.vertical(
  //                         bottom: Radius.circular(8),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   // Icon with rounded background
  //                   AnimatedContainer(
  //                     duration: const Duration(milliseconds: 200),
  //                     curve: Curves.easeInOut,
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 24,
  //                       vertical: 8,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: isSelected
  //                           ? theme.primaryColor.withAlpha(30)
  //                           : Colors.transparent,
  //                       borderRadius: BorderRadius.circular(
  //                         UiConstants.radiusRound,
  //                         // UiConstants.radiusMd,
  //                       ),
  //                     ),
  //                     child: Icon(
  //                       isSelected ? item.selectedIcon : item.icon,
  //                       color: isSelected
  //                           ? theme.primaryColor
  //                           : theme.unselectedWidgetColor,
  //                       size:
  //                           ResponsiveNavigationController.getNavigationIconSize(
  //                             NavigationType.mobileBottomNav,
  //                           ),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   // Label
  //                   Text(
  //                     item.label,
  //                     style: TextStyle(
  //                       fontSize: 11,
  //                       fontWeight: isSelected
  //                           ? FontWeight.w600
  //                           : FontWeight.w400,
  //                       color: isSelected
  //                           ? theme.primaryColor
  //                           : theme.unselectedWidgetColor,
  //                     ),
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPortraitBottomNavigationBar(BuildContext context) {
  //   final theme = Theme.of(context);

  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(
  //       UiConstants.spacingMd,
  //       0,
  //       UiConstants.spacingMd,
  //       UiConstants.spacingMd,
  //     ),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color:
  //             theme.bottomNavigationBarTheme.backgroundColor ??
  //             theme.colorScheme.surface,
  //         borderRadius: BorderRadius.circular(UiConstants.radiusRound),
  //         border: Border.all(color: theme.colorScheme.primary),
  //         boxShadow: [
  //           BoxShadow(
  //             color: theme.colorScheme.primary.withAlpha(100),
  //             blurRadius: 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: _items.asMap().entries.map((entry) {
  //           final index = entry.key;
  //           final item = entry.value;
  //           final isSelected = _tabController.index == index;

  //           return Expanded(
  //             child: InkWell(
  //               borderRadius: BorderRadius.circular(UiConstants.radiusXl),
  //               onTap: () => _tabController.animateTo(index),
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 10),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     /// ICON CONTAINER
  //                     AnimatedContainer(
  //                       duration: const Duration(milliseconds: 200),
  //                       curve: Curves.easeInOut,
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 18,
  //                         vertical: 8,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: isSelected
  //                             ? theme.colorScheme.primary
  //                             : Colors.transparent,
  //                         borderRadius: BorderRadius.circular(
  //                           UiConstants.radiusRound,
  //                         ),
  //                       ),
  //                       child: Icon(
  //                         isSelected ? item.selectedIcon : item.icon,
  //                         color: isSelected
  //                             ? theme.colorScheme.onPrimary
  //                             : theme.unselectedWidgetColor,
  //                         size:
  //                             ResponsiveNavigationController.getNavigationIconSize(
  //                               NavigationType.mobileBottomNav,
  //                             ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     // Label
  //                     Text(
  //                       item.label,
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         fontWeight: isSelected
  //                             ? FontWeight.w600
  //                             : FontWeight.w400,
  //                         color: isSelected
  //                             ? theme.primaryColor
  //                             : theme.unselectedWidgetColor,
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNavItem(
    BuildContext context,
    dynamic item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(UiConstants.radiusXl),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.unselectedWidgetColor,
              size: ResponsiveNavigationController.getNavigationIconSize(
                NavigationType.mobileBottomNav,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.unselectedWidgetColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConstants.spacingMd,
        0,
        UiConstants.spacingMd,
        UiConstants.spacingMd,
      ),
      child: Container(
        padding: const EdgeInsets.all(UiConstants.spacingSm),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(UiConstants.radiusRound),
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(80),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _tabController.index == index;

            return InkWell(
              onTap: () => _tabController.animateTo(index),
              borderRadius: BorderRadius.circular(UiConstants.radiusRound),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuad,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 20 : 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(UiConstants.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      size: 24,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : Colors.white,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: UiConstants.spacingXs),
                      Flexible(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLandscapeBottomNavigationBar(BuildContext context) {
    return Container(
      height: 60,
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
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildLandscapeNavigationItem(context, item, index);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLandscapeNavigationItem(
    BuildContext context,
    NavigationItem item,
    int index,
  ) {
    final isSelected = _tabController.index == index;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () => _tabController.animateTo(index),
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
                size: 20,
                color: isSelected
                    ? theme.primaryColor
                    : theme.unselectedWidgetColor,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
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
}
