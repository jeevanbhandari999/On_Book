import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            _showLogoutDialog(context);
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

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
