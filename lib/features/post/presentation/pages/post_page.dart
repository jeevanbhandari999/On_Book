// import 'package:app/app/dependency_injection.dart';
// import 'package:app/app/router/route_constants.dart';
// import 'package:app/features/auth/data/models/user_model.dart';
// import 'package:app/features/post/presentation/pages/dummy_post_page.dart';
// import 'package:app/features/post/services/post_services.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class PostPage extends StatefulWidget {
//   const PostPage({super.key});

//   @override
//   State<PostPage> createState() => _PostPageState();
// }

// class _PostPageState extends State<PostPage> {
//   bool _isLoading = true;
//   UserRole? _role;
//   String? _userId;
//   String? _organizationId;
//   String? _errorMessage;
//   @override
//   void initState() {
//     super.initState();
//     _loadUserContext();
//   }

//   Future<void> _loadUserContext() async {
//     try {
//       final postServices = DependencyInjection.get<PostServices>();
//       final role = await postServices.getCurrentUserRole();
//       final userId = postServices.getRequiredUserId();
//       final organizationId = await postServices.getCurrentUserOrganizationId();

//       if (!mounted) return;

//       setState(() {
//         _role = role;
//         _userId = userId;
//         _organizationId = organizationId;
//         _isLoading = false;
//       });
//       // print('$userId, $organizationId');
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     if (_errorMessage != null) {
//       return Scaffold(
//         body: Center(
//           child: Text(
//             'Error: $_errorMessage',
//             style: const TextStyle(color: Colors.red),
//           ),
//         ),
//       );
//     }
//     if (_role == UserRole.worker || _role == UserRole.user) {
//       return const DummyPostPage();
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Post page')),
//       body: Center(
//         child: TextButton(
//           onPressed: () {
//             context.push(
//               RouteConstants.createPostPage,
//               extra: {'userId': _userId, 'organizationId': _organizationId},
//             );
//           },
//           child: const Text('Go to create page'),
//         ),
//       ),
//     );
//   }
// }

import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/post/presentation/bloc/posts_bloc.dart';
import 'package:app/features/post/presentation/pages/dummy_post_page.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isLoading = true;
  UserRole? _role;
  String? _userId;
  String? _organizationId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
            style: TextStyle(color: Colors.red),
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
        appBar: AppBar(title: const Text('Organization Posts')),
        body: BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
          builder: (context, state) {
            if (state is OrganizationPostsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrganizationPostsLoaded) {
              if (state.posts.isEmpty) {
                return const Center(child: Text('No posts yet.'));
              }
              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return ListTile(
                    leading: post.primaryImageUrl != null
                        ? Image.network(post.primaryImageUrl!, width: 60)
                        : const Icon(Icons.image_not_supported),
                    title: Text(post.title),
                    subtitle: Text(post.description ?? 'No description'),
                  );
                },
              );
            } else if (state is OrganizationPostsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
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
}
