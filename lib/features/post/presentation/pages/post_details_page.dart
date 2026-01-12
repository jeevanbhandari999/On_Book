import 'package:app/app/app_config.dart';
import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/usecases/delete_post_use_case.dart';
import 'package:app/features/post/domain/usecases/get_post_by_id_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_details_bloc.dart';
import 'package:app/features/post/presentation/widgets/detail_info_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:url_launcher/url_launcher.dart';

class PostDetailsPage extends StatelessWidget {
  final String postId;
  final Post? post;
  final String? userId;
  const PostDetailsPage({
    super.key,
    required this.postId,
    this.post,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailsBloc>(
      create: (context) {
        return PostDetailsBloc(
          getPostByIdUseCase: DependencyInjection.get<GetPostByIdUseCase>(),
          deletePostUseCase: DependencyInjection.get<DeletePostUseCase>(),
        )..add(PostDetailLoadRequested(postId: postId, userId: userId));
      },
      child: PostDetailsView(postId: postId, post: post, userId: userId),
    );
  }
}

class PostDetailsView extends StatelessWidget {
  final String postId;
  final Post? post;
  final String? userId;
  const PostDetailsView({
    super.key,
    required this.postId,
    this.post,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post?.title ?? 'Details Page'),
        actions: [
          BlocBuilder<PostDetailsBloc, PostDetailState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                elevation: 3,
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push(
                      RouteConstants.editPostPage,
                      extra: {
                        // pasing the post id and userid to get the post detail through bloc in case the post is unavailabel at that moment
                        'postId': post?.id,
                        'post': post,
                        'userId': post?.createdBy,
                      },
                    );
                  }
                  if (value == 'delete') {
                    _showDeleteConfirmDialog(
                      context,
                      title: post?.title,
                      userId: userId ?? '',
                      state: state,
                    );
                  }
                },
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
                        Icon(
                          Icons.delete,
                          size: UiConstants.iconMd,
                          color: Colors.red,
                        ),
                        SizedBox(width: UiConstants.spacingSm),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<PostDetailsBloc, PostDetailState>(
        listener: (context, state) {
          if (state is PostDetailDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is PostDetailError) {
            // print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 10),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PostdetailLoading || state is PostDetailDeleting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PostDetailLoaded) {
            return _buildPostDetailSection(
              context,
              post: state.post,
              stateLoaded: state,
            );
          }
          if (state is PostDetailNotFound) {
            return _buildNotFoundState(context);
          }
          if (state is PostDetailError) {
            return _buildErrorState(context, message: state.message);
          }

          // show try again in fall back
          return _buildFallBackTryAgainState(context);
        },
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingSm),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Expanded(
      //         child: CustomButton(
      //           text: 'Add to Library',
      //           icon: const Icon(Icons.bookmark_outline),
      //           onPressed: () {},
      //           isOutlined: true,
      //         ),
      //       ),
      //       const SizedBox(width: UiConstants.spacingSm),
      //       Expanded(
      //         child: CustomButton(
      //           text: 'Book Now',
      //           onPressed: () {},
      //           icon: const Icon(Icons.event_available),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

Widget _buildPostDetailSection(
  BuildContext context, {
  required Post post,
  required PostDetailLoaded stateLoaded,
}) {
  return BlocBuilder<PostDetailsBloc, PostDetailState>(
    builder: (context, state) {
      final isViewingImage = state is PostDetailLoaded
          ? state.isViewingImage
          : false;
      if (isViewingImage) {
        return _buildImageViewer(context, state);
      }
      return RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePageView(context, stateLoaded),
              _buildTitleAndPriceSection(
                context,
                title: post.title,
                price: post.price!,
              ),
              _buildDescriptionSection(
                context,
                description: post.description!,
                isExpanded: stateLoaded.isDescriptionExpanded,
                onToggleExpand: () {
                  context.read<PostDetailsBloc>().add(
                    PostDetailToggleDescriptionRequested(
                      isDescriptionToggled: stateLoaded.isDescriptionExpanded,
                    ),
                  );
                },
              ),
              const SizedBox(height: UiConstants.spacingSm),
              _buildActionButtons(context),
              const SizedBox(height: UiConstants.spacingSm),

              _buildLocationSection(
                context,
                latitude: post.latitude,
                longitude: post.longitude,
              ),
              const SizedBox(height: UiConstants.spacingSm),
              _buildCustomerReviewSection(context),
              const SizedBox(height: UiConstants.spacingSm),
              _buildAmeniticsSection(context, amenityType: post.amenities),
              const SizedBox(height: UiConstants.spacingSm),
              _buildTagsSection(context, postTag: post.tags),
              const SizedBox(height: UiConstants.spacingSm),
              _buildOthersDetails(
                context,
                roomType: post.roomType,
                area: post.area,
                capacity: post.capacity,
              ),
              const SizedBox(height: UiConstants.spacingSm),
              _buildYoutubeVideoPreview(context, youtubeUrl: post.youtubeUrl),
              const SizedBox(height: UiConstants.spacingXxl),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildCustomerReviewSection(BuildContext context) {
  return const SectionContainer(
    borderRadius: BorderRadius.zero,
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Reviews!!!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: UiConstants.spacingSm),
        ],
      ),
    ),
  );
}

Widget _buildActionButtons(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingSm),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: CustomButton(
            text: 'Add to Library',
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {},
            isOutlined: true,
          ),
        ),
        const SizedBox(width: UiConstants.spacingSm),
        Expanded(
          child: CustomButton(
            text: 'Book Now',
            onPressed: () {},
            icon: const Icon(Icons.event_available),
          ),
        ),
      ],
    ),
  );
}

