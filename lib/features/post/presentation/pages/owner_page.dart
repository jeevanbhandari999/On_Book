import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_by_organization_id_use_case.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_images_by_orgnization_id.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_videos_by_organization_id.dart';
import 'package:app/features/post/presentation/bloc/posts_bloc.dart';
import 'package:app/features/post/presentation/widgets/header.dart';
import 'package:app/features/post/presentation/widgets/post_grid_section.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class OwnerPage extends StatelessWidget {
  final UserModel user;
  final OrganizationModel organization;
  const OwnerPage({super.key, required this.user, required this.organization});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizationPostsBloc(
        getAllPostsByOrganizationId:
            DependencyInjection.get<GetAllPostsByOrganizationIdUseCase>(),
        getAllPostsWithImagesByOrganizationId:
            DependencyInjection.get<
              GetAllPostsWithImagesByOrganizationIdUseCase
            >(),
        getAllPostsWithVideosByOrganizationId:
            DependencyInjection.get<GetAllPostsWithVideosByOrganizationId>(),
        postServices: DependencyInjection.get<PostServices>(),
      )..add(FetchOrganizationPosts(organizationId: organization.id)),
      child: OwnerView(user: user, organization: organization),
    );
  }
}

class OwnerView extends StatelessWidget {
  final UserModel user;
  final OrganizationModel organization;
  const OwnerView({super.key, required this.user, required this.organization});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          // Listen to tab changes
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              _onTabChanged(context, tabController.index, organization.id);
            }
          });

          return Column(
            children: [
              Header(user: user, organization: organization),
              Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(
                      UiConstants.spacingMd,
                      0,
                      UiConstants.spacingMd,
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(75),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.black,
                      unselectedLabelColor: Colors.black,
                      dividerColor: Colors.transparent,
                      tabs: [
                        _buildTab(
                          context,
                          index: 0,
                          selectedIcon: Icons.grid_view_rounded,
                          unselectedIcon: Icons.grid_view_outlined,
                          label: 'All Posts',
                        ),
                        _buildTab(
                          context,
                          index: 1,
                          selectedIcon: Icons.movie,
                          unselectedIcon: Icons.movie_outlined,
                          label: 'Videos',
                        ),
                        _buildTab(
                          context,
                          index: 2,
                          selectedIcon: Icons.photo_library,
                          unselectedIcon: Icons.photo_library_outlined,
                          label: 'Images',
                        ),
                      ],
                    ),
                  )
                  .animate(delay: UiConstants.animationDelayFaster)
                  .scale(
                    duration: UiConstants.animationDelayFast,
                    curve: Curves.easeOut,
                  ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildPostsList(context, user, organization),
                    _buildPostVideos(context, user, organization),
                    _buildPostImages(context, user, organization),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildTab(
  BuildContext context, {
  required int index,
  required IconData selectedIcon,
  required IconData unselectedIcon,
  required String label,
}) {
  return AnimatedBuilder(
    animation: DefaultTabController.of(context),
    builder: (context, child) {
      final isSelected = DefaultTabController.of(context).index == index;
      return Tab(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                size: UiConstants.iconSm,
              ),
              const SizedBox(width: UiConstants.spacingSm),
              Text(label),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildPostsList(
  BuildContext context,
  UserModel user,
  OrganizationModel organization,
) {
  return BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
    builder: (context, state) {
      if (state is OrganizationPostsLoading) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: UiConstants.spacingSm,
            crossAxisSpacing: UiConstants.spacingSm,
            children: List.generate(10, (index) {
              final height = index.isEven ? 200.0 : 260.0;
              return StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: _buildPostCardShimmer(height),
              );
            }),
          ),
        );
      } else if (state is OrganizationPostsLoaded) {
        final posts = state.posts.toList();

        if (posts.isEmpty) {
          return _buildEmptyState(
            context,
            title: 'No Posts Found',
            canManageOrganization:
                user.role == UserRole.admin ||
                user.role == UserRole.owner ||
                user.role == UserRole.manager,
            content:
                user.role == UserRole.admin ||
                    user.role == UserRole.owner ||
                    user.role == UserRole.manager
                ? 'Create Your first post to get started.'
                : 'Come back later to check the upcomig posts.',
            userId: user.userId,
            organizationId: organization.id,
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: PostGridSection(
            posts: state.posts
                .map(
                  (p) => {
                    'post': p,
                    'userId': user.userId,
                    'title': p.title,
                    'postId': p.id,
                    'imageUrl': p.primaryImageUrl,
                    'videoUrl': p.videoUrl,
                    'description': p.description,
                    'price': p.price,
                    'longitude': p.longitude,
                    'latitude': p.latitude,
                    // to determine whether the posts is is all, video , images
                    'posts': true,
                    'videos': false,
                    'images': false,
                  },
                )
                .toList(),
          ),
        );
      } else if (state is OrganizationPostsError) {
        return _buildErrorState(context, message: 'Failed to fetch the posts.');
      }
      return const SizedBox.shrink();
    },
  );
}

Widget _buildPostVideos(
  BuildContext context,
  UserModel user,
  OrganizationModel organization,
) {
  return BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
    builder: (context, state) {
      if (state is OrganizationPostsLoading) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: UiConstants.spacingSm,
            crossAxisSpacing: UiConstants.spacingSm,
            children: List.generate(10, (index) {
              final height = index.isEven ? 200.0 : 260.0;
              return StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: _buildPostCardShimmer(height),
              );
            }),
          ),
        );
      } else if (state is OrganizationPostsVideosLoaded) {
        final postsWithImages = state.postVideos;
        final postsOnly = state.posts;

        if (postsWithImages.isEmpty) {
          return _buildEmptyState(
            context,
            title: 'No Posts Found',
            canManageOrganization:
                user.role == UserRole.admin ||
                user.role == UserRole.owner ||
                user.role == UserRole.manager,
            description:
                'You haven\'t create any posts yet, try to add some posts and check it out.',
            content:
                user.role == UserRole.admin ||
                    user.role == UserRole.owner ||
                    user.role == UserRole.manager
                ? 'Create Your first post to get started.'
                : 'Come back later to check the upcomig posts.',
            userId: user.userId,
            organizationId: organization.id,
          );
        }

        // Create map: postId → full Post
        final postMap = {for (var post in postsOnly) post.id: post};

        // Flatten: one card per image, with full post data
        final cardItems = postsWithImages
            .map((vid) {
              final post = postMap[vid.postId];
              if (post == null) return null; // safety

              return {
                'post': post,
                'title': post.title,
                'imageUrl': null, // Since we are only showing videos here..
                'videoUrl': vid.videoUrl,
                'description': post.description ?? '',
                'price': post.price,
                'postId': post.id,
                'longitude': post.longitude,
                'latitude': post.latitude,
                // to determine whether the posts is is all, video , images
                'posts': false,
                'videos': true,
                'images': false,
                'userId': user.userId,
              };
            })
            .whereType<Map<String, dynamic>>()
            .toList();

        if (cardItems.isEmpty) {
          return _buildEmptyState(
            context,
            title: 'No Posts Found',
            canManageOrganization:
                user.role == UserRole.admin ||
                user.role == UserRole.owner ||
                user.role == UserRole.manager,
            description:
                'You haven\'t create any posts yet, try to add some posts and check it out.',
            content:
                user.role == UserRole.admin ||
                    user.role == UserRole.owner ||
                    user.role == UserRole.manager
                ? 'Create Your first post to get started.'
                : 'Come back later to check the upcomig posts.',
            userId: user.userId,
            organizationId: organization.id,
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: PostGridSection(posts: cardItems),
        );
      } else if (state is OrganizationPostsError) {
        return _buildErrorState(
          context,
          message: 'Failed to fetch the posts videos.',
        );
      }
      return const SizedBox.shrink();
    },
  );
}

