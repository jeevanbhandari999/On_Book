import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:shimmer/shimmer.dart';

class ChatDetailShimmerPage extends StatelessWidget {
  const ChatDetailShimmerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(UiConstants.radiusXl),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                          left: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                          right: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
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
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      UiConstants.radiusRound,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: UiConstants.spacingMd),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: UiConstants.spacingSm,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 60,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: UiConstants.spacingMd),

                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: UiConstants.spacingSm,
                                  ),
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: UiConstants.spacingSm,
                                  ),
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(UiConstants.spacingMd),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildShimmerBubble(isMine: false, width: 200),
                          _buildShimmerBubble(isMine: true, width: 150),
                          _buildShimmerBubble(isMine: false, width: 120),
                          _buildShimmerBubble(isMine: false, width: 220),
                          _buildShimmerBubble(isMine: true, width: 200),
                          _buildShimmerBubble(isMine: true, width: 100),
                          _buildShimmerBubble(isMine: false, width: 160),
                          _buildShimmerBubble(isMine: true, width: 150),
                          _buildShimmerBubble(isMine: false, width: 120),
                          _buildShimmerBubble(isMine: false, width: 220),
                          _buildShimmerBubble(isMine: true, width: 180),
                          _buildShimmerBubble(isMine: true, width: 100),
                          _buildShimmerBubble(isMine: false, width: 160),
                          _buildShimmerBubble(isMine: true, width: 150),
                          _buildShimmerBubble(isMine: false, width: 120),
                          _buildShimmerBubble(isMine: false, width: 220),
                          _buildShimmerBubble(isMine: true, width: 180),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              padding: const EdgeInsets.only(
                left: UiConstants.spacingMd,
                right: UiConstants.spacingMd,
                top: UiConstants.spacingSm,
                bottom: UiConstants.spacingLg,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                  const SizedBox(width: UiConstants.spacingSm),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          UiConstants.radiusXl,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UiConstants.spacingSm),
                  const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBubble({required bool isMine, required double width}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiConstants.spacingSm),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            const CircleAvatar(radius: 16, backgroundColor: Colors.white),
            const SizedBox(width: UiConstants.spacingSm),
          ],
          Container(
            width: width,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMine ? UiConstants.radiusLg : 4),
                topRight: Radius.circular(isMine ? 4 : UiConstants.radiusLg),
                bottomLeft: const Radius.circular(UiConstants.radiusLg),
                bottomRight: const Radius.circular(UiConstants.radiusLg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
