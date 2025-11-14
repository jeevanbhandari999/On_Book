import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_by_organization_id_use_case.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_images_by_orgnization_id.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_videos_by_organization_id.dart';
import 'package:app/features/post/presentation/bloc/posts_bloc.dart';
import 'package:app/features/post/presentation/pages/dummy_post_page.dart';
import 'package:app/features/post/presentation/widgets/post_grid_section.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizationPostsBloc(
        getAllPostsByOrganizationId:
            DependencyInjection.get<GetAllPostsByOrganizationIdUseCase>(),
        getAllPostsWithImagesByOrganizationId:
            DependencyInjection.get<
              GetAllPostsWithImagesByOrganizationIdUseCase
            >(),
        getAllPostsWithVideosByOrganizationId:
            DependencyInjection.get<GetAllPostsWithVideosByOrganizationId>(),
        postServices: DependencyInjection.get<PostServices>(),
      )..add(const ChecKUserRoleAndOrganizationDetailStatus()),
      child: const PostView(),
    );
  }
}

class PostView extends StatelessWidget {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OrganizationPostsBloc, OrganizationPostsState>(
        listener: (context, state) {
          if (state is AdminLoggedIn) {
            context.go(RouteConstants.anotherPage);
          }
          if (state is ManagerOrStaffLoggedInWithOutJoiningOrganization) {
            context.go(RouteConstants.anotherPage);
          }
          // if (state is GeneralUserLoggedIn) {
          //   context.go(RouteConstants.dummyPostPage);
          // }
        },
        builder: (context, state) {
          if (state is OrganizationPostsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrganizationOwnerLoggedIn) {
            final user = state.user;
            final organization = state.organization;
            return Center(
              child: Text(
                'Owner logged in: ${user.fullName} and ${organization.name}',
              ),
            );
          } else if (state is OrganizationManagerLoggedIn) {
            final user = state.user;
            final organization = state.organization;
            return Center(
              child: Text(
                'Manager logged in: ${user.fullName} and ${organization.name}',
              ),
            );
          } else if (state is OrganizationStaffLoggedIn) {
            final user = state.user;
            final organization = state.organization;
            return Center(
              child: Text(
                'Staff logged in: ${user.fullName} and ${organization.name}',
              ),
            );
          } else if (state
              is ManagerOrStaffLoggedInWithOutJoiningOrganization) {
            return Text('hello');
          } else if (state is GeneralUserLoggedIn) {
            return const DummyPostPage();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// class PostView extends StatefulWidget {
//   const PostView({super.key});

//   @override
//   State<PostView> createState() => _PostViewState();
// }

// class _PostViewState extends State<PostView>
//     with SingleTickerProviderStateMixin {
//   bool _isLoading = true;
//   UserRole? _role;
//   String? _userId;
//   String? _organizationId;
//   String? _errorMessage;
//   late TabController _tabController;
//   final _searchController = TextEditingController();
//   String _searchQuery = '';
//   Organization? _organizationDetails;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserContext();
//     _loadOrganizationDetails();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         if (_organizationId != null) {
//           _handleTabChange(_tabController.index);
//         }
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_organizationId != null) {
//         _handleTabChange(_tabController.index);
//       }
//     });
//   }

//   void _handleTabChange(int index) {
//     if (_organizationId == null) return;
//     final bloc = context.read<OrganizationPostsBloc>();
//     switch (index) {
//       case 0:
//         bloc.add(FetchOrganizationPosts(organizationId: _organizationId!));
//         break;
//       case 1:
//         bloc.add(
//           FetchOrganizationPostsWithVideos(organizationId: _organizationId!),
//         ); // Assuming you have this event
//         break;
//       case 2:
//         bloc.add(
//           FetchOrganizationPostsWithImages(organizationId: _organizationId!),
//         );
//         break;
//     }
//   }

//   Future<void> _loadOrganizationDetails() async {
//     try {
//       final postServices = DependencyInjection.get<PostServices>();
//       final organizationDetailsModel = await postServices
//           .getCurrentUserOrganization();
//       if (!mounted) return;
//       if (organizationDetailsModel != null) {
//         setState(() {
//           _organizationDetails = organizationDetailsModel.toEntity();
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//     }
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
//       context.read<OrganizationPostsBloc>().add(
//         FetchOrganizationPosts(organizationId: _organizationId!),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.removeListener(() {});
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     // For Workers or Normal Users
//     if (_role == UserRole.worker || _role == UserRole.user) {
//       return const DummyPostPage();
//     }

//     if (_errorMessage != null && _role != null) {
//       return Scaffold(
//         body: Center(child: _buildErrorState(message: _errorMessage!)),
//       );
//     }

//     // For Organization Admin
//     return Scaffold(
//       body: BlocListener<OrganizationPostsBloc, OrganizationPostsState>(
//         listener: (context, state) {
//           if (state is OrganizationPostsError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//                 action: SnackBarAction(
//                   label: 'Retry',
//                   onPressed: () => _onRefresh(context),
//                 ),
//               ),
//             );
//           }
//         },
//         child: Column(
//           children: [
//             _buildHeader(),
//             const SizedBox(height: UiConstants.spacingSm),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                       text: 'Manage Organization',
//                       onPressed: () {
//                         // TODO: Manage organization
//                         ScaffoldMessenger.of(context).clearSnackBars();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Manage posts coming soon'),
//                           ),
//                         );
//                       },
//                       icon: const Icon(Icons.apartment_rounded),
//                     ),
//                   ),
//                   const SizedBox(width: UiConstants.spacingSm),
//                   Expanded(
//                     child: CustomButton(
//                       text: 'Manage Posts',
//                       onPressed: () {
//                         // TODO: Manage posts
//                         ScaffoldMessenger.of(context).clearSnackBars();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Manage posts coming soon'),
//                           ),
//                         );
//                       },
//                       icon: const Icon(Icons.dashboard_customize_rounded),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: CustomTextField(
//                 hint: 'Search posts...',
//                 controller: _searchController,
//                 prefixIcon: const Icon(Icons.search),
//                 onChanged: (value) => setState(() {}),
//               ),
//             ),
//             Divider(
//               height: 1,
//               thickness: 1,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             TabBar(
//               controller: _tabController,
//               indicatorColor: Theme.of(context).primaryColor,
//               indicatorSize: TabBarIndicatorSize.tab,
//               unselectedLabelStyle: const TextStyle(fontSize: 12),
//               indicator: const BoxDecoration(),
//               tabs: [
//                 _buildTab(
//                   index: 0,
//                   selectedIcon: Icons.grid_view_rounded,
//                   unselectedIcon: Icons.grid_view_outlined,
//                   label: 'All Posts',
//                 ),
//                 _buildTab(
//                   index: 1,
//                   selectedIcon: Icons.movie,
//                   unselectedIcon: Icons.movie_outlined,
//                   label: 'Videos',
//                 ),
//                 _buildTab(
//                   index: 2,
//                   selectedIcon: Icons.photo_library,
//                   unselectedIcon: Icons.photo_library_outlined,
//                   label: 'Images',
//                 ),
//               ],
//             ),
//             Divider(
//               height: 1,
//               thickness: 1,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildPostsList(),
//                   _buildPostVideos(),
//                   _buildPostImages(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: CustomButton(
//         text: 'Create Post',
//         onPressed: () {
//           context.push(
//             RouteConstants.createPostPage,
//             extra: {'userId': _userId, 'organizationId': _organizationId},
//           );
//         },
//         icon: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildTab({
//     required int index,
//     required IconData selectedIcon,
//     required IconData unselectedIcon,
//     required String label,
//   }) {
//     return Tab(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _tabController,
//             builder: (context, child) {
//               final isSelected = _tabController.index == index;
//               return Icon(isSelected ? selectedIcon : unselectedIcon);
//             },
//           ),
//           Text(label),
//         ],
//       ),
//     );
//   }

//   Widget _buildPostsList() {
//     return BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
//       builder: (context, state) {
//         if (state is OrganizationPostsLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is OrganizationPostsLoaded) {
//           final posts = state.posts
//               .where(
//                 (p) =>
//                     p.title.toLowerCase().contains(_searchQuery.toLowerCase()),
//               )
//               .toList();

//           if (posts.isEmpty) {
//             // return _buildErrorState(
//             //   message: 'Failed to fetch the posts images.',
//             //   description:
//             //       'Please try to refresh, if you still get this kind of error then please login again and check it out.',
//             // );
//             return _buildEmptyState(
//               title: 'No Posts Found',
//               canManageOrganization:
//                   _role == UserRole.admin ||
//                   _role == UserRole.owner ||
//                   _role == UserRole.manager,
//               content:
//                   _role == UserRole.admin ||
//                       _role == UserRole.owner ||
//                       _role == UserRole.manager
//                   ? 'Create Your first post to get started.'
//                   : 'Come back later to check the upcomig posts.',
//             );
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: PostGridSection(
//               posts: state.posts
//                   .map(
//                     (p) => {
//                       'title': p.title,
//                       'imageUrl': p.primaryImageUrl,
//                       'videoUrl': p.videoUrl,
//                       'description': p.description,
//                       'price': p.price,
//                       // to determine whether the posts is is all, video , images
//                       'all': true,
//                     },
//                   )
//                   .toList(),
//             ),
//           );
//         } else if (state is OrganizationPostsError) {
//           return _buildErrorState(message: 'Failed to fetch the posts.');
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildPostVideos() {
//     return BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
//       builder: (context, state) {
//         if (state is OrganizationPostsLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is OrganizationPostsVideosLoaded) {
//           final postsWithImages = state.postVideos;
//           final postsOnly = state.posts;

//           if (postsWithImages.isEmpty) {
//             return _buildEmptyState(
//               title: 'No Posts Found',
//               canManageOrganization:
//                   _role == UserRole.admin ||
//                   _role == UserRole.owner ||
//                   _role == UserRole.manager,
//               description:
//                   'You haven\'t create any posts yet, try to add some posts and check it out.',
//               content:
//                   _role == UserRole.admin ||
//                       _role == UserRole.owner ||
//                       _role == UserRole.manager
//                   ? 'Create Your first post to get started.'
//                   : 'Come back later to check the upcomig posts.',
//             );
//           }

//           // Create map: postId → full Post
//           final postMap = {for (var post in postsOnly) post.id: post};

//           // Flatten: one card per image, with full post data
//           final cardItems = postsWithImages
//               .map((vid) {
//                 final post = postMap[vid.postId];
//                 if (post == null) return null; // safety

//                 return {
//                   'title': post.title,
//                   'imageUrl': null, // Since we are only showing videos here..
//                   'videoUrl': vid.videoUrl,
//                   'description': post.description ?? '',
//                   'price': post.price,
//                   'postId': post.id,
//                   // to determine whether the posts is is all, video , images
//                   'all': false,
//                 };
//               })
//               .whereType<Map<String, dynamic>>()
//               .toList();

//           if (cardItems.isEmpty) {
//             return _buildEmptyState(
//               title: 'No Posts Found',
//               canManageOrganization:
//                   _role == UserRole.admin ||
//                   _role == UserRole.owner ||
//                   _role == UserRole.manager,
//               description:
//                   'You haven\'t create any posts yet, try to add some posts and check it out.',
//               content:
//                   _role == UserRole.admin ||
//                       _role == UserRole.owner ||
//                       _role == UserRole.manager
//                   ? 'Create Your first post to get started.'
//                   : 'Come back later to check the upcomig posts.',
//             );
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: PostGridSection(posts: cardItems),
//           );
//         } else if (state is OrganizationPostsError) {
//           return _buildErrorState(message: 'Failed to fetch the posts videos.');
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildPostImages() {
//     return BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
//       builder: (context, state) {
//         if (state is OrganizationPostsLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is OrganizationPostsImagesLoaded) {
//           final postsWithImages = state.postImages;
//           final postsOnly = state.posts;

//           if (postsWithImages.isEmpty) {
//             return _buildEmptyState(
//               title: 'No Posts Found',
//               canManageOrganization:
//                   _role == UserRole.admin ||
//                   _role == UserRole.owner ||
//                   _role == UserRole.manager,
//               description:
//                   'You haven\'t create any posts yet, try to add some posts and check it out.',
//               content:
//                   _role == UserRole.admin ||
//                       _role == UserRole.owner ||
//                       _role == UserRole.manager
//                   ? 'Create Your first post to get started.'
//                   : 'Come back later to check the upcomig posts.',
//             );
//           }

//           // Create map: postId → full Post
//           final postMap = {for (var post in postsOnly) post.id: post};

//           // Flatten: one card per image, with full post data
//           final cardItems = postsWithImages
//               .map((img) {
//                 final post = postMap[img.postId];
//                 if (post == null) return null; // safety

//                 return {
//                   'title': post.title,
//                   'imageUrl': img.imageUrl,
//                   'videoUrl': null, // Since we are only showing images here..
//                   'description': post.description ?? '',
//                   'price': post.price,
//                   'postId': post.id,
//                   // to determine whether the posts is is all, video , images
//                   'all': false,
//                 };
//               })
//               .whereType<Map<String, dynamic>>()
//               .toList();

//           if (cardItems.isEmpty) {
//             return const Center(child: Text('No valid posts with images.'));
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: PostGridSection(posts: cardItems),
//           );
//         } else if (state is OrganizationPostsError) {
//           return _buildErrorState(message: 'Failed to fetch the posts images.');
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildErrorState({required String message, String? description}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Semantics(
//         label: message,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Semantics(
//                 image: true,
//                 label: 'Error icon',
//                 child: Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: Theme.of(context).colorScheme.error,
//                 ),
//               ),
//               const SizedBox(height: UiConstants.spacingMd),
//               Text(
//                 'Something went wrong',
//                 style: Theme.of(context).textTheme.headlineSmall,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: UiConstants.spacingSm),
//               if (description != null)
//                 Text(
//                   description,
//                   style: Theme.of(context).textTheme.headlineSmall,
//                   textAlign: TextAlign.center,
//                 ),
//               const SizedBox(height: UiConstants.spacingSm),
//               Text(
//                 message,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: UiConstants.spacingLg),
//               Semantics(
//                 label: 'Try again',
//                 hint: message,
//                 button: true,
//                 child: CustomButton(
//                   text: 'Try Again',
//                   onPressed: () => _onRefresh(context),
//                   icon: const Icon(Icons.refresh),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState({
//     required String title,
//     required bool canManageOrganization,
//     required String content,
//     String? description,
//   }) {
//     return Semantics(
//       label: title,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Semantics(
//               image: true,
//               label: 'No post icon',
//               child: Icon(
//                 Icons.hourglass_empty,
//                 size: 64,
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: UiConstants.spacingMd),
//             Text(title, style: Theme.of(context).textTheme.headlineSmall),
//             const SizedBox(height: UiConstants.spacingSm),
//             Text(
//               content,
//               style: Theme.of(context).textTheme.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//             if (description != null)
//               Text(
//                 description,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//             if (canManageOrganization) ...[
//               const SizedBox(height: UiConstants.spacingLg),
//               CustomButton(
//                 text: 'Create Post',
//                 onPressed: () {},
//                 icon: const Icon(Icons.add),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     String roleMessage = '';
//     if (_role == UserRole.admin) {
//       roleMessage =
//           'As an admin you can manage all posts related to this application';
//     } else if (_role == UserRole.owner) {
//       roleMessage =
//           'As an owner you can create and manage all posts related to this organization';
//     } else if (_role == UserRole.manager) {
//       roleMessage =
//           'As a manager, you can create, update, and manage posts related to this organization';
//     } else if (_role == UserRole.worker) {
//       roleMessage =
//           'As a staff, you can view and assist in post-related tasks.';
//     }
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(8),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 68,
//             height: 68,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Container(
//                 color: Colors.blueAccent.shade100,
//                 child:
//                     (_organizationDetails!.logoUrl != null &&
//                         _organizationDetails!.logoUrl!.isNotEmpty)
//                     ? Image.network(
//                         _organizationDetails!.logoUrl!,
//                         fit: BoxFit.cover,
//                       )
//                     : Center(
//                         child: Text(
//                           _getInitialCharactrOfOrganization(
//                             _organizationDetails!.name,
//                           ),
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${_organizationDetails?.name}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   _role.toString().split('.').last.toUpperCase(),
//                   style: const TextStyle(color: Colors.blueAccent),
//                 ),
//                 Text(
//                   roleMessage,
//                   style: const TextStyle(fontSize: 13, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getInitialCharactrOfOrganization(String name) {
//     return name
//         .trim()
//         .split(' ')
//         .where((word) => word.isNotEmpty)
//         .map((word) => word[0].toUpperCase())
//         .join();
//   }

//   void _onRefresh(BuildContext context) {}
// }
