import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/presentation/pages/post_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    return BlocProvider(
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
              //  ?? 27.986214,
              longitude: longitude,
              //  ?? 85.446681,
            ),
          ),
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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            // print(state.message);
            return Center(child: Text(state.message));
          }

          if (state is HomeLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text("No posts found"));
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.posts.length,
              itemBuilder: (_, index) {
                final post = state.posts[index];
                final organization = state.organizations[post.organizationId];
                if (organization == null) {
                  context.read<HomeBloc>().add(
                    FetchOrganizationDetails(post.organizationId),
                  );

                  return const Center(child: CircularProgressIndicator());
                }
                return _buildImagePageView(context, post, organization, userId);
              },
              pageSnapping: false,
              physics: const BouncingScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

Widget _buildImagePageView(
  BuildContext context,
  Post post,
  Organization organization,
  String userId,
) {
  return SizedBox.expand(
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          // top: 0,
          // left: 0,
          // right: 0,
          // bottom: 280,
          child: GestureDetector(
            onTap: () {
              context.push(
                RouteConstants.postDetailsPage,
                extra: {
                  'postId': post.id,
                  'post': post,
                  'userId': post.createdBy,
                },
              );
            },
            child: CachedNetworkImage(
              imageUrl: post.primaryImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error)),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Organization logo
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.blueAccent.shade100,
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
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          organization.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          organization.address ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                // Just show the menu icon for now
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  elevation: 3,
                  onSelected: (value) {
                    // handle selection
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'message',
                      child: Row(
                        children: [
                          Icon(Icons.chat, size: UiConstants.iconMd),
                          const SizedBox(width: UiConstants.spacingSm),
                          const Text('Message'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'vire_details',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: UiConstants.iconMd),
                          const SizedBox(width: UiConstants.spacingSm),
                          Text('Details'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (post.additionalImagesForHomeFeed.isNotEmpty)
          Positioned(
            bottom: 140,
            right: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 8.0),
              color: Colors.black54,
              child: _buildImageStrip(post),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleAndPriceSection(
                      context,
                      title: post.title,
                      price: post.price!,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getPostStatusColor(post.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        enumToString(post.status).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildDescriptionSection(
                  context,
                  description: post.description!,
                  isExpanded: true,
                  onToggleExpand: () {
                    // context.read<PostDetailsBloc>().add(
                    //   PostDetailToggleDescriptionRequested(
                    //     isDescriptionToggled: stateLoaded.isDescriptionExpanded,
                    //   ),
                    // );
                  },
                ),
                const SizedBox(height: UiConstants.spacingSm),
                _buildActionButtons(context, post: post, userId: userId),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

String _getInitialCharactrOfOrganization(String name) {
  return name
      .trim()
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .join();
}

Widget _buildImageStrip(Post post) {
  final images = post.additionalImagesForHomeFeed;

  return SizedBox(
    width: double.infinity,
    height: 120,
    child: ListView.separated(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showImagePreviewDialog(context, images[index]),
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: images[index],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemCount: images.length,
      scrollDirection: Axis.horizontal,
    ),
  );
}

void _showImagePreviewDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _showMoreOptions(BuildContext context) {
  return PopupMenuButton<String>(
    elevation: 3,
    onSelected: (value) {},
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: UiConstants.iconMd),
            SizedBox(width: UiConstants.spacingSm),
            Text('Edit'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: UiConstants.iconMd, color: Colors.red),
            SizedBox(width: UiConstants.spacingSm),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ],
  );
}

Widget _buildTitleAndPriceSection(
  BuildContext context, {
  required String title,
  required double price,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Rs.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          Text(
            '$price',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildDescriptionSection(
  BuildContext context, {
  required String description,
  required bool isExpanded,
  required VoidCallback onToggleExpand,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final textStyle = const TextStyle(color: Colors.white);
      final span = TextSpan(text: description, style: textStyle);

      final textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '...',
      )..layout(maxWidth: constraints.maxWidth);

      final bool textExceedsThreeLines = textPainter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpanded || !textExceedsThreeLines)
            Text(description, style: textStyle, textAlign: TextAlign.justify)
          else
            Stack(
              children: [
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                  textAlign: TextAlign.justify,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onToggleExpand,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        isExpanded ? 'View Less' : 'View More',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Show "View Less" when expanded and text was long
          if (isExpanded && textExceedsThreeLines)
            GestureDetector(
              onTap: onToggleExpand,
              child: Text(
                'View Less',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    },
  );
}

Widget _buildActionButtons(
  BuildContext context, {
  required String userId,
  required Post post,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Expanded(
        child: CustomButton(
          text: 'Add to Library',
          textColor: Colors.white,
          icon: const Icon(Icons.bookmark_outline, color: Colors.white),
          onPressed: () {},
          isOutlined: true,
        ),
      ),
      const SizedBox(width: UiConstants.spacingSm),
      Expanded(
        child: CustomButton(
          text: 'Book Now',
          onPressed: () {
            context.push(
              RouteConstants.bookingFormPage,
              extra: {'userId': userId, 'postId': post.id, 'post': post},
            );
          },
          icon: const Icon(Icons.event_available),
        ),
      ),
    ],
  );
}