Widget _buildImagePageView(BuildContext context, PostDetailLoaded state) {
  final images = state.getAllImages;
  final currentIndex = state.viewingImageIndex ?? 0;
  final pageController = PageController(initialPage: currentIndex);
  return SizedBox(
    height: 400,
    child: Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            context.read<PostDetailsBloc>().add(
              PostDetailImageViewRequested(imageIndex: index),
            );
          },
          itemBuilder: (context, index) {
            final url = images[index];
            return GestureDetector(
              onTap: () {
                _onImageViewTapped(context, index);
              },
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 400,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
              ),
            );
          },
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: getPostStatusColor(state.post.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              enumToString(state.post.status).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black45, Colors.black54],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final currentIndex = state.viewingImageIndex ?? 0;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == i ? 10 : 4,
                  height: currentIndex == i ? 10 : 4,
                  decoration: BoxDecoration(
                    color: currentIndex == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    ),
  );
}

void _onImageViewTapped(BuildContext context, int index) {
  context.read<PostDetailsBloc>().add(
    PostDetailFullImageViewRequested(imageIndex: index),
  );
}

void _onCloseImageViewer(BuildContext context) {
  context.read<PostDetailsBloc>().add(
    const PostDetailImageViewCloseRequested(),
  );
}

Widget _buildImageViewer(BuildContext context, PostDetailLoaded state) {
  final allImages = state.getAllImages;
  final currentIndex = state.viewingImageIndex ?? 0;
  final pageController = PageController(initialPage: currentIndex);

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _onCloseImageViewer(context),
      ),
      title: Text('${currentIndex + 1} of ${allImages.length}'),
      centerTitle: true,
    ),
    body: PageView.builder(
      controller: pageController,
      itemCount: allImages.length,
      onPageChanged: (index) {
        context.read<PostDetailsBloc>().add(
          PostDetailImageViewRequested(imageIndex: index),
        );
      },
      itemBuilder: (context, index) {
        return InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: allImages[index],
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error)),
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildLocationSection(
  BuildContext context, {
  required double? latitude,
  required double? longitude,
}) {
  if (latitude == null && longitude == null) {
    // print('object');
    return const SizedBox.shrink();
  } else {
    final location = LatLng(latitude!, longitude!);
    return SectionContainer(
      borderRadius: BorderRadius.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                'Find us here',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            'Visit us in person – we\'re ready to welcome you!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(UiConstants.radiusMd),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 16,
                  minZoom: 3,
                  maxZoom: 20,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.png?key=${AppConfig.mapTilerKey}',
                    userAgentPackageName: 'com.example.app',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    maxZoom: 20,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 50,
                          shadows: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UiConstants.spacingSm),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Get Directions',
                  icon: const Icon(Icons.directions),
                  onPressed: () => _launchMaps(context, latitude, longitude),
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'View Map',
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    // TODO
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _launchMaps(BuildContext context, double lat, double lng) async {
  final googleUrl = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );
  final appleUrl = Uri.parse('https://maps.apple.com/?q=$lat,$lng');

  if (await canLaunchUrl(googleUrl)) {
    await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
  } else if (await canLaunchUrl(appleUrl)) {
    await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }
}

Widget _buildTitleAndPriceSection(
  BuildContext context, {
  required String title,
  required double price,
}) {
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Rs.', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '$price',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildDescriptionSection(
  BuildContext context, {
  required String description,
  required bool isExpanded,
  required VoidCallback onToggleExpand,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingSm),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = DefaultTextStyle.of(context).style;
        final span = TextSpan(text: description, style: textStyle);

        final textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          maxLines: 3,
          ellipsis: '...',
        )..layout(maxWidth: constraints.maxWidth);

        final bool textExceedsThreeLines = textPainter.didExceedMaxLines;

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isExpanded || !textExceedsThreeLines)
                Text(
                  description,
                  style: textStyle,
                  textAlign: TextAlign.justify,
                )
              else
                Stack(
                  children: [
                    Text(
                      description,
                      maxLines: 3,
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
          ),
        );
      },
    ),
  );
}

