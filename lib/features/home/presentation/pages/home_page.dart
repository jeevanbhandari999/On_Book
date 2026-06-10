import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';

import 'package:app/core/widgets/auto_marquee_text.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/home/domain/usecases/get_all_post_recommended_by_content_filter_use_case.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/home/domain/usecases/get_organization_list_based_on_global_score_use_case.dart';
import 'package:app/features/home/presentation/bloc/get_organization_list_based_on_global_score_bloc.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:app/features/home/presentation/cubit/location_cubit.dart';
import 'package:app/features/home/presentation/widgets/animated_app_icon.dart';
import 'package:app/features/home/presentation/widgets/home_shimmer.dart';
import 'package:app/features/home/presentation/widgets/home_sliver_header.dart';
import 'package:app/features/home/presentation/widgets/post_card.dart';
import 'package:app/features/home/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final double? latitude;
  final double? longitude;

  const HomePage({
    super.key,
    required this.userId,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetCurrentUserProfileDetailsBloc(
            getCurrentUserProfileUseCase:
                DependencyInjection.get<GetCurrentUserProfileUseCase>(),
          )..add(GetCurrentUserProfileDetailsRequested(userId: userId)),
        ),
        BlocProvider(
          create: (context) => HomeBloc(
            getNearbyPostsUseCase:
                DependencyInjection.get<GetAllPostsNearByUserUseCase>(),
            getOrganizationDetailByPostOrganizationIdUseCase:
                DependencyInjection.get<
                  GetOrganizationDetailByPostOrganizationIdUseCase
                >(),
            getAllPostRecommendedByContentFilterUseCase:
                DependencyInjection.get<
                  GetAllPostRecommendedByContentFilterUseCase
                >(),
          )..add(FetchNearByAndContentBasedFilteringPosts(userId: userId)),
        ),
        BlocProvider(
          create: (context) => GetOrganizationListBasedOnGlobalScoreBloc(
            getOrganizationListBasedOnGlobalScoreUseCase:
                DependencyInjection.get<
                  GetOrganizationListBasedOnGlobalScoreUseCase
                >(),
          )..add(const GetOrganizationListBasedOnGlobalScoreRequested()),
        ),
        BlocProvider(create: (context) => LocationCubit()..checkShouldPrompt()),
      ],
      child: HomeView(userId: userId),
    );
  }
}

