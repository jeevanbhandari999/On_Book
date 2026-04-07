import 'dart:io';

import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/profile_avatar.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/home/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:app/features/organizations/domain/usecases/can_manage_orgnization_use_case.dart';
import 'package:app/features/organizations/domain/usecases/delete_organization_logo_use_case.dart';
import 'package:app/features/organizations/domain/usecases/get_organization_members_use_case.dart';
import 'package:app/features/organizations/domain/usecases/get_user_organization_detail_use_case.dart';
import 'package:app/features/organizations/domain/usecases/update_organization_logo_use_case.dart';
import 'package:app/features/organizations/presentation/bloc/get_user_organization_details_bloc.dart';
import 'package:app/features/organizations/presentation/bloc/update_organization_logo_bloc.dart';
import 'package:app/features/organizations/presentation/pages/organization_image_page.dart';
import 'package:app/features/organizations/presentation/widgets/organization_detail_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class OrganizationDetailsPageUserSide extends StatelessWidget {
  final String organizationId;
  final String userId;
  const OrganizationDetailsPageUserSide({
    super.key,
    required this.organizationId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
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
        ),
        BlocProvider(
          create: (context) => UpdateOrganizationLogoBloc(
            updateOrganizationLogoUseCase:
                DependencyInjection.get<UpdateOrganizationLogoUseCase>(),
            deleteOrganizationLogoUseCase:
                DependencyInjection.get<DeleteOrganizationLogoUseCase>(),
            repository: DependencyInjection.get<OrganizationRepository>(),
          ),
        ),
      ],
      child: OrganizationDetailsViewUserSide(userId: userId),
    );
  }
}

