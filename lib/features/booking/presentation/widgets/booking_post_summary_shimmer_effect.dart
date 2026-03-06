import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BookingPostSummaryShimmerEffect extends StatelessWidget {
  const BookingPostSummaryShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      backgroundColor: Colors.transparent,
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 22,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              ),
            ),
            const SizedBox(height: UiConstants.spacingSm),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: UiConstants.spacingMd),
                itemBuilder: (_, __) => Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: UiConstants.spacingSm),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 18,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                  ),
                ),
              ],
            ),

            const SizedBox(height: UiConstants.spacingSm),

            // Description
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              ),
            ),

            const SizedBox(height: UiConstants.spacingSm),

            // Price
            Container(
              height: 18,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              ),
            ),

            const SizedBox(height: UiConstants.spacingSm),

            // Amenities shimmer
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                5,
                (_) => Container(
                  height: 30,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: UiConstants.spacingSm),

            // Features shimmer
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: List.generate(
                3,
                (_) => Container(
                  height: 16,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
