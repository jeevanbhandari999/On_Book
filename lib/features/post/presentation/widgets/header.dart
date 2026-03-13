import 'dart:async';

import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/post/presentation/bloc/posts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Header extends StatefulWidget {
  final UserModel user;
  final OrganizationModel organization;
  const Header({super.key, required this.user, required this.organization});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String roleMessage = '';
    String manageOrgMessage = 'Manage Organization';
    String managePostMessage = 'Manage Posts';

    if (widget.user.role == UserRole.admin) {
      roleMessage =
          'As an admin you can manage all posts related to this application';
    } else if (widget.user.role == UserRole.owner) {
      roleMessage =
          'As an owner you can create and manage all posts related to this organization';
    } else if (widget.user.role == UserRole.manager) {
      roleMessage =
          'As a manager, you can create, update, and manage posts related to this organization';
    } else if (widget.user.role == UserRole.worker) {
      roleMessage =
          'As a staff, you can view and assist in post-related tasks.';
      manageOrgMessage = 'View Organization';
      managePostMessage = 'View Posts Lists';
    }

    return Column(
      children: [
        /// HEADER TOP
        Stack(
          children: [
            Positioned.fill(
              child:
                  Container(
                        padding: const EdgeInsets.fromLTRB(
                          UiConstants.spacingLg,
                          UiConstants.spacingXxl + UiConstants.spacingSm,
                          UiConstants.spacingLg,
                          UiConstants.spacingLg,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(UiConstants.radiusXl),
                          ),
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: -2,
                        duration: UiConstants.animationSlow,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(duration: UiConstants.animationSlow),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                UiConstants.spacingLg,
                UiConstants.spacingXxl + UiConstants.spacingSm,
                UiConstants.spacingLg,
                UiConstants.spacingLg,
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// LOGO / AVATAR
                  ClipOval(
                    child:
                        CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary.withAlpha(150),
                              child:
                                  (widget.organization.logoUrl != null &&
                                      widget.organization.logoUrl!.isNotEmpty)
                                  ? Image.network(
                                      width: double.infinity,
                                      height: double.infinity,
                                      widget.organization.logoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        _getInitialCharactrOfOrganization(
                                          widget.organization.name,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            )
                            .animate(delay: UiConstants.animationFast)
                            .scale(duration: UiConstants.animationNormal),
                  ),

                  const SizedBox(width: 12),

                  /// TEXT CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                              widget.organization.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                            .animate()
                            .slideX(
                              begin: -1,
                              duration: UiConstants.animationSlow,
                              curve: Curves.easeOutCubic,
                            )
                            .fadeIn(duration: UiConstants.animationSlow),
                        const SizedBox(height: 4),
                        Text(
                              widget.user.role
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,

                                fontWeight: FontWeight.w600,
                              ),
                            )
                            .animate(delay: UiConstants.animationFast)
                            .slideY(
                              begin: 0.4,
                              duration: UiConstants.animationNormal,
                              curve: Curves.easeOutCubic,
                            )
                            .fadeIn(duration: UiConstants.animationNormal),
                        const SizedBox(height: 6),
                        Text(
                              roleMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            )
                            .animate(delay: UiConstants.animationNormal)
                            .slideY(
                              begin: 0.6,
                              duration: UiConstants.animationNormal,
                              curve: Curves.easeOutCubic,
                            )
                            .fadeIn(duration: UiConstants.animationNormal),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        /// ACTION BUTTONS
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                    child: CustomButton(
                      text: manageOrgMessage,
                      icon: const Icon(Icons.apartment_rounded),
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Manage posts coming soon'),
                          ),
                        );
                      },
                    ),
                  )
                  .animate(delay: UiConstants.animationFast)
                  .fadeIn(duration: UiConstants.animationNormal)
                  .slideY(
                    begin: 0.4,
                    duration: UiConstants.animationNormal,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(width: UiConstants.spacingXs),
              Expanded(
                    child: CustomButton(
                      text: managePostMessage,
                      icon: const Icon(Icons.dashboard_customize_rounded),
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Manage posts coming soon'),
                          ),
                        );
                      },
                    ),
                  )
                  .animate(delay: UiConstants.animationSlow)
                  .fadeIn(duration: UiConstants.animationNormal)
                  .slideY(
                    begin: 0.4,
                    duration: UiConstants.animationNormal,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),

        /// SEARCH
        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomTextField(
                hint: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    context.read<OrganizationPostsBloc>().add(
                      SearchOrganizationPosts(query: value),
                    );
                  });
                },
              ),
            )
            .animate(delay: UiConstants.animationNormal)
            .fadeIn(duration: UiConstants.animationNormal)
            .slideY(
              begin: 0.3,
              duration: UiConstants.animationNormal,
              curve: Curves.easeOutCubic,
            ),

        const SizedBox(height: 12),
      ],
    );
  }
}

String _getInitialCharactrOfOrganization(String name) {
  return name
      .trim()
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .join();
}
