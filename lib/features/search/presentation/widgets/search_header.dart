import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/search/domain/entities/search_filter_enum.dart';
import 'package:app/features/search/presentation/bloc/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final SearchFilter activeFilter;
  final String currentUserId;

  const SearchHeader({super.key, 
    required this.controller,
    required this.activeFilter,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(UiConstants.radiusXl),
                  bottomRight: Radius.circular(UiConstants.radiusXl),
                ),
              ),
            )
            .animate()
            .slideY(
              begin: -2,
              duration: UiConstants.animationSlow,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: UiConstants.animationSlow),
        Container(
          padding: const EdgeInsets.only(
            right: UiConstants.spacingMd,
            left: UiConstants.spacingMd,
            bottom: UiConstants.spacingMd,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight),
              CustomTextField(
                controller: controller,
                onChanged: (value) {
                  context.read<SearchBloc>().add(
                    SearchQueryChanged(
                      query: value,
                      currentUserId: currentUserId,
                    ),
                  );
                },
                hint: 'Search what you want...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () {
                          controller.clear();
                          context.read<SearchBloc>().add(
                            SearchCleared(currentUserId: currentUserId),
                          );
                        },
                      )
                    : null,
              ),
              const SizedBox(height: UiConstants.spacingSm),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: SearchFilter.values.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: UiConstants.spacingXs),
                  itemBuilder: (context, index) {
                    final chipFilter = SearchFilter.values[index];
                    return _FilterChip(
                      filter: chipFilter,
                      isActive: activeFilter == chipFilter,
                      onTap: () => context.read<SearchBloc>().add(
                        SearchFilterChanged(filter: chipFilter),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
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

  String get _label => switch (filter) {
    SearchFilter.all => 'All',
    SearchFilter.people => 'People',
    SearchFilter.hotels => 'Hotels',
    SearchFilter.posts => 'Posts',
  };

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
              const Icon(Icons.check, size: 16, color: Colors.black87),
              const SizedBox(width: 6),
            ],
            Text(
              _label,
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