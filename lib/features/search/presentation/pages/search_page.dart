import 'dart:async';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  SearchFilter _filter = SearchFilter.all;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100 + UiConstants.spacingLg,
            collapsedHeight: 100 + UiConstants.spacingLg,
            foregroundColor: Colors.white,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(
                  right: UiConstants.spacingMd,
                  left: UiConstants.spacingMd,
                  bottom: UiConstants.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(UiConstants.radiusXl),
                    bottomRight: Radius.circular(UiConstants.radiusXl),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: kToolbarHeight),
                    CustomTextField(
                      controller: _controller,
                      onChanged: (value) {
                        setState(() {
                          // searchQuery = value;
                        });
                      },
                      hint: 'What do you want...',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    const SizedBox(height: UiConstants.spacingSm),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return _FilterChip(
                            filter: _filter,
                            isActive: _filter == SearchFilter.values[index],
                            onTap: () {
                              setState(() {
                                _filter = SearchFilter.values[index];
                              });
                            },
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: UiConstants.spacingXs),
                        itemCount: SearchFilter.values.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(UiConstants.spacingMd),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: UiConstants.spacingSm,
              crossAxisSpacing: UiConstants.spacingSm,
              childCount: 10,
              itemBuilder: (context, index) {
                final height = index.isEven ? 200.0 : 260.0;
                return _buildPostCardShimmer(height);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCardShimmer(double height) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(UiConstants.radiusMd),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            UiConstants.spacingSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        UiConstants.spacingSm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final SearchFilter filter;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(Icons.check, size: 16, color: Colors.black),
              const SizedBox(width: 6),
            ],
            Text(
              filter.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SearchFilter { all, people, hotels, posts }