Widget _buildPostImages(
  BuildContext context,
  UserModel user,
  OrganizationModel organization,
) {
  return BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
    builder: (context, state) {
      // print(state);
      if (state is OrganizationPostsLoading) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: UiConstants.spacingSm,
            crossAxisSpacing: UiConstants.spacingSm,
            children: List.generate(10, (index) {
              final height = index.isEven ? 200.0 : 260.0;
              return StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: _buildPostCardShimmer(height),
              );
            }),
          ),
        );
      } else if (state is OrganizationPostsImagesLoaded) {
        final postsWithImages = state.postImages;
        final postsOnly = state.posts;

        if (postsWithImages.isEmpty) {
          return _buildEmptyState(
            context,
            title: 'No Posts Found',
            canManageOrganization:
                user.role == UserRole.admin ||
                user.role == UserRole.owner ||
                user.role == UserRole.manager,
            description:
                'You haven\'t create any posts yet, try to add some posts and check it out.',
            content:
                user.role == UserRole.admin ||
                    user.role == UserRole.owner ||
                    user.role == UserRole.manager
                ? 'Create Your first post to get started.'
                : 'Come back later to check the upcomig posts.',
            userId: user.userId,
            organizationId: organization.id,
          );
        }

        // Create map: postId → full Post
        final postMap = {for (var post in postsOnly) post.id: post};

        // Flatten: one card per image, with full post data
        final cardItems = postsWithImages
            .map((img) {
              final post = postMap[img.postId];
              if (post == null) return null; // safety

              return {
                'post': post,
                'title': post.title,
                'imageUrl': img.imageUrl,
                'videoUrl': null, // Since we are only showing images here..
                'description': post.description ?? '',
                'price': post.price,
                'postId': post.id,
                'longitude': post.longitude,
                'latitude': post.latitude,
                // to determine whether the posts is is all, video , images
                'posts': false,
                'videos': false,
                'images': true,
                'userId': user.userId,
              };
            })
            .whereType<Map<String, dynamic>>()
            .toList();

        if (cardItems.isEmpty) {
          return const Center(child: Text('No valid posts with images.'));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: PostGridSection(posts: cardItems),
        );
      } else if (state is OrganizationPostsError) {
        return _buildErrorState(
          context,
          message: 'Failed to fetch the posts images.',
        );
      }
      return const SizedBox.shrink();
    },
  );
}

