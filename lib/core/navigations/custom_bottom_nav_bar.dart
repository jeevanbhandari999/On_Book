import 'dart:ui' as ui;

import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/navigations/custom_bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Regular navigation tabs
  final List<CustomBottomNavItem> navItems;

  /// Separate Post button
  final CustomBottomNavItem postItem;

  /// Branch index of the Post route in StatefulShellRoute
  final int postIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navItems,
    required this.postItem,
    required this.postIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child:
              Padding(
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(UiConstants.spacingSm),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(80),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(40),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: navItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return _NavItem(
                                item: item,
                                isSelected: currentIndex == index,
                                onTap: () => onTap(index),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: 1.2,
                    end: 0.0,
                    duration: UiConstants.animationSlow,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: UiConstants.animationNormal),
        ),

        Padding(
          padding: const EdgeInsets.only(
            right: UiConstants.spacingMd,
            top: UiConstants.spacingMd,
            bottom: UiConstants.spacingMd,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(UiConstants.spacingSm),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withAlpha(80),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _NavItem(
                  item: postItem,
                  isSelected: currentIndex == postIndex,
                  onTap: () => onTap(postIndex),
                ),
              ),
            ),
          ),
        ).animate().scale(duration: UiConstants.animationDelaySlow),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final CustomBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final maxSelectedWidth = (screenWidth * 0.4).clamp(80.0, 160.0);

    return InkWell(
      borderRadius: BorderRadius.circular(35),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        constraints: BoxConstraints(
          maxWidth: isSelected ? maxSelectedWidth : 48,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(35),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: 24,
              color: isSelected ? theme.colorScheme.onPrimary : Colors.white,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              alignment: Alignment.centerLeft,
              child: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}