import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrganizationDetailsShimmer extends StatelessWidget {
  const OrganizationDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Base color for the shimmer (grey)
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // 1. Fake Sliver App Bar
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Gradient Background Placeholder
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            UiConstants.radiusLg,
                          ),
                        ),
                      ),
                    ),
                    // Logo Placeholder
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Body Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Name & Address)
                    _buildHeaderShimmer(),
                    const SizedBox(height: 24),

                    // Contact Info Card
                    _buildSectionCardShimmer(height: 120),
                    const SizedBox(height: 24),

                    // Members Section (Simulating grouped lists)
                    _buildMembersSectionShimmer(),
                    const SizedBox(height: 16),

                    // Location/Metadata Card
                    _buildSectionCardShimmer(height: 100),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Line
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          ),
        ),
        const SizedBox(height: 12),
        // Address Line
        Row(
          children: [
            const CircleAvatar(radius: 8, backgroundColor: Colors.white),
            const SizedBox(width: 8),
            Container(
              width: 150,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCardShimmer({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Container(
            width: 100,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey[100], // Slightly lighter inside card
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Content Lines
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildLinePlaceholder(), _buildLinePlaceholder()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinePlaceholder() {
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
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSectionShimmer() {
    return Container(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Team Members" Title
          Container(width: 120, height: 18, color: Colors.grey[100]),
          const SizedBox(height: 20),

          // Simulate 3 Member Rows
          _buildMemberRowShimmer(),
          _buildMemberRowShimmer(),
          _buildMemberRowShimmer(),
        ],
      ),
    );
  }

  Widget _buildMemberRowShimmer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(radius: 22, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          // Name and Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Role Badge
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
