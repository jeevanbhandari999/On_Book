import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/booking/presentation/widgets/booking_post_summary_shimmer_effect.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/usecases/delete_post_use_case.dart';
import 'package:app/features/post/domain/usecases/get_post_by_id_use_case.dart';
import 'package:app/features/post/domain/usecases/get_related_posts_through_algorithm_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_details_bloc.dart';
import 'package:app/features/post/presentation/pages/post_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingPosstSummary extends StatelessWidget {
  final Post post;
  final String? userId;
  const BookingPosstSummary({super.key, required this.post, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostDetailsBloc(
        getPostByIdUseCase: DependencyInjection.get<GetPostByIdUseCase>(),
        deletePostUseCase: DependencyInjection.get<DeletePostUseCase>(),
        getRelatedPostsThroughAlgorithmUseCase:
            DependencyInjection.get<GetRelatedPostsThroughAlgorithmUseCase>(),
        getOrganizationDetailByPostOrganizationIdUseCase:
            DependencyInjection.get<
              GetOrganizationDetailByPostOrganizationIdUseCase
            >(),
      )..add(PostDetailLoadRequested(postId: post.id, userId: userId)),
      child: BookingPostSummary(post: post),
    );
  }
}

class BookingPostSummary extends StatelessWidget {
  final Post post;

  const BookingPostSummary({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailsBloc, PostDetailState>(
      builder: (context, state) {
        if (state is PostDetailError) {}
        if (state is PostdetailLoading) {
          return const BookingPostSummaryShimmerEffect();
        }
        if (state is PostDetailLoaded) {
          // final images = [post.primaryImageUrl, ...post.additionalImagesForHomeFeed];
          final images = state.getAllImages;

          return SectionContainer(
            borderRadius: BorderRadius.circular(UiConstants.radiusMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text('Hotel Details', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: UiConstants.spacingSm),
                // Images
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final url = images[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: UiConstants.spacingMd),
                    itemCount: images.length,
                  ),
                ),

                const SizedBox(height: UiConstants.spacingSm),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
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
                Text(
                  post.description ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: UiConstants.spacingSm),

                // Price
                Text(
                  'Rs. ${post.price} / night',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: UiConstants.spacingSm),
                _buildAmeniticsSection(context, amenityType: post.amenities),
                const SizedBox(height: UiConstants.spacingSm),
                _buildTagsSection(context, postTag: post.tags),
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

        return const SizedBox.shrink();
      },
    );
  }
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

Widget _buildAmeniticsSection(
  BuildContext context, {
  required List<AmenityType>? amenityType,
}) {
  if (amenityType == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
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
  );
}

Widget _buildTagsSection(
  BuildContext context, {
  required List<PostTag>? postTag,
}) {
  if (postTag == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
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
  );
}

String _amenityLabel(AmenityType a) =>
    StringExt(a.name.replaceAll('_', ' ')).capitalize();
String _tagLabel(PostTag p) =>
    StringExt(p.name.replaceAll('_', ' ')).capitalize();

extension StringExt on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
