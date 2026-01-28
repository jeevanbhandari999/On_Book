import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = DependencyInjection.get<AuthService>();
    final userId = authService.getCurrentUserId();

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User ID required')));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authService: DependencyInjection.get<AuthService>()),
        ),
        BlocProvider(
          create: (context) => GetCurrentUserProfileDetailsBloc(
            getCurrentUserProfileUseCase:
                DependencyInjection.get<GetCurrentUserProfileUseCase>(),
          )..add(GetCurrentUserProfileDetailsRequested(userId: userId)),
        ),
      ],
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print(state);
          if (state is AuthUnauthenticated) {
            context.go(RouteConstants.login);
          }
        },
        child:
            BlocConsumer<
              GetCurrentUserProfileDetailsBloc,
              GetCurrentUserProfileDetailsState
            >(
              listener: (context, state) {
                if (state is GetCurrentUserProfileDetailsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is GetCurrentUserProfileDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GetCurrentUserProfileDetailsSuccess) {
                  return Column(
                    children: [
                      Text(state.user.fullName),
                      CustomButton(
                        text: 'Logout',
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  );
                }
                return const Center(child: Text('No profile data available'));
              },
            ),
      ),
    );
  }

  // void _showLogoutDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Logout'),
  //       content: const Text('Are you sure you want to logout?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             context.pop();
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             // context.pop();
  //             _handleLogout(context);
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Theme.of(context).colorScheme.error,
  //             foregroundColor: Colors.white,
  //           ),
  //           child: const Text('Logout'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _showLogoutDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              dialogContext.pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              dialogContext.pop(); // close dialog
              parentContext.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(parentContext).colorScheme.error,
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
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }
}
