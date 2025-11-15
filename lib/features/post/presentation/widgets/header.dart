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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.blueAccent.shade100,
                    child:
                        (organization.logoUrl != null &&
                            organization.logoUrl!.isNotEmpty)
                        ? Image.network(
                            organization.logoUrl!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              _getInitialCharactrOfOrganization(
                                organization.name,
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.role.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                    Text(
                      roleMessage,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UiConstants.spacingSm),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: manageOrgMessage,
                  onPressed: () {
                    // TODO: Manage organization
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manage posts coming soon')),
                    );
                  },
                  icon: const Icon(Icons.apartment_rounded),
                ),
              ),
              const SizedBox(width: UiConstants.spacingSm),
              Expanded(
                child: CustomButton(
                  text: managePostMessage,
                  onPressed: () {
                    // TODO: Manage posts
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manage posts coming soon')),
                    );
                  },
                  icon: const Icon(Icons.dashboard_customize_rounded),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: CustomTextField(
            hint: 'Search posts...',
            // controller: _searchController,
            prefixIcon: Icon(Icons.search),
            // onChanged: (value) => setState(() {}),
          ),
        ),
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
