import 'package:flutter/material.dart';

class CustomBottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const CustomBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}