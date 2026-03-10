import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
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
             backgroundColor: AppColors.primaryLight,
              leading: const Padding(
                padding: EdgeInsets.all(UiConstants.spacingSm),
                child: CircleAvatar(backgroundColor: Colors.white),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                    ),
                  ),
                  const SizedBox(height: UiConstants.spacingSm),
                  Container(
                    height: 20,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                    ),
                  ),
                ],
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(16, 85, 16, 34),
                  decoration: BoxDecoration(
                    border: Border.all(color: baseColor),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(UiConstants.radiusLg),
                    ),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 230,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    UiConstants.radiusMd,
                                  ),
                                ),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              Container(
                                height: 20,
                                width: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    UiConstants.radiusMd,
                                  ),
                                ),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              Container(
                                height: 16,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    UiConstants.radiusMd,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusMd,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    right: UiConstants.spacingMd,
                    left: UiConstants.spacingMd,
                    top: UiConstants.spacingMd,
                    bottom: UiConstants.spacingSm,
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
