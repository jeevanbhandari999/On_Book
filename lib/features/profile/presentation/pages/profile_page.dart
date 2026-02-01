import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:app/features/profile/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = DependencyInjection.get<AuthService>();
    final userId = authService.getCurrentUserId();

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authService: authService)),
        BlocProvider(
          create: (context) => GetCurrentUserProfileDetailsBloc(
            getCurrentUserProfileUseCase: DependencyInjection.get(),
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
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is GetCurrentUserProfileDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GetCurrentUserProfileDetailsSuccess) {
                  final user = state.user;
                  return CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(context, user),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiConstants.spacingMd,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildProfileInfoCard(user),
                              const SizedBox(height: 24),
                              _buildInfoSection(context, user),
                              const SizedBox(height: 32),
                              _buildActionButtons(context),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User user) {
    return
    // SliverAppBar(
    //   expandedHeight: 220.0,
    //   floating: false,
    //   pinned: true,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    //   ),
    //   flexibleSpace: FlexibleSpaceBar(
    //     background: Stack(
    //       fit: StackFit.expand,
    //       children: [
    //         // Background gradient or image (you can replace with user cover if available)
    //         Container(
    //           decoration: BoxDecoration(
    //             gradient: LinearGradient(
    //               begin: Alignment.topCenter,
    //               end: Alignment.bottomCenter,
    //               colors: [
    //                 Theme.of(context).colorScheme.primary,
    //                 Theme.of(context).colorScheme.primary.withAlpha(180),
    //               ],
    //             ),
    //           ),
    //         ),
    //         // Avatar centered at bottom
    //         Positioned(
    //           bottom: 0,
    //           left: 0,
    //           right: 0,
    //           child: Column(
    //             children: [
    //               CircleAvatar(
    //                 radius: 60,
    //                 backgroundColor: Colors.white,
    //                 child: CircleAvatar(
    //                   radius: 56,
    //                   backgroundImage: user.imageUrl != null
    //                       ? NetworkImage(user.imageUrl!)
    //                       : null,
    //                   backgroundColor: Theme.of(context).colorScheme.surface,
    //                   child: user.imageUrl == null
    //                       ? Icon(
    //                           Icons.person,
    //                           size: 60,
    //                           color: Theme.of(context).colorScheme.primary,
    //                         )
    //                       : null,
    //                 ),
    //               ),
    //               const SizedBox(height: 12),
    //               Text(
    //                 user.fullName,
    //                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    //                   color: Colors.white,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               const SizedBox(height: 4),
    //               _buildRoleChip(user.role),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    //   actions: [
    //     IconButton(
    //       icon: const Icon(Icons.edit),
    //       onPressed: () {
    //         // TODO: Navigate to edit profile page
    //         // context.push(RouteConstants.editProfile, extra: user);
    //       },
    //     ),
    //   ],
    // );
    SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: MediaQuery.sizeOf(context).height * 0.25,
      backgroundColor: AppColors.primaryLight,
      collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
      elevation: 0,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_sharp, color: Colors.black),
          onPressed: () {},
        ),
      ],
      title: ShowOnCollapsedSliverAppBar(
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: ClipOval(
                child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.imageUrl!,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, error, stackTrace) =>
                            CachedNetworkImage(
                              imageUrl:
                                  'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
                            ),
                      )
                    : CachedNetworkImage(
                        imageUrl:
                            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(color: Colors.white),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: UiConstants.spacingSm),
            Text(user.fullName, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),

      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
          final t =
              (1.0 -
                      (settings.currentExtent - settings.minExtent) /
                          (settings.maxExtent - settings.minExtent))
                  .clamp(0.0, 1.0);

          final bgColor = Color.lerp(
            AppColors.primaryLight,
            Theme.of(context).colorScheme.primary,
            t,
          );

          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(UiConstants.radiusXl),
              ),
            ),
            child: FlexibleSpaceBar(
              background: Center(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: UiConstants.spacingXxl + UiConstants.spacingLg,
                  ),
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.imageUrl!,
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, error, stackTrace) =>
                              CachedNetworkImage(
                                imageUrl:
                                    'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
                              ),
                        )
                      : CachedNetworkImage(
                          imageUrl:
                              'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleChip(UserRole role) {
    final color = switch (role) {
      UserRole.owner => Colors.amber,
      UserRole.admin => Colors.redAccent,
      UserRole.manager => Colors.blueAccent,
      UserRole.worker => Colors.teal,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(
        role.value.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildProfileInfoCard(User user) {
    final authService = DependencyInjection.get<AuthService>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: authService.getCurrentUserEmail() ?? 'Not available',
            ),
            const Divider(height: 32),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user.phone ?? 'Not set',
            ),
            const Divider(height: 32),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: user.address ?? 'Not set',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Info',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          context,
          icon: Icons.business,
          title: 'Organization',
          subtitle: user.organizationId != null
              ? 'Member of organization'
              : 'No organization yet',
        ),
        const SizedBox(height: 8),
        _buildInfoTile(
          context,
          icon: Icons.calendar_today_outlined,
          title: 'Joined',
          subtitle: user.createdAt.toString().split(' ')[0],
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: 'Edit Profile',
          icon: const Icon(Icons.edit),
          onPressed: () {
            // TODO: Navigate to edit profile
          },
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Logout',
          isOutlined: true,
          textColor: Theme.of(context).colorScheme.error,
          onPressed: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () {
              dialogContext.pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
