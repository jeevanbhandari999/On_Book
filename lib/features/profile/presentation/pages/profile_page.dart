import 'dart:io';
import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/profile_avatar.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/delete_profile_picture_use_case.dart';
import 'package:app/features/profile/domain/usecases/update_profile_picture_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:app/features/profile/presentation/bloc/update_profile_picture_bloc.dart';
import 'package:app/features/profile/presentation/pages/profile_image_page.dart';
import 'package:app/features/profile/presentation/pages/view_user_profile_page.dart';
import 'package:app/features/profile/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:app/features/profile/presentation/widgets/view_user_profile_detail_shimmer.dart';
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
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              context.push(RouteConstants.login);
            },
            child: const Text('Please sign in'),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authService: authService)),
        BlocProvider(
          create: (context) => GetCurrentUserProfileDetailsBloc(
            getCurrentUserProfileUseCase: DependencyInjection.get(),
          )..add(GetCurrentUserProfileDetailsRequested(userId: userId)),
        ),
        BlocProvider(
          create: (context) => UpdateProfilePictureBloc(
            updateProfilePictureUseCase:
                DependencyInjection.get<UpdateProfilePictureUseCase>(),
            deleteProfilePictureUseCase:
                DependencyInjection.get<DeleteProfilePictureUseCase>(),
            repository: DependencyInjection.get<ProfileRepository>(),
          ),
        ),
      ],
      child: ProfileView(userId: userId),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GetCurrentUserProfileDetailsBloc>().add(
          GetCurrentUserProfileDetailsRequested(userId: userId),
        );
      },
      child: Scaffold(
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
                    // return const Center(child: CircularProgressIndicator());
                    return const ViewUserProfileShimmer();
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
                                GestureDetector(
                                  // onTap: () {
                                  //   context.push(
                                  //     RouteConstants.selectHotelOrganization,
                                  //     extra: UserModel.fromEntity(user),
                                  //   );
                                  // },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: SectionContainer(
                                      padding: const EdgeInsets.all(
                                        UiConstants.spacingMd,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        UiConstants.radiusMd,
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
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
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
      ),
    );
  }

  SectionContainer _buildSettingItem(
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
    return SectionContainer(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     Colors.white.withAlpha(30),
        //     Colors.white.withAlpha(100),
        //     Colors.white.withAlpha(200),
        //   ],
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withAlpha(22),
        //     blurRadius: 20,
        //     spreadRadius: 2,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
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
          horizontal: UiConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        ),
        // leading: icon != null ? Icon(icon, color: iconColor) : null,
        leading: Container(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          decoration: BoxDecoration(
            color: iconColor?.withAlpha(70),
            borderRadius: BorderRadius.circular(UiConstants.radiusSm),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
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
            child: const Icon(Icons.edit_sharp, color: Colors.black),
          ),
          onPressed: () {
            context.push(RouteConstants.editProfilePage, extra: {'user': user});
          },
        ),
      ],
      title: ShowOnCollapsedSliverAppBar(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.secondary.withAlpha(150),
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
                            const Icon(Icons.image_not_supported_sharp),
                      )
                    : Text(
                        user.fullName[0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: UiConstants.spacingSm),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
                    onTap: () {
                      if (user.imageUrl != null && user.imageUrl!.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileImagePage(user: user),
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child:
                          BlocListener<
                            UpdateProfilePictureBloc,
                            UpdateProfilePictureState
                          >(
                            listener: (context, state) {
                              if (state is UpdateProfilePictureSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile picture updated'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            child: AppImagePicker(
                              existingImageUrl: user.imageUrl,
                              label: user.fullName[0].toUpperCase(),
                              showFileName: false,
                              borderRadius: UiConstants.radiusRound,
                              height: 200,
                              onImagePicked: (file) {
                                context.read<UpdateProfilePictureBloc>().add(
                                  UpdateProfilePictureRequested(
                                    userId: user.userId,
                                    newPictureFile: File(file.path),
                                    existingImageUrlToDelete: user.imageUrl,
                                  ),
                                );
                              },
                              showDottedBorder: false,
                            ),
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

  Widget _buildProfileInfoCard(User user) {
    return SectionContainer(
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
            accentColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: UiConstants.spacingMd),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone ?? 'Not set',
            accentColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: UiConstants.spacingMd),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            accentColor: const Color(0xFFEF4444),
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
    Color? accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          decoration: BoxDecoration(
            color: accentColor?.withAlpha(70),
            borderRadius: BorderRadius.circular(UiConstants.radiusSm),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, User user) {
    return SectionContainer(
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      padding: const EdgeInsets.all(UiConstants.spacingMd),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.organizationId != null) ...[
            OrganizationDetailTile(
              organizationId: user.organizationId!,
              userId: user.userId,
              role: user.role.name,
            ),
            const SizedBox(height: UiConstants.spacingXs),
          ],
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Joined',
            value: user.createdAt.toString().split(' ')[0],
            accentColor: const Color(0xFF8B5CF6),
          ),
        ],
      ),
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
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
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
        const SizedBox(height: UiConstants.spacingSm),
        _buildSettingItem(
          context,
          icon: Icons.security_sharp,
          title: 'Security And Privacy',
          iconColor: AppColors.success,
          textColor: AppColors.black,
          borderColor: AppColors.black,
          onTap: () {},
        ),
        const SizedBox(height: UiConstants.spacingSm),
        _buildSettingItem(
          context,
          icon: Icons.notifications_active_rounded,
          title: 'Notofications',
          iconColor: AppColors.info,
          textColor: AppColors.black,
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
