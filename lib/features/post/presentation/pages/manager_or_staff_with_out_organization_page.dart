import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagerOrStaffWithOutOrganizationPage extends StatelessWidget {
  final UserModel user;

  const ManagerOrStaffWithOutOrganizationPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isManager = user.role == UserRole.manager;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.spacingLg),
          child: Column(
            children: [
              // Illustration / Icon
              Expanded(
                flex: 2,
                child: Center(
                  child: Icon(
                    Icons.apartment_outlined,
                    size: 120,
                    color: theme.colorScheme.primary.withAlpha(170),
                  ),
                ),
              ),

              // Title & Message
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You are not part of any organization yet.',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UiConstants.spacingMd),
                    Text(
                      isManager
                          ? 'As a Manager, you need to join or be invited to an organization to manage posts and staff.'
                          : 'As a Staff, you must be added to an organization by a Manager or Owner to view and assist with posts.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: UiConstants.spacingLg),
              // Action Buttons
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Join Organization Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Join an Organization',
                        onPressed: () {
                          context.push(
                            RouteConstants.selectHotelOrganization,
                            extra: user,
                          );
                        },
                        icon: const Icon(Icons.add_business_rounded),
                      ),
                    ),

                    const SizedBox(height: UiConstants.spacingSm),
                    // Change Role Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Change Role',
                        onPressed: () {
                          // TODO: Show role change dialog or navigate
                          _showChangeRoleDialog(context);
                        },
                        icon: const Icon(Icons.swap_horiz_rounded),
                        isOutlined: true,
                      ),
                    ),

                    const Spacer(),
                    // Back to Home
                    CustomButton(
                      text: 'Back to Home',
                      onPressed: () {
                        context.push(RouteConstants.home, extra: user);
                      },
                      icon: const Icon(Icons.home_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context) {
    Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a new role to continue:'),
            const SizedBox(height: 16),
            _buildRoleOption(
              ctx,
              UserRole.manager,
              'Manager',
              Icons.supervisor_account,
            ),
            _buildRoleOption(
              ctx,
              UserRole.worker,
              'Staff',
              Icons.person_outline,
            ),
            _buildRoleOption(
              ctx,
              UserRole.user,
              'General User',
              Icons.person_search,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    UserRole role,
    String label,
    IconData icon,
  ) {
    final isCurrent = user.role == role;
    return ListTile(
      leading: Icon(
        icon,
        color: isCurrent ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(label),
      trailing: isCurrent ? const Icon(Icons.check, color: Colors.green) : null,
      enabled: !isCurrent,
      onTap: () {
        Navigator.of(context).pop();
        // TODO: Trigger role change in auth bloc
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Switching to $label...')));
      },
    );
  }
}
