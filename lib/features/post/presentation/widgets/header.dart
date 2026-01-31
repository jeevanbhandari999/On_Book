import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final UserModel user;
  final OrganizationModel organization;
  const Header({super.key, required this.user, required this.organization});

  @override
  Widget build(BuildContext context) {
    String roleMessage = '';
    String manageOrgMessage = 'Manage Organization';
    String managePostMessage = 'Manage Posts';

    if (user.role == UserRole.admin) {
      roleMessage =
          'As an admin you can manage all posts related to this application';
    } else if (user.role == UserRole.owner) {
      roleMessage =
          'As an owner you can create and manage all posts related to this organization';
    } else if (user.role == UserRole.manager) {
      roleMessage =
          'As a manager, you can create, update, and manage posts related to this organization';
    } else if (user.role == UserRole.worker) {
      roleMessage =
          'As a staff, you can view and assist in post-related tasks.';
      manageOrgMessage = 'View Organization';
      managePostMessage = 'View Posts Lists';
    }

    return Column(
      children: [
        /// HEADER TOP
        Container(
          width: double.infinity,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LOGO / AVATAR
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child:
                    (organization.logoUrl != null &&
                        organization.logoUrl!.isNotEmpty)
                    ? Image.network(organization.logoUrl!, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          _getInitialCharactrOfOrganization(organization.name),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              /// TEXT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      roleMessage,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                      const SnackBar(content: Text('Manage posts coming soon')),
                    );
                  },
                ),
              ),
              const SizedBox(width: UiConstants.spacingXs),
              Expanded(
                child: CustomButton(
                  text: managePostMessage,
                  icon: const Icon(Icons.dashboard_customize_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manage posts coming soon')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        /// SEARCH
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: CustomTextField(
            hint: 'Search posts...',
            prefixIcon: Icon(Icons.search),
          ),
        ),

        const SizedBox(height: 12),

        Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
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
