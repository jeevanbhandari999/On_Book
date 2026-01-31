import 'dart:ui';

import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/home/domain/usecases/get_organization_list_based_on_global_score_use_case.dart';
import 'package:app/features/home/presentation/bloc/get_organization_list_based_on_global_score_bloc.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
              )..add(
                FetchNearbyPosts(
                  userId: userId,
                  latitude: latitude,
                  longitude: longitude,
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
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
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
                          context.push(RouteConstants.chatUserListPage);
                        },
                      ),
                    ],
                    flexibleSpace: Stack(
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
                        ),
                        const FlexibleSpaceBar(
                          titlePadding: EdgeInsets.only(left: 16, bottom: 12),
                          title: HomeProfileHeader(),
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
                            // 🔄 LOADING
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

                  /// POSTS GRID
                  // SliverPadding(
                  //   padding: const EdgeInsets.all(UiConstants.spacingMd),
                  //   sliver: SliverGrid(
                  //     delegate: SliverChildBuilderDelegate((context, index) {
                  //       final post = state.posts[index];
                  //       final organization =
                  //           state.organizations[post.organizationId];

                  //       if (organization == null) {
                  //         context.read<HomeBloc>().add(
                  //           FetchOrganizationDetails(post.organizationId),
                  //         );
                  //         return const Center(
                  //           child: CircularProgressIndicator(),
                  //         );
                  //       }

                  //       return PostGridCard(
                  //         post: post,
                  //         organization: organization,
                  //         userId: userId,
                  //       );
                  //     }, childCount: state.posts.length),
                  //     gridDelegate:
                  //         const SliverGridDelegateWithFixedCrossAxisCount(
                  //           crossAxisCount: 2,
                  //           mainAxisSpacing: UiConstants.spacingSm,
                  //           crossAxisSpacing: UiConstants.spacingSm,
                  //         ),
                  //   ),
                  // ),
                  SliverPadding(
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: UiConstants.spacingSm,
                      crossAxisSpacing: UiConstants.spacingSm,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
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
                        );
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
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: org.logoUrl != null && org.logoUrl!.isNotEmpty
              ? NetworkImage(org.logoUrl!)
              : null,
          child: (org.logoUrl == null || org.logoUrl!.isEmpty)
              ? Text(
                  org.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          org.name,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Profile header
class HomeProfileHeader extends StatelessWidget {
  const HomeProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GetCurrentUserProfileDetailsBloc,
      GetCurrentUserProfileDetailsState
    >(
      builder: (context, state) {
        if (state is GetCurrentUserProfileDetailsLoading) {
          return const SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (state is GetCurrentUserProfileDetailsError) {
          return const Text(
            'Welcome',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }

        if (state is GetCurrentUserProfileDetailsSuccess) {
          final user = state.user;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                user.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class HomeSliverHeader extends StatelessWidget {
  const HomeSliverHeader({super.key});

  static const double _expandedHeight = 200;
  static const double _collapsedHeight = kToolbarHeight + 20;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.biggest.height;
        final isCollapsed = top <= _collapsedHeight + 10;

        return BlocBuilder<
          GetCurrentUserProfileDetailsBloc,
          GetCurrentUserProfileDetailsState
        >(
          builder: (context, state) {
            if (state is GetCurrentUserProfileDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            if (state is GetCurrentUserProfileDetailsError) {
              return const SizedBox.shrink();
            }

            if (state is GetCurrentUserProfileDetailsSuccess) {
              final user = state.user;

              return Stack(
                fit: StackFit.expand,
                children: [
                  /// Background
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(UiConstants.radiusXl),
                      ),
                    ),
                  ),

                  /// App Logo (always top-left)
                  Positioned(
                    left: 16,
                    top: MediaQuery.of(context).padding.top + 8,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.flutter_dash, color: Colors.blue),
                    ),
                  ),

                  /// Expanded content
                  AnimatedOpacity(
                    opacity: isCollapsed ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.role.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Collapsed center content
                  AnimatedOpacity(
                    opacity: isCollapsed ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Text(
                              user.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final Organization organization;
  final String userId;

  const PostCard({
    super.key,
    required this.post,
    required this.organization,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final double baseHeight = 200;
    final double heightVariation = (post.title.length % 5) * 40.0;
    final double cardHeight = baseHeight + heightVariation;
    final double maxHeight = MediaQuery.of(context).size.height * 0.55;

    final theme = Theme.of(context);
    final isAvailable = post.status == PostStatus.available;

    const double rating = 4.8;
    const int reviewCount = 12;
    // print(cardHeight);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(
            RouteConstants.postDetailsPage,
            extra: {'postId': post.id, 'post': post, 'userId': userId},
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: cardHeight < maxHeight ? cardHeight : maxHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: post.primaryImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.9)
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(
                            UiConstants.radiusRound,
                          ),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Booked',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () {
                          // Handle favorite / saved
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusRound,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite_border_outlined,
                            size: UiConstants.iconSm,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            color: Colors.white.withAlpha(100), // tint
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '$rating',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                '($reviewCount)',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 18,
                                      child:
                                          (organization.logoUrl != null &&
                                              organization.logoUrl!.isNotEmpty)
                                          ? Image.network(
                                              organization.logoUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : Center(
                                              child: Text(
                                                _getInitialCharactrOfOrganization(
                                                  organization.name,
                                                ),
                                                style: const TextStyle(
                                                  // fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  'Rs. ${post.price!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: UiConstants.buttonHeightSm,
                child: CustomButton(
                  text: isAvailable ? 'Book Now' : 'Booked',
                  onPressed: isAvailable
                      ? () {
                          context.push(
                            RouteConstants.bookingFormPage,
                            extra: {
                              'userId': userId,
                              'postId': post.id,
                              'post': post,
                            },
                          );
                        }
                      : null,
                ),
              ),
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
