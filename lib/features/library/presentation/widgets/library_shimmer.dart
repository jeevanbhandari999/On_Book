import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class LibraryShimmer extends StatelessWidget {
  const LibraryShimmer({super.key});

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
              expandedHeight: 85,
              backgroundColor: Colors.transparent,

              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(
                    UiConstants.spacingSm,
                    UiConstants.spacingXxl + UiConstants.spacingSm,
                    UiConstants.spacingSm,
                    UiConstants.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: baseColor),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(UiConstants.radiusLg),
                    ),
                    color: Colors.transparent,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiConstants.spacingMd,
                    ),
                    child: Row(
                      children: List.generate(8, (index) {
                        return Container(
                          margin: const EdgeInsets.only(
                            right: UiConstants.spacingMd,
                          ),
                          width: widthOfButtons[index].toDouble(),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusMd,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),

            // SliverToBoxAdapter(
            //   child: SizedBox(
            //     height: 100,
            //     child: ListView.separated(
            //       padding: const EdgeInsets.only(
            //         right: UiConstants.spacingMd,
            //         left: UiConstants.spacingMd,
            //         top: UiConstants.spacingMd,
            //         bottom: UiConstants.spacingSm,
            //       ),
            //       scrollDirection: Axis.horizontal,
            //       itemCount: 6,
            //       separatorBuilder: (_, __) =>
            //           const SizedBox(width: UiConstants.spacingMd),
            //       itemBuilder: (context, index) => Column(
            //         children: [
            //           const CircleAvatar(
            //             radius: 28,
            //             backgroundColor: Colors.white,
            //           ),
            //           const SizedBox(height: 8),
            //           Container(
            //             width: 50,
            //             height: 10,
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(4),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // 3. Masonry Grid Posts
            SliverPadding(
              padding: const EdgeInsets.all(UiConstants.spacingMd),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 1,
                mainAxisSpacing: UiConstants.spacingSm,
                crossAxisSpacing: UiConstants.spacingSm,
                childCount: 8,
                itemBuilder: (context, index) {
                  // Simulate different heights for masonry effect
                  // final height = index.isEven ? 200.0 : 260.0;
                  return _buildPostCardShimmer(200);
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
      padding: const EdgeInsets.symmetric(
        vertical: UiConstants.spacingMd,
        horizontal: UiConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: UiConstants.spacingXs),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(UiConstants.radiusMd),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
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
                                height: 18,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    UiConstants.radiusMd,
                                  ),
                                ),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              Container(
                                height: 18,
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
                                height: 20,
                                width: 170,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    UiConstants.radiusMd,
                                  ),
                                ),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                            ],
                          ),
                        ),
                        const SizedBox(width: UiConstants.spacingSm),
                        const CircleAvatar(radius: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(8, (index) {
                    return Container(
                      margin: const EdgeInsets.only(
                        right: UiConstants.spacingMd,
                      ),
                      width: widthOfButtons[index].toDouble(),
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          UiConstants.radiusMd,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                // width: widthOfButtons[Random().nextInt(widthOfButtons.length)]
                //     .toDouble(),
                width: 250,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final widthOfButtons = [370, 200, 300, 350, 250, 440, 300, 410];
