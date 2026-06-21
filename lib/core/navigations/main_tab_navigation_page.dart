import 'package:app/core/navigations/custom_bottom_nav_bar.dart';
import 'package:app/core/navigations/custom_bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainTabNavigationPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainTabNavigationPage({super.key, required this.navigationShell});

  static const _navItems = <CustomBottomNavItem>[
    CustomBottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    CustomBottomNavItem(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search_rounded,
      label: 'Search',
    ),
    CustomBottomNavItem(
      icon: Icons.bookmark_border,
      selectedIcon: Icons.bookmark,
      label: 'Library',
    ),
    CustomBottomNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  static const _postItem = CustomBottomNavItem(
    icon: Icons.add_box_outlined,
    selectedIcon: Icons.add_box_rounded,
    label: 'Post',
  );

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          navItems: _navItems,
          postItem: _postItem,
          postIndex: 4,
        ),
      ),
    );
  }
}