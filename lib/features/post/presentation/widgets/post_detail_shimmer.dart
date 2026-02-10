import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostDetailsShimmer extends StatelessWidget {
  const PostDetailsShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image PageView Placeholder (Height 400)
              Container(
                width: double.infinity,
                height: 400,
                color: Colors.white,
              ),

              Padding(
                padding: const EdgeInsets.all(UiConstants.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Title and Price Section
                    const SizedBox(height: UiConstants.spacingSm),
                    Container(
                      width: double.infinity,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // 3. Description Section (3 lines)
                    const SizedBox(height: UiConstants.spacingMd),
                    Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            width: double.infinity,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 4. Action Buttons (Add to Library / Book Now)
                    const SizedBox(height: UiConstants.spacingSm),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48, // Standard button height
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusMd,
                              ), // Assuming radiusMd exists
                            ),
                          ),
                        ),
                        const SizedBox(width: UiConstants.spacingSm),
                        Expanded(
                          child: Container(
                            height: 48,
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

                    // 5. Location/Map Section
                    const SizedBox(height: UiConstants.spacingMd),
                    _buildSectionHeaderPlaceholder(),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 200, // Map height
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          UiConstants.radiusMd,
                        ),
                      ),
                    ),
                    const SizedBox(height: UiConstants.spacingSm),
                    // Map Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 40, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(height: 40, color: Colors.white),
                        ),
                      ],
                    ),

                    // 6. Reviews Section
                    const SizedBox(height: UiConstants.spacingMd),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeaderPlaceholder(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.white,
                              ),
                              Container(
                                width: 80,
                                height: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 10,
                            color: Colors.white,
                          ), // Progress bar
                        ],
                      ),
                    ),

                    // 7. Amenities / Tags (Chips)
                    const SizedBox(height: UiConstants.spacingMd),
                    _buildSectionHeaderPlaceholder(),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 80,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    // 8. Other Details (Room Type, Area, etc)
                    const SizedBox(height: UiConstants.spacingMd),
                    _buildSectionHeaderPlaceholder(),
                    const SizedBox(height: 12),
                    _buildDetailRowPlaceholder(),
                    const SizedBox(height: 8),
                    _buildDetailRowPlaceholder(),
                    const SizedBox(height: 8),
                    _buildDetailRowPlaceholder(),

                    // 9. YouTube Video
                    const SizedBox(height: UiConstants.spacingMd),
                    _buildSectionHeaderPlaceholder(),
                    const SizedBox(height: 8),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            UiConstants.radiusSm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: UiConstants.spacingXxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build a "Section Title" gray box
  Widget _buildSectionHeaderPlaceholder() {
    return Container(
      width: 150,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Helper to build "Icon + Text" row
  Widget _buildDetailRowPlaceholder() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 80, height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(width: 120, height: 12, color: Colors.white),
          ],
        ),
      ],
    );
  }
}