Widget _buildPostCardShimmer(double height) {
  final baseColor = Colors.grey[300]!;
  final highlightColor = Colors.grey[100]!;
  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(UiConstants.radiusMd),
                ),
              ),
            ),
          ),
          // Content Placeholder
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorState(
  BuildContext context, {
  required String message,
  String? description,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Semantics(
      label: message,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: 'Error icon',
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (description != null)
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: UiConstants.spacingSm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UiConstants.spacingLg),
            Semantics(
              label: 'Try again',
              hint: message,
              button: true,
              child: CustomButton(
                text: 'Try Again',
                onPressed: () => _onRefresh(context),
                icon: const Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _onRefresh(BuildContext context) {}

void _onTabChanged(BuildContext context, int index, String organizationId) {
  final bloc = context.read<OrganizationPostsBloc>();
  switch (index) {
    case 0:
      bloc.add(FetchOrganizationPosts(organizationId: organizationId));
      break;
    case 1:
      bloc.add(
        FetchOrganizationPostsWithVideos(organizationId: organizationId),
      );
      break;
    case 2:
      bloc.add(
        FetchOrganizationPostsWithImages(organizationId: organizationId),
      );
      break;
  }
}

Widget _buildEmptyState(
  BuildContext context, {
  required String title,
  required bool canManageOrganization,
  required String content,
  String? description,
  String? userId,
  String? organizationId,
}) {
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingLg),
    child: Semantics(
      label: title,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: 'No post icon',
              child:
                  Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.hourglass_empty,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 600.ms),
            ),
            const SizedBox(height: UiConstants.spacingSm),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: UiConstants.spacingSm),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn().moveY(begin: 20, end: 0),
            if (description != null)
              Text(
                description,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn().moveY(begin: 20, end: 0),
            if (canManageOrganization) ...[
              const SizedBox(height: UiConstants.spacingLg),
              CustomButton(
                text: 'Create Post',
                onPressed: () {
                  context.push(
                    RouteConstants.createPostPage,
                    extra: {'userId': userId, 'organizationId': organizationId},
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
