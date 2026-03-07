import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/home/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:app/features/organizations/domain/usecases/can_manage_orgnization_use_case.dart';
import 'package:app/features/organizations/domain/usecases/get_organization_members_use_case.dart';
import 'package:app/features/organizations/domain/usecases/get_user_organization_detail_use_case.dart';
import 'package:app/features/organizations/presentation/bloc/get_user_organization_details_bloc.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:app/features/profile/presentation/pages/profile_image_page.dart';
import 'package:app/features/profile/presentation/widgets/view_user_profile_detail_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class ViewUserProfilePage extends StatelessWidget {
  final String userId;
  final String currentUserId;
  const ViewUserProfilePage({
    super.key,
    required this.userId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetCurrentUserProfileDetailsBloc(
        getCurrentUserProfileUseCase:
            DependencyInjection.get<GetCurrentUserProfileUseCase>(),
      )..add(GetCurrentUserProfileDetailsRequested(userId: userId)),
      child: ViewUserProfileView(currentUserId: currentUserId),
    );
  }
}

class ViewUserProfileView extends StatelessWidget {
  final String currentUserId;
  const ViewUserProfileView({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocBuilder<
            GetCurrentUserProfileDetailsBloc,
            GetCurrentUserProfileDetailsState
          >(
            builder: (context, state) {
              if (state is! GetCurrentUserProfileDetailsSuccess) {
                return const ViewUserProfileShimmer();
              }
              return CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, state.user),
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
                                  UiConstants.radiusMd,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.user.fullName.trim(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // No need to show the role of the user for now
                                  // Text(
                                  //   _getRoleDisplayName(state.user.role),
                                  //   style: const TextStyle(fontSize: 17),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: UiConstants.spacingMd),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              text: 'Say Hi to ${state.user.fullName}',
                              onPressed: () {
                                // Since this is the direct message so no need for the organization
                                context.push(
                                  RouteConstants.initialChatPlaceholderPage,
                                  extra: {
                                    'organizationId': null,
                                    'userId': currentUserId,
                                    'targetUserId': state.user.userId,
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: UiConstants.spacingMd),
                          const Text(
                            'Contact Information',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: UiConstants.spacingSm),
                          _buildProfileInfoCard(state.user),
                          const SizedBox(height: UiConstants.spacingMd),
                          const Text(
                            'Additional Information',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: UiConstants.spacingSm),
                          _buildInfoSection(context, state.user),
                          const SizedBox(height: UiConstants.spacingMd),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
      titleSpacing: 0,
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
                            const Icon(Icons.image_not_supported_sharp),
                      )
                    : Text(
                        user.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                      child: CircleAvatar(
                        child: ClipOval(
                          child:
                              user.imageUrl != null && user.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  width: double.infinity,
                                  height: double.infinity,
                                  imageUrl: user.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(color: Colors.white),
                                      ),
                                  errorWidget: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported_sharp,
                                      ),
                                )
                              : CachedNetworkImage(
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                ),
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
    return Container(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
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
    return Container(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
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

class OrganizationDetailTile extends StatelessWidget {
  final String organizationId;
  final String userId;
  final String role;
  const OrganizationDetailTile({
    super.key,
    required this.organizationId,
    required this.userId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetUserOrganizationDetailsBloc(
            getUserOrganizationDetailUseCase:
                DependencyInjection.get<GetUserOrganizationDetailUseCase>(),
            getOrganizationMembersUseCase:
                DependencyInjection.get<GetOrganizationMembersUseCase>(),
            canManageOrganizationUseCase:
                DependencyInjection.get<CanManageOrganizationUseCase>(),
          )..add(
            GetUserOrganizationDetailsRequested(
              organizationId: organizationId,
              userId: userId,
            ),
          ),
      child: OrganizationTile(
        organizationId: organizationId,
        userId: userId,
        role: role,
      ),
    );
  }
}

class OrganizationTile extends StatelessWidget {
  final String organizationId;
  final String userId;
  final String role;
  const OrganizationTile({
    super.key,
    required this.organizationId,
    required this.userId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GetUserOrganizationDetailsBloc,
      GetUserOrganizationDetailsState
    >(
      builder: (context, state) {
        if (state is! GetUserOrganizationDetailsSuccess) {
          final baseColor = Colors.grey[300]!;
          final highlightColor = Colors.grey[100]!;
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              children: [
                const CircleAvatar(radius: 24),
                const SizedBox(width: UiConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            UiConstants.radiusLg,
                          ),
                        ),
                        height: 20,
                      ),
                      const SizedBox(height: UiConstants.spacingSm),
                      Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            UiConstants.radiusLg,
                          ),
                        ),
                        height: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: UiConstants.spacingXl),

                const CircleAvatar(radius: 15),
              ],
            ),
          );
        }

        return ListTile(
          onTap: () {
            context.push(
              RouteConstants.organizationDetailsPageUserSide,
              extra: {'organizationId': organizationId, 'userId': userId},
            );
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: CircleAvatar(
            radius: 20,
            child: ClipOval(
              child:
                  state.organizationDetails.logoUrl != null &&
                      state.organizationDetails.logoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: state.organizationDetails.logoUrl!,
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
                      state.organizationDetails.name[0],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          title: Text(
            state.organizationDetails.name,
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            '${_getRoleDisplayName(enumFromString(UserRole.values, role)!)} of the organization',
          ),
        );
      },
    );
  }
}
