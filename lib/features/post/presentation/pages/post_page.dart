import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/post/presentation/bloc/posts_bloc.dart';
import 'package:app/features/post/presentation/pages/dummy_post_page.dart';
import 'package:app/features/post/presentation/widgets/post_grid_section.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  UserRole? _role;
  String? _userId;
  String? _organizationId;
  String? _errorMessage;
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadUserContext();
  }

  Future<void> _loadUserContext() async {
    try {
      final postServices = DependencyInjection.get<PostServices>();
      final role = await postServices.getCurrentUserRole();
      final userId = postServices.getRequiredUserId();
      final organizationId = await postServices.getCurrentUserOrganizationId();

      if (!mounted) return;

      setState(() {
        _role = role;
        _userId = userId;
        _organizationId = organizationId;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: $_errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // ─── For Workers or Normal Users ───────────────────────────────
    if (_role == UserRole.worker || _role == UserRole.user) {
      return const DummyPostPage();
    }

    // ─── For Organization Admin ────────────────────────────────────
    return BlocProvider(
      create: (_) => DependencyInjection.get<OrganizationPostsBloc>()
        ..add(
          FetchOrganizationPosts(
            userId: _userId,
            organizationId: _organizationId!,
          ),
        ),
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: CustomTextField(
                hint: 'Search posts...',
                controller: _searchController,
                prefixIcon: const Icon(Icons.search),
                onChanged: (value) => setState(() {}),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Column(
                    children: [
                      Icon(
                        _tabController.index == 0
                            ? Icons.grid_view_rounded
                            : Icons.grid_view_outlined,
                      ),
                      const Text('All Posts'),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    children: [
                      Icon(
                        _tabController.index == 1
                            ? Icons.movie
                            : Icons.movie_outlined,
                      ),
                      const Text('Videos'),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    children: [
                      Icon(
                        _tabController.index == 2
                            ? Icons.photo_library
                            : Icons.photo_library_outlined,
                      ),
                      const Text('Images'),
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsList(),
                  const Center(child: Text('Videos only will appear here')),
                  const Center(child: Text('Images & Videos will appear here')),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push(
              RouteConstants.createPostPage,
              extra: {'userId': _userId, 'organizationId': _organizationId},
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Post'),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
      builder: (context, state) {
        if (state is OrganizationPostsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrganizationPostsLoaded) {
          final posts = state.posts
              .where(
                (p) =>
                    p.title.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

          if (posts.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }

          return PostGridSection(
            posts: state.posts
                .map(
                  (p) => {
                    'title': p.title,
                    'imageUrl': p.primaryImageUrl,
                    'videoUrl': p.videoUrl,
                    'description': p.description,
                    'price': p.price,
                  },
                )
                .toList(),
          );

          // return ListView.builder(
          //   itemCount: posts.length,
          //   itemBuilder: (context, index) {
          //     final post = posts[index];
          //     return ListTile(
          //       leading: post.primaryImageUrl != null
          //           ? Image.network(post.primaryImageUrl!, width: 60)
          //           : const Icon(Icons.image_not_supported),
          //       title: Text(post.title),
          //       subtitle: Text(post.description ?? 'No description'),
          //     );
          //   },
          // );
        } else if (state is OrganizationPostsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader() {
    final roleMessage = _role == UserRole.admin
        ? 'As a manager, you can create, update, and manage posts.'
        : 'As a staff, you can view and assist in post-related tasks.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundImage: NetworkImage(
              'https://eucadoxgijhmbpjlypmn.supabase.co/storage/v1/object/public/post-images/6fd1c9a6-dc5c-4c50-beb6-6ec1080bcc23/temp/1762880945943.jpg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ABC Organization',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _role.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(color: Colors.blueAccent),
                ),
                const SizedBox(height: 6),
                Text(
                  roleMessage,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
