import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'post_card.dart';

class PostGridSection extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  const PostGridSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(posts.length, (index) {
          final post = posts[index];
          // final isWide = (index + 1) % 5 == 0;
          return StaggeredGridTile.fit(
            // crossAxisCellCount: isWide ? 2 : 1,
            crossAxisCellCount: 1,
            child:
                PostCard(
                      key: ValueKey(
                        post['imageUrl'] ?? post['videoUrl'] ?? index,
                      ),
                      title: post['title'] ?? 'Untitled',
                      imageUrl: post['imageUrl'],
                      videoUrl: post['videoUrl'],
                      description: post['description'] ?? '',
                      price: (post['price'] as num?)?.toDouble() ?? 0.0,
                      onTap: () {
                        if (post['posts'] as bool == true) {
                          context.push(
                            RouteConstants.postDetailsPage,
                            extra: {
                              'postId': post['postId'],
                              'post': post['post'],
                              'userId': post['userId'],
                            },
                          );
                        }
                        if (post['images'] as bool == true) {
                          _showModalBottomSheetForImage(context, post: post);
                        }
                      },
                      posts: (post['posts'] as bool),
                      videos: (post['videos'] as bool),
                      images: (post['images'] as bool),
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
                    .fade(duration: UiConstants.animationSlow),
          );
        }),
      ),
    );
  }
}

Future<void> _showModalBottomSheetForImage(
  BuildContext context, {
  required Map<String, dynamic> post,
}) async {
  return CustomBottomSheet.show(
    context: context,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: post['imageUrl'],
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 220,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 220,
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // show the remaining related images to this posts (in future)
          if (post['gallery'] != null && post['gallery'] is List)
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: (post['gallery'] as List).length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final img = post['gallery'][index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: img,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: UiConstants.spacingMd),

          Text(
            post['title'] ?? 'Untitled Post',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: UiConstants.spacingSm),

          Text(
            post['description'] ?? 'No description available.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),

          const SizedBox(height: UiConstants.spacingMd),

          if (post['price'] != null)
            Text(
              "Price: Rs.${post['price'].toString()}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),

          // const SizedBox(height: UiConstants.spacingLg),
          // _buildActionButtons(context),
          const SizedBox(height: UiConstants.spacingMd),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'View More',
              onPressed: () {
                if (!context.mounted) return;
                context.push(
                  RouteConstants.postDetailsPage,
                  extra: {
                    'postId': post['postId'],
                    'post': post['post'],
                    'userId': post['userId'],
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
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
