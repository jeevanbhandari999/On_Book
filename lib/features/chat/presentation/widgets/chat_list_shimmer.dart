import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:shimmer/shimmer.dart';

class ChatListShimmerPage extends StatelessWidget {
  const ChatListShimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(top: UiConstants.spacingLg),
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(UiConstants.radiusXl),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    left: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    right: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiConstants.spacingMd,
                    vertical: UiConstants.spacingMd,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusMd,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusRound,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: UiConstants.spacingMd),
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            UiConstants.radiusLg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(top: UiConstants.spacingMd),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  // if (index == 0 || index == 4) {
                  //   return Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: UiConstants.spacingMd,
                  //       vertical: UiConstants.spacingXs,
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Container(
                  //           width: 20,
                  //           height: 20,
                  //           decoration: const BoxDecoration(
                  //             color: Colors.white,
                  //             shape: BoxShape.circle,
                  //           ),
                  //         ),
                  //         const SizedBox(width: UiConstants.spacingSm),
                  //         Container(
                  //           width: 80,
                  //           height: 16,
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(
                  //               UiConstants.radiusMd,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // }
                  return _buildChatCardShimmer();
                }, childCount: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCardShimmer() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: UiConstants.spacingMd,
            vertical: UiConstants.spacingXs,
          ),
          padding: const EdgeInsets.all(UiConstants.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiConstants.radiusMd),
            color: Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 28, backgroundColor: Colors.white),
              const SizedBox(width: UiConstants.spacingMd),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 140,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusSm,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusSm,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UiConstants.spacingSm),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusSm,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: UiConstants.spacingMd),
                        Container(
                          width: 24,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusRound,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
