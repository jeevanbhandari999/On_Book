import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/auto_marquee_text.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/home/domain/usecases/get_all_post_recommended_by_content_filter_use_case.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/home/domain/usecases/get_organization_list_based_on_global_score_use_case.dart';
import 'package:app/features/home/presentation/bloc/get_organization_list_based_on_global_score_bloc.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:app/features/home/presentation/widgets/animated_app_icon.dart';
import 'package:app/features/home/presentation/widgets/home_shimmer.dart';
import 'package:app/features/home/presentation/widgets/home_sliver_header.dart';
import 'package:app/features/home/presentation/widgets/post_card.dart';
import 'package:app/features/home/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
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
          create: (context) =>
              HomeBloc(
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
                )
                // ..add(
                //   FetchNearbyPosts(
                //     userId: userId,
                //     latitude: 37.421998,
                //     longitude: -122.084000,
                //   ),
                // ),
                ..add(
                  FetchNearByAndContentBasedFilteringPosts(
                    userId: userId,
                    // latitude: 37.421998,
                    // longitude: -122.084000,
                  ),
                ),
        ),
        BlocProvider(
          create: (context) => GetOrganizationListBasedOnGlobalScoreBloc(
            getOrganizationListBasedOnGlobalScoreUseCase:
                DependencyInjection.get<
                  GetOrganizationListBasedOnGlobalScoreUseCase
                >(),
          )..add(const GetOrganizationListBasedOnGlobalScoreRequested()),
        ),
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(RefreshNearbyPosts(userId: userId));
          // context.read<HomeBloc>().add(
          //   FetchNearByAndContentBasedFilteringPosts(
          //     userId: userId,
          //     // latitude: 37.421998,
          //     // longitude: -122.084000,
          //   ),
          // );
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
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    expandedHeight: 200,
                    centerTitle: true,
                    collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
                    // leading: Padding(
                    //   padding: const EdgeInsets.all(UiConstants.spacingSm),
                    //   child: ClipOval(
                    //     child:
                    //         Container(
                    //               decoration: BoxDecoration(
                    //                 border: Border.all(
                    //                   color: Colors.white,
                    //                   width: 1.5,
                    //                 ),
                    //                 color: Colors.transparent,
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                     color: Colors.black.withAlpha(80),
                    //                     blurRadius: 4,
                    //                     offset: const Offset(0, 2),
                    //                   ),
                    //                 ],
                    //               ),
                    //               child: const CustomSvgIcon(
                    //                 path: AppImages.appIconTransparentSvg,
                    //               ),
                    //             )
                    //             .animate(onPlay: (c) => c.repeat(reverse: true))
                    //             .scaleXY(
                    //               begin: 1.0,
                    //               end: 1.06,
                    //               duration: 1800.ms,
                    //               curve: Curves.easeInOut,
                    //             )
                    //             .shimmer(
                    //               delay: 400.ms,
                    //               duration: 1800.ms,
                    //               color: Colors.white.withOpacity(0.15),
                    //               angle: 0.5,
                    //             ),
                    //   ),
                    // ),
                    leading: const AnimatedAppIcon(),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chat_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.push(
                            RouteConstants.chatUserListPage,
                            extra: userId,
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
                            if (state is GetCurrentUserProfileDetailsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            }

                            if (state is GetCurrentUserProfileDetailsError) {
                              return const SizedBox.shrink();
                            }

                            if (state is GetCurrentUserProfileDetailsSuccess) {
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
                                                      baseColor:
                                                          Colors.grey.shade300,
                                                      highlightColor:
                                                          Colors.grey.shade100,
                                                      child: Container(
                                                        color: Colors.white,
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
                                                user.fullName[0],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          if (userEmail != null &&
                                              userEmail.isNotEmpty)
                                            AutoMarqueeText(
                                              text: userEmail,
                                              style: const TextStyle(
                                                color: Colors.white,
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
                                  color: Theme.of(context).colorScheme.primary,
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
                        const FlexibleSpaceBar(background: HomeSliverHeader()),
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

                              final int displayCount = organizations.length >= 8
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
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
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
    );
  }

  Widget _shimmerCircle() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: const CircleAvatar(radius: 28),
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
          RouteConstants.initialChatPlaceholderPage,
          extra: {
            'organizationId': org.id,
            'userId': userId,
            'targetUserId':
                null, // no need to provide because this is related to the organization related chat
          },
        );
        // context.push(
        //   RouteConstants.contacts,
        //   extra: {'orgId': org.id, 'userId': userId},
        // );
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
                            color: Colors.white,
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
