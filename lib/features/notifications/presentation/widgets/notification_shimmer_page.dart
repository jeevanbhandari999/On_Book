import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:shimmer/shimmer.dart';

class NotificationShimmerPage extends StatelessWidget {
  const NotificationShimmerPage({super.key});

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
                padding: const EdgeInsets.only(top: UiConstants.spacingMd),
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(UiConstants.radiusXl),
                  ),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: UiConstants.spacingMd,
                    left: UiConstants.spacingMd,
                    top: UiConstants.spacingXl,
                    bottom: UiConstants.spacingSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: UiConstants.spacingXxl),

                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusRound,
                              ),
                            ),
                          ),
                          const SizedBox(width: UiConstants.spacingMd),
                          Container(
                            width: 30,
                            height: 30,
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

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: UiConstants.spacingMd),
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiConstants.spacingMd,
                  ),
                  itemCount: 6,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: UiConstants.spacingSm),
                  itemBuilder: (context, index) {
                    return Container(
                      width: widthOfFilterTabs[index].toDouble(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          UiConstants.radiusRound,
                        ),
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(top: UiConstants.spacingMd),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index % 4 == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiConstants.spacingMd,
                        vertical: UiConstants.spacingSm,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return _buildNotificationCardShimmer();
                }, childCount: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCardShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
        vertical: UiConstants.spacingXs,
      ),
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
        color: Colors.transparent,
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 24, backgroundColor: Colors.white),
          const SizedBox(width: UiConstants.spacingMd),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          UiConstants.radiusSm,
                        ),
                      ),
                    ),
                    const SizedBox(width: UiConstants.spacingSm),
                    Container(
                      width: 40,
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
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UiConstants.radiusSm),
                  ),
                ),
                const SizedBox(height: UiConstants.spacingSm),
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UiConstants.radiusSm),
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

final widthOfFilterTabs = [110, 90, 100, 76, 93, 86, 110, 99];
