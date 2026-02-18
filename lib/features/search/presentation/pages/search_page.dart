// import 'dart:async';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:shimmer/shimmer.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _controller = TextEditingController();
//   bool _isLoading = true;
//   SearchFilter _filter = SearchFilter.all;

//   @override
//   void initState() {
//     super.initState();
//     _simulateLoading();
//   }

//   void _simulateLoading() {
//     setState(() => _isLoading = true);
//     Timer(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 100 + UiConstants.spacingLg,
//             collapsedHeight: 100 + UiConstants.spacingLg,
//             foregroundColor: Colors.white,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 padding: const EdgeInsets.only(
//                   right: UiConstants.spacingMd,
//                   left: UiConstants.spacingMd,
//                   bottom: UiConstants.spacingMd,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.primary,
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(UiConstants.radiusXl),
//                     bottomRight: Radius.circular(UiConstants.radiusXl),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: kToolbarHeight),
//                     CustomTextField(
//                       controller: _controller,
//                       onChanged: (value) {
//                         setState(() {
//                           // searchQuery = value;
//                         });
//                       },
//                       hint: 'What do you want...',
//                       prefixIcon: const Icon(Icons.search),
//                     ),
//                     const SizedBox(height: UiConstants.spacingSm),
//                     SizedBox(
//                       height: 40,
//                       child: ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         itemBuilder: (context, index) {
//                           return _FilterChip(
//                             filter: _filter,
//                             isActive: _filter == SearchFilter.values[index],
//                             onTap: () {
//                               setState(() {
//                                 _filter = SearchFilter.values[index];
//                               });
//                             },
//                           );
//                         },
//                         separatorBuilder: (context, index) =>
//                             const SizedBox(width: UiConstants.spacingXs),
//                         itemCount: SearchFilter.values.length,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.all(UiConstants.spacingMd),
//             sliver: SliverMasonryGrid.count(
//               crossAxisCount: 2,
//               mainAxisSpacing: UiConstants.spacingSm,
//               crossAxisSpacing: UiConstants.spacingSm,
//               childCount: 10,
//               itemBuilder: (context, index) {
//                 final height = index.isEven ? 200.0 : 260.0;
//                 return _buildPostCardShimmer(height);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPostCardShimmer(double height) {
//     final baseColor = Colors.grey[300]!;
//     final highlightColor = Colors.grey[100]!;
//     return Shimmer.fromColors(
//       baseColor: baseColor,
//       highlightColor: highlightColor,
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(UiConstants.radiusMd),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const CircleAvatar(
//                         radius: 10,
//                         backgroundColor: Colors.white,
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         width: 80,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(
//                             UiConstants.spacingSm,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     width: double.infinity,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(
//                         UiConstants.spacingSm,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _FilterChip extends StatelessWidget {
//   final SearchFilter filter;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _FilterChip({
//     required this.filter,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
//         decoration: BoxDecoration(
//           color: isActive
//               ? Theme.of(context).colorScheme.primaryContainer
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isActive) ...[
//               const Icon(Icons.check, size: 16, color: Colors.black),
//               const SizedBox(width: 6),
//             ],
//             Text(
//               filter.name,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//                 color: isActive ? Colors.black87 : Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// enum SearchFilter { all, people, hotels, posts }

// ─────────────────────────────────────────────────────────────────
// features/search/presentation/pages/search_page.dart
// ─────────────────────────────────────────────────────────────────

import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/auto_marquee_text.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/search/domain/entities/search_result.dart';
import 'package:app/features/search/presentation/bloc/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

// ── Filter enum ───────────────────────────────────────────────────
enum SearchFilter { all, people, hotels, posts }

// ─────────────────────────────────────────────────────────────────
// Entry — BlocProvider wrapper (mirrors LibraryPage pattern)
// ─────────────────────────────────────────────────────────────────
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = DependencyInjection.get<AuthService>();
    final userId = authService.getCurrentUserId();

    if (userId == null) {
      return const Scaffold(body: Center(child: LoadingWidget()));
    }

    return BlocProvider(
      create: (_) =>
          DependencyInjection.get<SearchBloc>()
            ..add(LoadDiscoveryFeed(currentUserId: userId)),
      child: _SearchView(currentUserId: userId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Main view
// ─────────────────────────────────────────────────────────────────
class _SearchView extends StatefulWidget {
  final String currentUserId;
  const _SearchView({required this.currentUserId});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();

  // ── helpers ────────────────────────────────────────────────────

  SearchFilter _activeFilter(SearchState state) {
    if (state is SearchDiscoveryLoaded) return state.activeFilter;
    if (state is SearchResultsLoaded) return state.activeFilter;
    return SearchFilter.all;
  }

  SearchResult? _result(SearchState state) {
    if (state is SearchDiscoveryLoaded) return state.result;
    if (state is SearchResultsLoaded) return state.result;
    return null;
  }

  String? _activeQuery(SearchState state) {
    if (state is SearchResultsLoaded) return state.query;
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final filter = _activeFilter(state);
        final result = _result(state);
        final query = _activeQuery(state);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Sticky header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 100 + UiConstants.spacingLg,
                collapsedHeight: 100 + UiConstants.spacingLg,
                foregroundColor: Colors.white,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _SearchHeader(
                    controller: _controller,
                    activeFilter: filter,
                    currentUserId: widget.currentUserId,
                  ),
                ),
              ),

              // ── Body ──────────────────────────────────────────
              if (state is SearchLoading || state is SearchInitial)
                const _ShimmerGrid()
              else if (state is SearchError)
                _ErrorSliver(message: state.message)
              else if (result != null && result.isEmpty)
                _EmptySliver(query: query)
              else if (result != null)
                _ResultsSliver(
                  result: result,
                  filter: filter,
                  isSearchMode: state is SearchResultsLoaded,
                  currentUserId: widget.currentUserId,
                )
              else
                const _ShimmerGrid(),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sticky search header with filter chips
// ─────────────────────────────────────────────────────────────────
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final SearchFilter activeFilter;
  final String currentUserId;

  const _SearchHeader({
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

// ─────────────────────────────────────────────────────────────────
// Results dispatcher
// ─────────────────────────────────────────────────────────────────
// class _ResultsSliver extends StatelessWidget {
//   final SearchResult result;
//   final SearchFilter filter;
//   final bool isSearchMode;

//   const _ResultsSliver({
//     required this.result,
//     required this.filter,
//     required this.isSearchMode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     print(result.organizations.length);
//     print(result.posts.length);
//     print(result.users.length);
//     return switch (filter) {
//       SearchFilter.all => _AllResultsSliver(
//         result: result,
//         isSearchMode: isSearchMode,
//       ),
//       SearchFilter.people => _PeopleListSliver(users: result.users),
//       SearchFilter.hotels => _HotelsGridSliver(orgs: result.organizations),
//       SearchFilter.posts => _PostsMasonrySliver(posts: result.posts),
//     };
//   }
// }

class _ResultsSliver extends StatelessWidget {
  final SearchResult result;
  final SearchFilter filter;
  final bool isSearchMode;
  final String currentUserId;

  const _ResultsSliver({
    required this.result,
    required this.filter,
    required this.isSearchMode,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final slivers = switch (filter) {
      SearchFilter.all => _buildAllSlivers(result, isSearchMode, currentUserId),
      SearchFilter.people => [
        _PeopleListSliver(users: result.users, currentUserId: currentUserId),
      ],
      SearchFilter.hotels => [_HotelsGridSliver(orgs: result.organizations)],
      SearchFilter.posts => [
        _PostsMasonrySliver(posts: result.posts, currentUserId: currentUserId),
      ],
    };

    return SliverMainAxisGroup(slivers: slivers);
  }
}

List<Widget> _buildAllSlivers(
  SearchResult result,
  bool isSearchMode,
  String currentUserId,
) {
  final List<Widget> slivers = [];

  if (result.users.isNotEmpty) {
    slivers.add(
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: isSearchMode ? 'People' : 'Suggested People',
              icon: Icons.people_outline,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConstants.spacingMd,
              ),
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiConstants.spacingMd,
                    vertical: UiConstants.spacingSm,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: result.users.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: UiConstants.spacingMd),
                  itemBuilder: (_, i) => _UserBubble(
                    user: result.users[i],
                    currentUserId: currentUserId,
                  ),
                ),
              ),
            ),
            // const SizedBox(height: UiConstants.spacingMd),
          ],
        ),
      ),
    );
  }

  if (result.organizations.isNotEmpty) {
    slivers.add(
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: isSearchMode ? 'Hotels' : 'Featured Hotels',
              icon: Icons.hotel_outlined,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConstants.spacingMd,
              ),
              child: SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: result.organizations.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: UiConstants.spacingXs),
                  itemBuilder: (_, i) =>
                      _HotelCard(org: result.organizations[i])
                          .animate(delay: (i * 80).ms)
                          .slideX(
                            begin: i.isEven ? -0.3 : 0.3,
                            duration: UiConstants.animationSlow,
                            curve: Curves.easeOutCubic,
                          )
                          .scale(
                            begin: const Offset(0.9, 1),
                            duration: UiConstants.animationSlow,
                            curve: Curves.easeInOut,
                          )
                          .fade(duration: UiConstants.animationSlow),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  if (result.posts.isNotEmpty) {
    slivers.add(
      SliverToBoxAdapter(
        child: _SectionHeader(
          title: isSearchMode ? 'Posts' : 'Trending Posts',
          icon: Icons.grid_view_outlined,
        ),
      ),
    );
    slivers.add(
      _PostsMasonrySliver(posts: result.posts, currentUserId: currentUserId),
    );
  }

  return slivers;
}

