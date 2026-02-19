import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SearchShimmerView extends StatelessWidget {
  const SearchShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: UiConstants.spacingMd),

            // People section
            _TitleShimmer(width: 160, height: 20),
            SizedBox(height: UiConstants.spacingSm),
            _HorizontalAvatarShimmer(),
            SizedBox(height: UiConstants.spacingSm),

            // Hotels section
            _TitleShimmer(width: 230, height: 20),
            SizedBox(height: UiConstants.spacingSm),
            _HorizontalCardShimmer(),
            SizedBox(height: UiConstants.spacingLg),

            // Posts section
            _TitleShimmer(width: 200, height: 20),
            SizedBox(height: UiConstants.spacingSm),
            _GridShimmer(),

            SizedBox(height: UiConstants.spacingLg),
          ],
        ),
      ),
    );
  }
}





class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    // Manually build rows instead of GridView to avoid sizing issues inside Column
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
      child: Column(
        children: List.generate(4, (rowIndex) {
          final leftHeight = rowIndex.isEven ? 200.0 : 260.0;
          final rightHeight = rowIndex.isEven ? 260.0 : 200.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: UiConstants.spacingSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _ShimmerBox(height: leftHeight)),
                const SizedBox(width: UiConstants.spacingSm),
                Expanded(child: _ShimmerBox(height: rightHeight)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE SHIMMER BOX
// ─────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double? height;
  final double? width;
  final double radius;

  const _ShimmerBox({this.height, this.width, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TITLE SHIMMER
// ─────────────────────────────────────────────

class _TitleShimmer extends StatelessWidget {
  final double height;
  final double width;
  const _TitleShimmer({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
        vertical: UiConstants.spacingSm,
      ),
      child: _ShimmerBox(height: height, width: width),
    );
  }
}

// ─────────────────────────────────────────────
// HORIZONTAL AVATAR SHIMMER
// ─────────────────────────────────────────────

class _HorizontalAvatarShimmer extends StatelessWidget {
  const _HorizontalAvatarShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            const SizedBox(width: UiConstants.spacingMd),
        itemBuilder: (_, __) => const Column(
          children: [
            CircleAvatar(radius: 28, backgroundColor: Colors.white),
            SizedBox(height: 8),
            _ShimmerBox(height: 10, width: 50, radius: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HORIZONTAL CARD SHIMMER
// ─────────────────────────────────────────────

class _HorizontalCardShimmer extends StatelessWidget {
  const _HorizontalCardShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            const SizedBox(width: UiConstants.spacingMd),
        itemBuilder: (_, __) => const _ShimmerBox(height: 220, width: 160),
      ),
    );
  }
}