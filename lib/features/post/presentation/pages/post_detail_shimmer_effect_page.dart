import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostDetailShimmerEffectPage extends StatelessWidget {
  const PostDetailShimmerEffectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. Top Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  UiConstants.spacingLg,
                  UiConstants.spacingXxl + UiConstants.spacingSm,
                  UiConstants.spacingLg,
                  UiConstants.spacingLg,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  border: Border.all(color: baseColor, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 140,
                              height: 20,
                              decoration: _boxDecoration(),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 70,
                              height: 18,
                              decoration: _boxDecoration(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: _boxDecoration(),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 250,
                      height: 12,
                      decoration: _boxDecoration(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Action Buttons (Manage Orga... / Manage Posts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        decoration: _boxDecoration(radius: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 55,
                        decoration: _boxDecoration(radius: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 3. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 50,
                  decoration: _boxDecoration(radius: 12),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Tab Navigation (All Posts, Videos, Images)
              Column(
                children: [
                  const Divider(color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        3,
                        (index) => Column(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: _boxDecoration(radius: 6),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 50,
                              height: 10,
                              decoration: _boxDecoration(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                ],
              ),

              const SizedBox(height: 20),

              // 5. Simulated Masonry Grid using Row and Columns
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildPostCardShimmer(280), // Tall card
                          const SizedBox(height: 12),
                          _buildPostCardShimmer(200), // Medium card
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildPostCardShimmer(180), // Short card
                          const SizedBox(height: 12),
                          _buildPostCardShimmer(260), // Tall card
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // Helper for consistent container styling
  BoxDecoration _boxDecoration({double radius = 6}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  Widget _buildPostCardShimmer(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: _boxDecoration(radius: 12),
      child: Stack(
        children: [
          // Simulated Text Overlay at the bottom left of the image
          Positioned(
            bottom: 15,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 12,
                  decoration: _boxDecoration(radius: 4),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: _boxDecoration(radius: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