class OrganizationDetailsViewUserSide extends StatelessWidget {
  final String userId;
  const OrganizationDetailsViewUserSide({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocConsumer<
            GetUserOrganizationDetailsBloc,
            GetUserOrganizationDetailsState
          >(
            listener: (context, state) {
              if (state is GetUserOrganizationDetailsError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is GetUserOrganizationDetailsLoading) {
                return const OrganizationDetailsShimmer();
              }
              if (state is! GetUserOrganizationDetailsSuccess) {
                return const Center(child: Text('Something wen\'t wrong'));
              }
              final org = state.organizationDetails;
              final canManage = state.canManage;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, org, canManage),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(context, org),
                          const SizedBox(height: 16),
                          // _buildActionButtons(context, org),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              text: 'Chat with ${org.name}',
                              onPressed: () {
                                context.push(
                                  RouteConstants.initialChatPlaceholderPage,
                                  extra: {
                                    'organizationId': org.id,
                                    'userId': userId,
                                    'targetUserId':
                                        null, // no need to provide because this is related to the organization related chat
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildContactSection(context, org),
                          const SizedBox(height: 24),
                          _buildMembersSection(context, state.members, userId),
                          const SizedBox(height: 16),
                          _buildLocationSection(context, org),
                          const SizedBox(height: 16),
                          _buildMetadataSection(context, org),
                          const SizedBox(height: 40), // Bottom padding
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

  // 1. The Collapsing Header with Logo
  Widget _buildSliverAppBar(
    BuildContext context,
    Organization org,
    bool canManage,
  ) {
    return SliverAppBar(
      backgroundColor: AppColors.primaryLight,
      expandedHeight: 220.0,
      centerTitle: false,
      floating: false,
      pinned: true,
      collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
      foregroundColor: Colors.black,
      titleSpacing: 0,
      title: ShowOnCollapsedSliverAppBar(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.secondary.withAlpha(150),
              radius: 24,
              child: ClipOval(
                child: (org.logoUrl != null && org.logoUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: org.logoUrl!,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.black,
                          highlightColor: Colors.black,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported_sharp),
                      )
                    : Text(
                        org.name[0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: UiConstants.spacingSm),
            Text(
              org.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      actions: canManage
          ? [
              IconButton(
                onPressed: () {},
                icon: const Padding(
                  padding: EdgeInsets.all(UiConstants.spacingSm),
                  child: Icon(Icons.edit),
                ),
              ),
            ]
          : null,
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
          return Stack(
            children: [
              Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(UiConstants.radiusXl),
                        ),
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
              FlexibleSpaceBar(
                background: Container(
                  child: canManage
                      ? Column(
                          children: [
                            const SizedBox(height: kToolbarHeight),
                            GestureDetector(
                              onTap: () {
                                if (org.logoUrl != null &&
                                    org.logoUrl!.isNotEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrganizationImagePage(
                                            organization: org,
                                          ),
                                    ),
                                  );
                                }
                              },
                              child: SizedBox(
                                width: 200,
                                height: 200,
                                child:
                                    BlocListener<
                                      UpdateOrganizationLogoBloc,
                                      UpdateOrganizationLogoState
                                    >(
                                      listener: (context, state) {
                                        if (state
                                            is UpdateOrganizationLogoSuccess) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'organization logo updated',
                                              ),
                                              backgroundColor:
                                                  AppColors.success,
                                            ),
                                          );
                                        }
                                        if (state
                                            is UpdateOrganizationLogoError) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(state.message),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      },
                                      child: AppImagePicker(
                                        existingImageUrl: org.logoUrl,
                                        label: org.name[0].toUpperCase(),
                                        showFileName: false,
                                        borderRadius: UiConstants.radiusRound,
                                        showUploadIcon: true,
                                        showFirstNameCharacter: true,
                                        height: 200,
                                        onImagePicked: (file) {
                                          context
                                              .read<
                                                UpdateOrganizationLogoBloc
                                              >()
                                              .add(
                                                UpdateOrganizationLogoRequested(
                                                  organizationId: org.id,
                                                  newLogoFile: File(file.path),
                                                  existingLogoToDelete:
                                                      org.logoUrl,
                                                ),
                                              );
                                        },
                                        showDottedBorder: false,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            if (org.logoUrl != null &&
                                org.logoUrl!.isNotEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrganizationImagePage(organization: org),
                                ),
                              );
                            }
                          },
                          child: Center(
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary.withAlpha(150),
                              backgroundImage:
                                  (org.logoUrl != null &&
                                      org.logoUrl!.isNotEmpty)
                                  ? NetworkImage(org.logoUrl!)
                                  : null,
                              child:
                                  (org.logoUrl == null || org.logoUrl!.isEmpty)
                                  ? Text(
                                      org.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMembersSection(
    BuildContext context,
    List<User> members,
    String currentUserId,
  ) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    // Optional: group by role
    final owners = members.where((u) => u.role == UserRole.owner).toList();
    final managers = members.where((u) => u.role == UserRole.manager).toList();
    final staff = members
        .where((u) => u.role == UserRole.worker || u.role == UserRole.admin)
        .toList();

    return _SectionCard(
      title: "Team Members",
      children: [
        if (owners.isNotEmpty) ...[
          _buildRoleGroup("Owner", owners, currentUserId),
          const SizedBox(height: 16),
        ],
        if (managers.isNotEmpty) ...[
          _buildRoleGroup("Managers", managers, currentUserId),
          const SizedBox(height: 16),
        ],
        if (staff.isNotEmpty) _buildRoleGroup("Staff", staff, currentUserId),
      ],
    );
  }

  Widget _buildRoleGroup(String title, List<User> users, String currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...users.map(
          (user) => _MemberTile(user: user, currentUserId: currentUserId),
        ),
      ],
    );
  }

  // 2. Name and main details
  Widget _buildHeaderSection(BuildContext context, Organization org) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic Info', style: TextStyle(fontSize: 18)),
        const SizedBox(height: UiConstants.spacingSm),
        SectionContainer(
          padding: const EdgeInsets.all(UiConstants.spacingMd),
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                org.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (org.address != null) ...[
                const SizedBox(height: UiConstants.spacingXs),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_sharp,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        org.address!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // 4. Contact Information Card
  Widget _buildContactSection(BuildContext context, Organization org) {
    return _SectionCard(
      title: "Contact Information",
      children: [
        if (org.phone != null) ...[
          _InfoTile(
            icon: Icons.phone_outlined,
            label: "Phone",
            accentColor: const Color(0xFF10B981),
            value: org.phone!,
          ),
          const SizedBox(height: UiConstants.spacingMd),
        ],

        if (org.address != null) ...[
          _InfoTile(
            icon: Icons.location_city_outlined,
            label: "Address",
            value: org.address!,
            accentColor: const Color(0xFFEF4444),
          ),
        ],
        // Fallback if empty
        if (org.phone == null && org.address == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "No contact information provided.",
              style: TextStyle(color: Colors.black),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context, Organization org) {
    if (org.latitude == null || org.longitude == null) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: "Coordinates",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CoordinateBadge(
              label: "LAT",
              value: org.latitude!.toStringAsFixed(4),
            ),
            _CoordinateBadge(
              label: "LNG",
              value: org.longitude!.toStringAsFixed(4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, Organization org) {
    final dateStr = DateFormatter.format(org.createdAt);

    return _SectionCard(
      title: "About",
      children: [
        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: "Member Since",
          value: dateStr,
          accentColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: UiConstants.spacingSm),
        SectionContainer(
          padding: const EdgeInsets.all(UiConstants.spacingMd),
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          child: Column(children: [...children]),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoordinateBadge extends StatelessWidget {
  final String label;
  final String value;

  const _CoordinateBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[400],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monospace', // Looks technical
              color: Colors.blueGrey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final User user;
  final String currentUserId;

  const _MemberTile({required this.user, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          if (user.userId == currentUserId) {
            context.go(RouteConstants.profilePage);
          } else {
            context.push(
              RouteConstants.viewUserProfilePage,
              extra: {'userId': user.userId, 'currentUserId': currentUserId},
            );
          }
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage:
                  user.imageUrl != null && user.imageUrl!.isNotEmpty
                  ? NetworkImage(user.imageUrl!)
                  : null,
              child: user.imageUrl == null || user.imageUrl!.isEmpty
                  ? Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: const TextStyle(fontSize: 15)),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    Text(
                      user.phone!,
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.value.toUpperCase(),
                style: TextStyle(fontSize: 11, color: _getRoleColor(user.role)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Colors.purple;
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.worker:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
