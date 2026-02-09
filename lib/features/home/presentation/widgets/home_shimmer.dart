import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Define grey colors for the skeleton
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: CustomScrollView(
          physics:
              const NeverScrollableScrollPhysics(), // Disable scrolling while loading
          slivers: [
            // 1. App Bar Header
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(UiConstants.spacingSm),
                child: const CircleAvatar(backgroundColor: Colors.white),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: Colors.white),
              ),
            ),

            // 2. Organization Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiConstants.spacingMd,
                    vertical: UiConstants.spacingSm,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 6, // Simulate 6 items
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: UiConstants.spacingMd),
                  itemBuilder: (context, index) => Column(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Masonry Grid Posts
            SliverPadding(
              padding: const EdgeInsets.all(UiConstants.spacingMd),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: UiConstants.spacingSm,
                crossAxisSpacing: UiConstants.spacingSm,
                childCount: 6, // Simulate 6 posts
                itemBuilder: (context, index) {
                  // Simulate different heights for masonry effect
                  final height = index.isEven ? 200.0 : 260.0;
                  return _buildPostCardShimmer(height);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCardShimmer(double height) {
    return Container(
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
    );
  }
}
