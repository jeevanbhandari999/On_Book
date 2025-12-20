import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/presentation/pages/post_details_page.dart';
import 'package:flutter/material.dart';

class BookingPostSummary extends StatelessWidget {
  final Post post;

  const BookingPostSummary({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final images = [
      post.primaryImageUrl,
      ...post.additionalImagesForHomeFeed.take(5),
    ];

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images
          SizedBox(
            height: 150,
            child: Row(
              children: [
                // Primary image (bigger)
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      post.primaryImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Additional images
                if (post.additionalImagesForHomeFeed.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.additionalImagesForHomeFeed
                          .take(4)
                          .length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.additionalImagesForHomeFeed[index],
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: UiConstants.spacingSm),

          // Title + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getPostStatusColor(post.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  enumToString(post.status).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Price
          Text(
            'Rs. ${post.price} / night',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          // Key features (minimal)
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (post.roomType != null)
                _feature(Icons.bed, post.roomType!.displayName),
              if (post.capacity != null)
                _feature(Icons.people, '${post.capacity} guests'),
              if (post.area != null)
                _feature(Icons.square_foot, '${post.area} sqft'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
