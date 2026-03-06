import 'package:app/features/booking/presentation/widgets/booking_post_summary_shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app/core/constants/ui_constants.dart';

class BookingFormShimmerEffect extends StatelessWidget {
  const BookingFormShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              title: Container(
                width: 170,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
            SliverPadding(
              padding: const EdgeInsets.all(UiConstants.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _userCard(),
                  const SizedBox(height: 20),

                  _postSummary(),

                  const SizedBox(height: 20),

                  _scheduleCard(),

                  const SizedBox(height: 20),

                  _notesCard(),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(UiConstants.radiusMd),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 160),
                const SizedBox(height: 8),
                _box(width: 120),
                const SizedBox(height: 8),
                _box(width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _postSummary() {
    return const BookingPostSummaryShimmerEffect();
  }

  Widget _scheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 160),

          const SizedBox(height: 20),

          _box(height: 60),
          const SizedBox(height: 12),

          _box(height: 60),

          const SizedBox(height: 16),

          _box(height: 40),
        ],
      ),
    );
  }

  Widget _notesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 140),
          const SizedBox(height: 16),

          _box(height: 90),

          const SizedBox(height: 16),

          _box(height: 50),
        ],
      ),
    );
  }

  Widget _box({double width = double.infinity, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      border: Border.all(width: 1, color: Colors.white),
    );
  }
}
