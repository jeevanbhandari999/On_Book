import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (tabController.index == 0) {
              _onTabChanged(context, 0, organization.id);
            }
          });
          return Column(
            children: [
              Header(user: user, organization: organization),
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                indicator: const BoxDecoration(),
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

              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : unselectedIcon),
            Text(label),
          ],
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
        return const Center(child: CircularProgressIndicator());
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
                    'title': p.title,
                    'imageUrl': p.primaryImageUrl,
                    'videoUrl': p.videoUrl,
                    'description': p.description,
                    'price': p.price,
                    'location':
                        '0101000020E6100000DBF97E6ABC545540F2B0506B9AB73B40',
                    // to determine whether the posts is is all, video , images
                    'all': true,
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
        return const Center(child: CircularProgressIndicator());
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
                'title': post.title,
                'imageUrl': null, // Since we are only showing videos here..
                'videoUrl': vid.videoUrl,
                'description': post.description ?? '',
                'price': post.price,
                'postId': post.id,
                // to determine whether the posts is is all, video , images
                'all': false,
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
        return const Center(child: CircularProgressIndicator());
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
                'title': post.title,
                'imageUrl': img.imageUrl,
                'videoUrl': null, // Since we are only showing images here..
                'description': post.description ?? '',
                'price': post.price,
                'postId': post.id,
                // to determine whether the posts is is all, video , images
                'all': false,
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
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: UiConstants.spacingMd),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UiConstants.spacingSm),
            if (description != null)
              Text(
                description,
                style: Theme.of(context).textTheme.headlineSmall,
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
  return Semantics(
    label: title,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            image: true,
            label: 'No post icon',
            child: Icon(
              Icons.hourglass_empty,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: UiConstants.spacingMd),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: UiConstants.spacingSm),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (description != null)
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
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
  );
}