Widget _buildAmeniticsSection(
  BuildContext context, {
  required List<AmenityType>? amenityType,
}) {
  if (amenityType == null) return const SizedBox.shrink();
  return SectionContainer(
    borderRadius: BorderRadius.zero,
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomMultiSelect<AmenityType>(
            label: 'Amenities',
            items: AmenityType.values,
            selected: amenityType,
            itemLabel: (a) => _amenityLabel(a),
            readOnly: true,
            onChanged: null,
          ),
        ],
      ),
    ),
  );
}

Widget _buildTagsSection(
  BuildContext context, {
  required List<PostTag>? postTag,
}) {
  if (postTag == null) return const SizedBox.shrink();
  return SectionContainer(
    borderRadius: BorderRadius.zero,
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomMultiSelect<PostTag>(
            label: 'Tags',
            items: PostTag.values,
            selected: postTag,
            itemLabel: (p) => _tagLabel(p),
            readOnly: true,
            onChanged: null,
          ),
        ],
      ),
    ),
  );
}

Widget _buildOthersDetails(
  BuildContext context, {
  required RoomType? roomType,
  required double? area,
  required int? capacity,
}) {
  if (roomType == null && area == null && capacity == null) {
    return const SizedBox.shrink();
  }
  return SectionContainer(
    borderRadius: BorderRadius.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Others details!!!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: UiConstants.spacingSm),
        if (roomType != null)
          DetailInfoTile(
            icon: Icons.bed,
            title: "Room Type",
            value: roomType.displayName,
          ),
        const SizedBox(height: UiConstants.spacingSm),
        if (area != null)
          DetailInfoTile(
            icon: Icons.square_foot,
            title: "Area",
            value: "$area sqft",
          ),
        const SizedBox(height: UiConstants.spacingSm),
        if (capacity != null)
          DetailInfoTile(
            icon: Icons.people,
            title: "Capacity",
            value: "$capacity guests",
          ),
      ],
    ),
  );
}

