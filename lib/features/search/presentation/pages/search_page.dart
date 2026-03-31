import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/auto_marquee_text.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/home/presentation/widgets/post_card.dart';
// import 'package:app/features/home/presentation/widgets/post_card.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/search/domain/entities/search_filter_enum.dart';
import 'package:app/features/search/domain/entities/search_result.dart';
import 'package:app/features/search/presentation/bloc/search_bloc.dart';
import 'package:app/features/search/presentation/widgets/search_header.dart';
import 'package:app/features/search/presentation/widgets/search_shimmer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

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

        return RefreshIndicator(
          onRefresh: () async {
            context.read<SearchBloc>().add(
              LoadDiscoveryFeed(currentUserId: widget.currentUserId),
            );
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.primaryLight,
                  expandedHeight: 100 + UiConstants.spacingLg,
                  collapsedHeight: 100 + UiConstants.spacingLg,
                  foregroundColor: Colors.white,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: SearchHeader(
                      controller: _controller,
                      activeFilter: filter,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                ),

                if (state is SearchLoading || state is SearchInitial) ...[
                  const SliverFillRemaining(
                    hasScrollBody: true,
                    child: SearchShimmerView(),
                  ),
                ] else if (state is SearchError)
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
                  const SliverFillRemaining(
                    hasScrollBody: true,
                    child: SearchShimmerView(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
      SearchFilter.hotels => [
        _HotelsGridSliver(orgs: result.organizations, userId: currentUserId),
      ],
      SearchFilter.posts => [
        _PostsMasonrySliver(
          posts: result.posts,
          organizations: result.organizations,
          currentUserId: currentUserId,
        ),
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
                      _HotelCard(
                            org: result.organizations[i],
                            userId: currentUserId,
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
      _PostsMasonrySliver(
        posts: result.posts,
        organizations: result.organizations,
        currentUserId: currentUserId,
      ),
    );
  }

  return slivers;
}

// class _PostsMasonrySliver extends StatelessWidget {
//   final List<Post> posts;
//   final String currentUserId;
//   final List<Organization> organizations;
//   const _PostsMasonrySliver({
//     required this.posts,
//     required this.organizations,
//     required this.currentUserId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (posts.isEmpty) {
//       return const SliverFillRemaining(
//         child: Center(child: Text('No posts found')),
//       );
//     }
//     return SliverPadding(
//       padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
//       sliver: SliverMasonryGrid.count(
//         crossAxisCount: 2,
//         mainAxisSpacing: UiConstants.spacingSm,
//         crossAxisSpacing: UiConstants.spacingSm,
//         childCount: posts.length,
//         itemBuilder: (context, i) =>
//             _PostCard(
//                   post: posts[i],
//                   height: i.isEven ? 200.0 : 260.0,
//                   currentUserId: currentUserId,
//                 )
//                 .animate(delay: (i * 80).ms)
//                 .slideX(
//                   begin: i.isEven ? -0.3 : 0.3,
//                   duration: UiConstants.animationSlow,
//                   curve: Curves.easeOutCubic,
//                 )
//                 .scale(
//                   begin: const Offset(0.9, 1),
//                   duration: UiConstants.animationSlow,
//                   curve: Curves.easeInOut,
//                 )
//                 .fade(duration: UiConstants.animationSlow),
//         // PostCard(post: posts[i], organization: organization, userId: currentUserId)
//       ),
//     );
//   }
// }

class _PostsMasonrySliver extends StatelessWidget {
  final List<Post> posts;
  final String currentUserId;
  final List<Organization> organizations;

  const _PostsMasonrySliver({
    required this.posts,
    required this.organizations,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No posts found')),
      );
    }

    // ✅ Convert list → map once, O(1) lookup per post
    final orgMap = {for (final org in organizations) org.id: org};

    return SliverPadding(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: UiConstants.spacingSm,
        crossAxisSpacing: UiConstants.spacingSm,
        childCount: posts.length,
        itemBuilder: (context, i) {
          final post = posts[i];
          final organization = orgMap[post.organizationId]; // ✅ matched by id

          if (organization == null) {
            // Org not loaded yet — show placeholder
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          return PostCard(
                post: post,
                organization: organization,
                userId: currentUserId,
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
              .fade(duration: UiConstants.animationSlow);
        },
      ),
    );
  }
}

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

class _HotelsGridSliver extends StatelessWidget {
  final List<Organization> orgs;
  final String userId;
  const _HotelsGridSliver({required this.orgs, required this.userId});

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

          return _HotelGridCard(org: org, userId: userId)
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
          ],
        ),
      ),
    );
  }
}

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
  final String userId;
  const _HotelCard({required this.org, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: 160,
      child: InkWell(
        onTap: () {
          context.push(
            RouteConstants.organizationDetailsPageUserSide,
            extra: {'organizationId': org.id, 'userId': userId},
          );
        },
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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
                                      _getInitialCharactrOfOrganization(
                                        org.name,
                                      ),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hotel grid card — Hotels tab
// ─────────────────────────────────────────────────────────────────
class _HotelGridCard extends StatelessWidget {
  final Organization org;
  final String userId;
  const _HotelGridCard({required this.org, required this.userId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          RouteConstants.organizationDetailsPageUserSide,
          extra: {'organizationId': org.id, 'userId': userId},
        );
      },
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
                color: Theme.of(context).colorScheme.primaryContainer,
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
              // message,
              'Please try again in later.',
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