// ─────────────────────────────────────────────────────────────────
// "All" — stacked sections: users row, hotels row, posts grid
// ─────────────────────────────────────────────────────────────────
class _AllResultsSliver extends StatelessWidget {
  final SearchResult result;
  final String currentUserId;
  final bool isSearchMode;

  const _AllResultsSliver({
    required this.result,
    required this.isSearchMode,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // ── People row ──────────────────────────────────────────
        if (result.users.isNotEmpty) ...[
          _SectionHeader(
            title: isSearchMode ? 'People' : 'Suggested People',
            icon: Icons.people_outline,
          ),
          SizedBox(
            height: 110,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConstants.spacingMd,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: result.users.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: UiConstants.spacingMd),
              itemBuilder: (_, i) => _UserBubble(
                user: result.users[i],
                currentUserId: currentUserId,
              ),
            ),
          ),
          const SizedBox(height: UiConstants.spacingMd),
        ],

        // ── Hotels row ──────────────────────────────────────────
        if (result.organizations.isNotEmpty) ...[
          _SectionHeader(
            title: isSearchMode ? 'Hotels' : 'Featured Hotels',
            icon: Icons.hotel_outlined,
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: result.organizations.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: UiConstants.spacingSm),
              itemBuilder: (_, i) =>
                  _HotelGridCard(org: result.organizations[i])
                      .animate(delay: (i * 80).ms)
                      .slideY(
                        begin: i.isEven ? -0.3 : 0.3,
                        duration: UiConstants.animationSlow,
                        curve: Curves.easeOutCubic,
                      )
                      .scale(
                        begin: const Offset(0.9, 1),
                        duration: UiConstants.animationSlow,
                        curve: Curves.easeInOut,
                      )
                      .fade(duration: UiConstants.animationSlow),
            ),
          ),
          const SizedBox(height: UiConstants.spacingMd),
        ],

        // ── Posts header (grid rendered in next sliver) ─────────
        if (result.posts.isNotEmpty) ...[
          _SectionHeader(
            title: isSearchMode ? 'Posts' : 'Trending Posts',
            icon: Icons.grid_view_outlined,
          ),
          _PostsMasonrySliver(
            posts: result.posts,
            currentUserId: currentUserId,
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Posts masonry sliver
// ─────────────────────────────────────────────────────────────────
class _PostsMasonrySliver extends StatelessWidget {
  final List<Post> posts;
  final String currentUserId;
  const _PostsMasonrySliver({required this.posts, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No posts found')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: UiConstants.spacingSm,
        crossAxisSpacing: UiConstants.spacingSm,
        childCount: posts.length,
        itemBuilder: (context, i) =>
            _PostCard(
                  post: posts[i],
                  height: i.isEven ? 200.0 : 260.0,
                  currentUserId: currentUserId,
                )
                .animate(delay: (i * 80).ms)
                .slideX(
                  begin: i.isEven ? -0.3 : 0.3,
                  duration: UiConstants.animationSlow,
                  curve: Curves.easeOutCubic,
                )
                .scale(
                  begin: const Offset(0.9, 1),
                  duration: UiConstants.animationSlow,
                  curve: Curves.easeInOut,
                )
                .fade(duration: UiConstants.animationSlow),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// People list sliver (People tab)
// ─────────────────────────────────────────────────────────────────
class _PeopleListSliver extends StatelessWidget {
  final List<User> users;
  final String currentUserId;

  const _PeopleListSliver({required this.users, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No people found')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
      sliver: SliverList.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (_, i) =>
            _UserListTile(user: users[i], currentUserId: currentUserId),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hotels grid sliver (Hotels tab)
// ─────────────────────────────────────────────────────────────────
class _HotelsGridSliver extends StatelessWidget {
  final List<Organization> orgs;
  const _HotelsGridSliver({required this.orgs});

  @override
  Widget build(BuildContext context) {
    if (orgs.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No hotels found')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: UiConstants.spacingSm,
          crossAxisSpacing: UiConstants.spacingSm,
          childAspectRatio: 0.85,
        ),
        itemCount: orgs.length,
        itemBuilder: (context, i) {
          final org = orgs[i];

          return _HotelGridCard(org: org)
              .animate(delay: (i * 80).ms)
              .slideX(
                begin: i.isEven ? -0.3 : 0.3,
                duration: UiConstants.animationSlow,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.9, 1),
                duration: UiConstants.animationSlow,
                curve: Curves.easeInOut,
              )
              .fade(duration: UiConstants.animationSlow);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConstants.spacingMd,
        UiConstants.spacingMd,
        UiConstants.spacingMd,
        UiConstants.spacingSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// User bubble — horizontal scroll in "All" tab
// Uses User.fullName, User.imageUrl
// ─────────────────────────────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  final User user;
  final String currentUserId;

  const _UserBubble({required this.user, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (user.userId == currentUserId) {
          context.go(RouteConstants.profilePage);
        } else {
          context.push(
            RouteConstants.viewUserProfilePage,
            extra: {'userId': user.userId, 'currentUserId': currentUserId},
          );
        }
      },
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                  radius: 28,
                  // backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage:
                      user.imageUrl != null && user.imageUrl!.isNotEmpty
                      ? NetworkImage(user.imageUrl!)
                      : null,
                  child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                )
                .animate(delay: UiConstants.animationFast)
                .scale(duration: UiConstants.animationNormal),
            AutoMarqueeText(
              text: user.fullName,
              style: const TextStyle(fontSize: 12),
            ),
            // // Show role badge
            // Container(
            //   margin: const EdgeInsets.only(top: 2),
            //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.secondaryContainer,
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Text(
            //     user.role.name,
            //     style: TextStyle(
            //       fontSize: 9,
            //       color: Theme.of(context).colorScheme.onSecondaryContainer,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// User list tile — People tab
// ─────────────────────────────────────────────────────────────────
class _UserListTile extends StatelessWidget {
  final User user;
  final String currentUserId;
  const _UserListTile({required this.user, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: UiConstants.spacingXs,
      ),
      leading:
          CircleAvatar(
                radius: 24,
                backgroundImage: user.imageUrl != null
                    ? NetworkImage(user.imageUrl!)
                    : null,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: user.imageUrl == null
                    ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              )
              .animate(delay: UiConstants.animationFast)
              .scale(duration: UiConstants.animationNormal),
      title: Text(
        user.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        user.role.name,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: user.organizationId != null
          ? const Icon(Icons.business_outlined, size: 18, color: Colors.grey)
          : null,
      onTap: () {
        if (user.userId == currentUserId) {
          context.go(RouteConstants.profilePage);
        } else {
          context.push(
            RouteConstants.viewUserProfilePage,
            extra: {'userId': user.userId, 'currentUserId': currentUserId},
          );
        }
      },
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Organization org;
  const _HotelCard({required this.org});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: 160,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey.shade400,
                child: org.logoUrl != null
                    ? Image.network(
                        org.logoUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            const _Placeholder(icon: Icons.hotel),
                      )
                    : Center(
                        child:
                            CircleAvatar(
                                  radius: 50,
                                  child: Text(
                                    _getInitialCharactrOfOrganization(org.name),
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                .animate(delay: UiConstants.animationFast)
                                .scale(duration: UiConstants.animationNormal),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (org.address != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: Colors.grey[600],
                        ),
                        Expanded(
                          child: Text(
                            org.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (org.phone != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 11,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          org.phone!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hotel grid card — Hotels tab
// ─────────────────────────────────────────────────────────────────
class _HotelGridCard extends StatelessWidget {
  final Organization org;
  const _HotelGridCard({required this.org});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade400,
              child: org.logoUrl != null
                  ? Image.network(
                      org.logoUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          const _Placeholder(icon: Icons.hotel),
                    )
                  : Center(
                      child:
                          CircleAvatar(
                                radius: 50,
                                child: Text(
                                  _getInitialCharactrOfOrganization(org.name),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              .animate(delay: UiConstants.animationFast)
                              .scale(duration: UiConstants.animationNormal),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (org.address != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: Colors.grey[600],
                      ),
                      Expanded(
                        child: Text(
                          org.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (org.phone != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 11,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        org.phone!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Post masonry card
// Uses Post.title, .primaryImageUrl, .price, .roomType, .tags,
//         .createdBy (manager id — shows initials)
// ─────────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Post post;
  final double height;
  final String currentUserId;
  const _PostCard({
    required this.post,
    required this.height,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          RouteConstants.postDetailsPage,
          extra: {'postId': post.id, 'post': post, 'userId': currentUserId},
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(UiConstants.radiusMd),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      post.primaryImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _Placeholder(icon: Icons.image_outlined),
                    ),
                    // Price badge
                    if (post.price != null)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '\$${post.price!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    // Room type badge
                    if (post.roomType != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.roomType!.name,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Footer ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tags row
                  if (post.tags != null && post.tags!.isNotEmpty)
                    SizedBox(
                      height: 18,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.tags!.length.clamp(0, 3),
                        separatorBuilder: (_, __) => const SizedBox(width: 4),
                        itemBuilder: (_, i) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.tags![i].name,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Capacity / area stats
                  Row(
                    children: [
                      if (post.capacity != null) ...[
                        const Icon(
                          Icons.people_outline,
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${post.capacity}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (post.area != null) ...[
                        const Icon(
                          Icons.square_foot,
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${post.area!.toStringAsFixed(0)} m²',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ],
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

// ─────────────────────────────────────────────────────────────────
// Placeholder image
// ─────────────────────────────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  final IconData icon;
  const _Placeholder({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(child: Icon(icon, color: Colors.grey[400], size: 32)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Shimmer loading grid
// ─────────────────────────────────────────────────────────────────
class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: UiConstants.spacingSm,
        crossAxisSpacing: UiConstants.spacingSm,
        childCount: 10,
        itemBuilder: (context, index) {
          final height = index.isEven ? 200.0 : 260.0;
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
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
                    padding: const EdgeInsets.all(8),
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
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────
class _EmptySliver extends StatelessWidget {
  final String? query;
  const _EmptySliver({this.query});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: UiConstants.spacingMd),
          Text(
            query != null ? 'No results for "$query"' : 'Nothing to show yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: UiConstants.spacingSm),
          Text(
            'Try a different keyword or filter',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────
class _ErrorSliver extends StatelessWidget {
  final String message;
  const _ErrorSliver({required this.message});

  @override
  Widget build(BuildContext context) {
    print(message);
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: UiConstants.spacingMd),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: UiConstants.spacingSm),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.spacingLg,
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

String _getInitialCharactrOfOrganization(String name) {
  return name
      .trim()
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .join();
}
