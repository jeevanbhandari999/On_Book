import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/profile_avatar.dart';
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
        // BlocProvider(create: (context) => UpdateProfilePicture)
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
                              const SizedBox(height: UiConstants.spacingMd),
                              const Text(
                                'Personal Information',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    UiConstants.spacingMd,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      UiConstants.radiusXl,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withAlpha(90),
                                        Colors.white.withAlpha(40),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(22),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.fullName.trim(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _getRoleDisplayName(user.role),
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: UiConstants.spacingMd),
                              const Text(
                                'Contact Information',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              _buildProfileInfoCard(user),
                              const SizedBox(height: UiConstants.spacingMd),
                              const Text(
                                'Additional Information',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              _buildInfoSection(context, user),
                              const SizedBox(height: UiConstants.spacingMd),
                              const Text(
                                'Settings',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              _buildSettingsList(context, user),
                              const SizedBox(height: UiConstants.spacingXl),
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

  Container _buildSettingItem(
    BuildContext context, {
    IconData? icon,
    required String title,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
    Color? borderColor,
    Color? trailingColor,
    bool showBorder = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(30),
            Colors.white.withAlpha(100),
            Colors.white.withAlpha(200),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(22),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: showBorder
            ? Border.all(
                color: borderColor ?? Colors.white.withAlpha(80),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: UiConstants.spacingLg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        ),
        leading: icon != null ? Icon(icon, color: iconColor) : null,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textColor),
        ),
        trailing: Icon(Icons.chevron_right, color: trailingColor),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User user) {
    return SliverAppBar(
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
          icon: Container(
            padding: const EdgeInsets.all(UiConstants.spacingSm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UiConstants.radiusRound),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Icon(Icons.edit_sharp, color: Colors.white),
          ),
          onPressed: () {
            context.push(RouteConstants.editProfilePage);
          },
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
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: kToolbarHeight),
                  GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: AppImagePicker(
                        label: user.fullName[0].toUpperCase(),
                        showFileName: false,
                        borderRadius: UiConstants.radiusRound,
                        height: 200,
                        onImagePicked: (file) {},
                        showDottedBorder: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _shimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }

  Widget _textAvatar(String name) {
    return Container(
      color: Colors.grey,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(User user) {
    final authService = DependencyInjection.get<AuthService>();
    return Container(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withAlpha(90), Colors.white.withAlpha(40)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(22),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withAlpha(80), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: authService.getCurrentUserEmail() ?? 'Not available',
          ),
          const SizedBox(height: UiConstants.spacingMd),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone ?? 'Not set',
          ),
          const SizedBox(height: UiConstants.spacingMd),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: user.address ?? 'Not set',
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withAlpha(90), Colors.white.withAlpha(40)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(22),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withAlpha(80), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile(
            context,
            icon: Icons.business,
            title: 'Organization',
            subtitle: user.organizationId != null
                ? 'Member of organization'
                : 'No organization yet',
          ),

          _buildInfoTile(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Joined',
            subtitle: user.createdAt.toString().split(' ')[0],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
      dense: true,
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

  Widget _buildSettingsList(BuildContext context, User user) {
    return Column(
      children: [
        _buildSettingItem(
          context,
          icon: Icons.business,
          title: user.organizationId != null
              ? 'Member of organization'
              : 'No organization yet',
          borderColor: AppColors.black,
          onTap: () {
            context.push(RouteConstants.organizationDetailsPageOwnerSide);
          },
        ),
        const SizedBox(height: UiConstants.spacingSm),
        _buildSettingItem(
          context,
          icon: Icons.security_sharp,
          title: 'Security And Privacy',
          borderColor: AppColors.black,
          onTap: () {},
        ),
        const SizedBox(height: UiConstants.spacingSm),

        _buildSettingItem(
          context,
          icon: Icons.notifications_active_rounded,
          title: 'Notofications',
          borderColor: AppColors.black,
          onTap: () {},
        ),
        const SizedBox(height: UiConstants.spacingSm),
        _buildSettingItem(
          context,
          icon: Icons.logout,
          iconColor: AppColors.error,
          textColor: AppColors.error,
          borderColor: AppColors.error,
          trailingColor: AppColors.error,
          title: 'Logout',
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }
}

String _getRoleDisplayName(UserRole role) {
  switch (role) {
    case UserRole.owner:
      return 'Owner';
    case UserRole.admin:
      return 'Admin';
    case UserRole.manager:
      return 'Manager';
    case UserRole.worker:
      return 'Staff';
    default:
      return 'Guest';
  }
}