String _amenityLabel(AmenityType a) => a.name.replaceAll('_', ' ').capitalize();
String _tagLabel(PostTag p) => p.name.replaceAll('_', ' ').capitalize();

extension StringExt on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}

Widget _buildYoutubeVideoPreview(
  BuildContext context, {
  required String? youtubeUrl,
}) {
  if (youtubeUrl == null) return const SizedBox.shrink();

  final videoId = extractYoutubeId(youtubeUrl);

  if (videoId == null) {
    return const Text("Invalid YouTube link");
  }

  final thumbnailUrl = "https://img.youtube.com/vi/$videoId/0.jpg";

  return SectionContainer(
    borderRadius: BorderRadius.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wanna know us about more!!!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Visit us in our official youtybe videos!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: UiConstants.spacingSm),
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(youtubeUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open youtube')),
                );
              }
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(UiConstants.radiusSm),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),

                // Play button overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha(80),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

String? extractYoutubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }

  if (uri.host.contains('youtube.com')) {
    return uri.queryParameters['v'];
  }

  return null;
}

Widget _buildNotFoundState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off, size: UiConstants.iconLg),
        const SizedBox(height: UiConstants.spacingMd),
        const Text(
          'No results found',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: UiConstants.spacingSm),
        const Text(
          'Try adjusting your search or filters.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiConstants.spacingLg),
        CustomButton(
          text: 'Try Again',
          onPressed: () => _onRefresh(context),
          icon: const Icon(Icons.refresh),
        ),
      ],
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
            const Text(
              'Error',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

Future<void> _onRefresh(BuildContext context) async {
  context.read<PostDetailsBloc>().add(const PostDetailRefreshRequested());
}

Widget _buildFallBackTryAgainState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.remove_red_eye, size: UiConstants.iconLg),
          const SizedBox(height: UiConstants.spacingMd),
          const Text(
            'Somethign went wrong!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: UiConstants.spacingSm),
          const Text(
            'Looks like something is happening while fetching the post details, please try again.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UiConstants.spacingLg),

          CustomButton(
            text: 'Retry',
            icon: const Icon(Icons.refresh),
            onPressed: () => _onRefresh(context),
          ),
        ],
      ),
    ),
  );
}

Color getPostStatusColor(PostStatus status) {
  switch (status) {
    case PostStatus.available:
      return const Color(0xFF4CAF50);
    case PostStatus.booked:
      return const Color(0xFFFF8C00);
    case PostStatus.sold:
      return const Color(0xFFEF5350);
    case PostStatus.underMaintenance:
      return const Color(0xFF546E7A);
  }
}

void _showDeleteConfirmDialog(
  BuildContext context, {
  required String? title,
  required String userId,
  required PostDetailState state,
}) {
  // print('$title , $userId');
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete post Confirm'),
        content: Text(
          'Are you aure want to delete this post ($title), This action can\'t be undone once you delete , you will lose all related data about this post',
        ),
        actions: [
          CustomButton(
            text: 'Cancel',
            isOutlined: true,
            onPressed: () => dialogContext.pop(),
          ),
          CustomButton(
            text: 'Confirm',
            isLoading: state is PostDetailDeleting,
            onPressed: () {
              context.read<PostDetailsBloc>().add(
                PostDetailDeleteRequested(userId: userId),
              );
              dialogContext.pop();
            },
          ),
          // BlocBuilder<PostDetailsBloc, PostDetailState>(
          //   builder: (context, state) {
          //     if (state is PostDetailLoaded) {
          //       CustomButton(
          //         text: 'Confirm',
          //         isLoading: state is PostDetailDeleting,
          //         onPressed: () => context.read<PostDetailsBloc>().add(
          //           PostDetailDeleteRequested(userId: userId),
          //         ),
          //       );
          //     }
          //     return const SizedBox.shrink();
          //   },
          // ),
        ],
      );
    },
  );
}
