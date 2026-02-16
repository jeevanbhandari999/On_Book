import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ViewUserProfileShimmer extends StatelessWidget {
  const ViewUserProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.sizeOf(context).height * 0.25,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: kToolbarHeight),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConstants.spacingMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: UiConstants.spacingMd),

                  // "Personal Information" title
                  Container(
                    width: 180,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                    ),
                  ),
                  const SizedBox(height: UiConstants.spacingSm),

                  // Name card + gradient container
                  Container(
                    width: double.infinity,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusXl),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                  ),

                  const SizedBox(height: UiConstants.spacingMd),

                  // "Say Hi" button placeholder
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusXl),
                    ),
                  ),

                  const SizedBox(height: UiConstants.spacingLg),

                  // "Contact Information" title
                  Container(
                    width: 160,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                    ),
                  ),
                  const SizedBox(height: UiConstants.spacingSm),

                  // Contact info card
                  Container(
                    width: double.infinity,
                    height: 160,
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusXl),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRowPlaceholder(),
                        _buildRowPlaceholder(),
                        _buildRowPlaceholder(),
                      ],
                    ),
                  ),

                  const SizedBox(height: UiConstants.spacingLg),

                  // "Additional Information" title
                  Container(
                    width: 200,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                    ),
                  ),
                  const SizedBox(height: UiConstants.spacingSm),

                  // Additional info card (organization + joined date)
                  Container(
                    width: double.infinity,
                    height: 140,
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusXl),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Organization row
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 16,
                                    color: Colors.grey[100],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 100,
                                    height: 12,
                                    color: Colors.grey[100],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Joined date row
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 120,
                              height: 14,
                              color: Colors.grey[100],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowPlaceholder() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