class HomeView extends StatelessWidget {
  final String userId;
  const HomeView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationState>(
      listener: (context, state) {
        if (state is LocationShouldPrompt) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLocationSheet(context);
          });
        }

        if (state is LocationGranted) {
          context.read<HomeBloc>().add(
            FetchNearByAndContentBasedFilteringPosts(
              userId: userId,
              latitude: state.latitude,
              longitude: state.longitude,
            ),
          );
        }
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            final locationState = context.read<LocationCubit>().state;
            double? lat;
            double? lng;

            if (locationState is LocationGranted) {
              lat = locationState.latitude;
              lng = locationState.longitude;
            }

            context.read<HomeBloc>().add(
              RefreshNearbyPosts(userId: userId, latitude: lat, longitude: lng),
            );
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const HomeShimmer();
              }
              if (state is HomeError) {
                // print(state.message);
                return Center(child: Text(state.message));
              }

              if (state is HomeLoaded) {
                return CustomScrollView(
                  slivers: [
                    /// APP BAR
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: AppColors.primaryLight,
                      elevation: 0,
                      expandedHeight: 215,
                      centerTitle: true,
                      collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
                      leading: const AnimatedAppIcon(),
                      actions: [
                        BlocBuilder<NotificationCubit, NotificationCubitState>(
                          builder: (context, state) {
                            final unreadCount = state is NotificationCubitLoaded
                                ? state.notifications
                                      .where((n) => n.isUnread)
                                      .length
                                : 0;

                            return IconButton(
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.black,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Center(
                                          child: Text(
                                            unreadCount > 99
                                                ? '99+'
                                                : '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              height: 1.1,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: () {
                                context.push(
                                  RouteConstants.notificationsPage,
                                  extra: userId,
                                );
                              },
                            );
                          },
                        ),
                        BlocBuilder<NotificationCubit, NotificationCubitState>(
                          builder: (context, state) {
                            final unReadChatCount =
                                state is NotificationCubitLoaded
                                ? state.notifications
                                      .where(
                                        (n) =>
                                            n.type ==
                                                    NotificationType
                                                        .chatMessage &&
                                                n.isUnread ||
                                            n.isViewed,
                                      )
                                      .map((n) => n.referenceId)
                                      .toSet()
                                      .length
                                : 0;
                            return IconButton(
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.chat_outlined,
                                    color: Colors.black,
                                  ),
                                  if (unReadChatCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Center(
                                          child: Text(
                                            unReadChatCount > 99
                                                ? '99+'
                                                : '$unReadChatCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              height: 1.1,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: () {
                                context.push(
                                  RouteConstants.chatUserListPage,
                                  extra: userId,
                                );
                              },
                            );
                          },
                        ),
                      ],
                      title:
                          BlocBuilder<
                            GetCurrentUserProfileDetailsBloc,
                            GetCurrentUserProfileDetailsState
                          >(
                            builder: (context, state) {
                              if (state
                                  is GetCurrentUserProfileDetailsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              if (state is GetCurrentUserProfileDetailsError) {
                                return const SizedBox.shrink();
                              }

                              if (state
                                  is GetCurrentUserProfileDetailsSuccess) {
                                final user = state.user;
                                final authService =
                                    DependencyInjection.get<AuthService>();

                                final userEmail = authService
                                    .getCurrentUserEmail();

                                return ShowOnCollapsedSliverAppBar(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.secondary.withAlpha(150),
                                        radius: 16,
                                        child: ClipOval(
                                          child:
                                              user.imageUrl != null &&
                                                  user.imageUrl!.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: user.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  width: 48,
                                                  height: 48,
                                                  placeholder: (context, url) =>
                                                      Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey
                                                            .shade300,
                                                        highlightColor: Colors
                                                            .grey
                                                            .shade100,
                                                        child: Container(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => CachedNetworkImage(
                                                        imageUrl:
                                                            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
                                                      ),
                                                )
                                              : Text(
                                                  user.fullName[0]
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                        ),
                                      ).animate().scale(
                                        duration: UiConstants.animationNormal,
                                      ),
                                      const SizedBox(
                                        width: UiConstants.spacingSm,
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            AutoMarqueeText(
                                              text: user.fullName,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            if (userEmail != null &&
                                                userEmail.isNotEmpty)
                                              AutoMarqueeText(
                                                text: userEmail,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(
                                        UiConstants.radiusXl,
                                      ),
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
                          const FlexibleSpaceBar(
                            background: HomeSliverHeader(),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child:
                          BlocBuilder<
                            GetOrganizationListBasedOnGlobalScoreBloc,
                            GetOrganizationListBasedOnGlobalScoreState
                          >(
                            builder: (context, state) {
                              if (state
                                  is GetOrganizationListBasedOnGlobalScoreLoading) {
                                return SizedBox(
                                  height: 100,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: UiConstants.spacingMd,
                                      vertical: UiConstants.spacingSm,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 8,
                                    separatorBuilder: (_, __) => const SizedBox(
                                      width: UiConstants.spacingMd,
                                    ),
                                    itemBuilder: (context, index) =>
                                        _shimmerCircle(),
                                  ),
                                );
                              }
                              if (state
                                  is GetOrganizationListBasedOnGlobalScoreError) {
                                return Center(child: Text(state.message));
                              }
                              if (state
                                  is GetOrganizationListBasedOnGlobalScoreSuccess) {
                                final organizations = state.organizations;

                                final int displayCount =
                                    organizations.length >= 8
                                    ? organizations.length
                                    : 8;

                                return SizedBox(
                                  height: 100,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: UiConstants.spacingMd,
                                      vertical: UiConstants.spacingSm,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: displayCount,
                                    separatorBuilder: (_, __) => const SizedBox(
                                      width: UiConstants.spacingMd,
                                    ),
                                    itemBuilder: (context, index) {
                                      if (index < organizations.length) {
                                        return _orgItem(
                                          context,
                                          organizations[index],
                                        );
                                      } else {
                                        // shimmer filler if less than 8 orgs
                                        return _shimmerCircle();
                                      }
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiConstants.spacingMd,
                      ),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: UiConstants.spacingSm,
                        crossAxisSpacing: UiConstants.spacingSm,
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          // print(state.posts[index].title);

                          final organization =
                              state.organizations[post.organizationId];
                          if (organization == null) {
                            context.read<HomeBloc>().add(
                              FetchOrganizationDetails(post.organizationId),
                            );
                            return const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          return PostCard(
                                post: post,
                                organization: organization,
                                userId: userId,
                              )
                              .animate(delay: (index * 80).ms)
                              .slideX(
                                begin: index.isEven ? -0.3 : 0.3,
                                duration: UiConstants.animationSlow,
                                curve: Curves.easeOutCubic,
                              )
                              .scale(
                                begin: const Offset(0.9, 1),
                                duration: UiConstants.animationSlow,
                                curve: Curves.easeInOut,
                              )
                              .fade(duration: UiConstants.animationSlow);
                        },
                        childCount: state.posts.length,
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      builder: (_) => BlocProvider.value(
        value: context.read<LocationCubit>(),
        child: const _LocationPermissionSheet(),
      ),
    ).then((_) {
      // If dismissed without action, treat as denied for session
      final state = context.read<LocationCubit>().state;
      if (state is LocationShouldPrompt) {
        context.read<LocationCubit>().dismiss();
      }
    });
  }

  Widget _shimmerCircle() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: const CircleAvatar(backgroundColor: Colors.white, radius: 28),
        ),
        const SizedBox(height: 6),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 10,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _orgItem(BuildContext context, Organization org) {
    return InkWell(
      onTap: () {
        context.push(
          RouteConstants.organizationDetailsPageUserSide,
          extra: {'organizationId': org.id, 'userId': userId},
        );
      },
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage:
                      org.logoUrl != null && org.logoUrl!.isNotEmpty
                      ? NetworkImage(org.logoUrl!)
                      : null,
                  child: (org.logoUrl == null || org.logoUrl!.isEmpty)
                      ? Text(
                          _getInitialCharactrOfOrganization(org.name),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                )
                .animate(delay: UiConstants.animationFast)
                .scale(duration: UiConstants.animationNormal),
            AutoMarqueeText(
              text: org.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
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

class _LocationPermissionSheet extends StatelessWidget {
  const _LocationPermissionSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Allow Location Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We use your location to show nearby places and personalize your experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              final isLoading = state is LocationLoading;
              return Column(
                children: [
                  // Allow button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              await context
                                  .read<LocationCubit>()
                                  .requestLocation();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Allow Location',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Deny button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<LocationCubit>().dismiss();
                              Navigator.of(context).pop();
                            },
                      child: Text(
                        'Not Now',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
