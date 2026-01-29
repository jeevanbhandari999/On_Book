// import 'package:app/app/dependency_injection.dart';
// import 'package:app/app/router/route_constants.dart';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/features/auth/domain/entities/organization.dart';
// import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
// import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
// import 'package:app/features/home/presentation/bloc/home_bloc.dart';
// import 'package:app/features/post/domain/entities/post.dart';
// import 'package:app/features/post/domain/entities/post_enums.dart';
// import 'package:app/features/post/presentation/pages/post_details_page.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// class HomePage extends StatelessWidget {
//   final String userId;
//   final double? latitude;
//   final double? longitude;
//   const HomePage({
//     super.key,
//     required this.userId,
//     this.latitude,
//     this.longitude,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           HomeBloc(
//             getNearbyPostsUseCase:
//                 DependencyInjection.get<GetAllPostsNearByUserUseCase>(),
//             getOrganizationDetailByPostOrganizationIdUseCase:
//                 DependencyInjection.get<
//                   GetOrganizationDetailByPostOrganizationIdUseCase
//                 >(),
//           )..add(
//             FetchNearbyPosts(
//               userId: userId,
//               latitude: latitude,
//               //  ?? 27.986214,
//               longitude: longitude,
//               //  ?? 85.446681,
//             ),
//           ),
//       child: HomeView(userId: userId),
//     );
//   }
// }

// class HomeView extends StatelessWidget {
//   final String userId;
//   const HomeView({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: () async {
//           context.read<HomeBloc>().add(RefreshNearbyPosts(userId: userId));
//         },
//         child: BlocBuilder<HomeBloc, HomeState>(
//           builder: (context, state) {
//             if (state is HomeLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (state is HomeError) {
//               // print(state.message);
//               return Center(child: Text(state.message));
//             }

//             if (state is HomeLoaded) {
//               if (state.posts.isEmpty) {
//                 return const Center(child: Text("No posts found"));
//               }

//               return PageView.builder(
//                 scrollDirection: Axis.vertical,
//                 itemCount: state.posts.length,
//                 itemBuilder: (_, index) {
//                   final post = state.posts[index];
//                   final organization = state.organizations[post.organizationId];
//                   if (organization == null) {
//                     context.read<HomeBloc>().add(
//                       FetchOrganizationDetails(post.organizationId),
//                     );

//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   return _buildImagePageView(
//                     context,
//                     post,
//                     organization,
//                     userId,
//                   );
//                 },
//                 pageSnapping: false,
//                 physics: const AlwaysScrollableScrollPhysics(
//                   parent: ClampingScrollPhysics(),
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }
// }

// Widget _buildImagePageView(
//   BuildContext context,
//   Post post,
//   Organization organization,
//   String userId,
// ) {
//   return SizedBox.expand(
//     child: Stack(
//       fit: StackFit.expand,
//       children: [
//         Positioned.fill(
//           child: GestureDetector(
//             onTap: () {
//               context.push(
//                 RouteConstants.postDetailsPage,
//                 extra: {'postId': post.id, 'post': post, 'userId': userId},
//               );
//             },
//             child: CachedNetworkImage(
//               imageUrl: post.primaryImageUrl,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               placeholder: (context, url) =>
//                   const Center(child: CircularProgressIndicator()),
//               errorWidget: (context, url, error) =>
//                   const Center(child: Icon(Icons.error)),
//             ),
//           ),
//         ),
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Organization logo
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 60,
//                       height: 60,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Container(
//                           color: Colors.blueAccent.shade100,
//                           child:
//                               (organization.logoUrl != null &&
//                                   organization.logoUrl!.isNotEmpty)
//                               ? Image.network(
//                                   organization.logoUrl!,
//                                   fit: BoxFit.cover,
//                                 )
//                               : Center(
//                                   child: Text(
//                                     _getInitialCharactrOfOrganization(
//                                       organization.name,
//                                     ),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           organization.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           organization.address ?? '',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 // Just show the menu icon for now
//                 PopupMenuButton<String>(
//                   icon: const Icon(Icons.more_vert, color: Colors.white),
//                   elevation: 3,
//                   onSelected: (value) {
//                     // handle selection
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem<String>(
//                       value: 'message',
//                       child: Row(
//                         children: [
//                           Icon(Icons.chat, size: UiConstants.iconMd),
//                           SizedBox(width: UiConstants.spacingSm),
//                           Text('Message'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem<String>(
//                       value: 'vire_details',
//                       child: Row(
//                         children: [
//                           Icon(Icons.info, size: UiConstants.iconMd),
//                           SizedBox(width: UiConstants.spacingSm),
//                           Text('Details'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),

//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.all(8.0),
//             color: Colors.black54,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (post.additionalImagesForHomeFeed.isNotEmpty) ...[
//                   _buildImageStrip(post),
//                   const SizedBox(height: UiConstants.spacingSm),
//                 ],
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildTitleAndPriceSection(
//                       context,
//                       title: post.title,
//                       price: post.price!,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: getPostStatusColor(post.status),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Text(
//                         enumToString(post.status).toUpperCase(),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 _buildDescriptionSection(
//                   context,
//                   description: post.description!,
//                   isExpanded: true,
//                   onToggleExpand: () {
//                     // context.read<PostDetailsBloc>().add(
//                     //   PostDetailToggleDescriptionRequested(
//                     //     isDescriptionToggled: stateLoaded.isDescriptionExpanded,
//                     //   ),
//                     // );
//                   },
//                 ),
//                 const SizedBox(height: UiConstants.spacingSm),
//                 _buildActionButtons(context, post: post, userId: userId),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// String _getInitialCharactrOfOrganization(String name) {
//   return name
//       .trim()
//       .split(' ')
//       .where((word) => word.isNotEmpty)
//       .map((word) => word[0].toUpperCase())
//       .join();
// }

// Widget _buildImageStrip(Post post) {
//   final images = post.additionalImagesForHomeFeed;

//   return SizedBox(
//     width: double.infinity,
//     height: 100,
//     child: ListView.separated(
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () => _showImagePreviewDialog(context, images[index]),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: CachedNetworkImage(
//               imageUrl: images[index],
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//           ),
//         );
//       },
//       separatorBuilder: (context, index) => const SizedBox(width: 10),
//       itemCount: images.length,
//       scrollDirection: Axis.horizontal,
//     ),
//   );
// }

// void _showImagePreviewDialog(BuildContext context, String imageUrl) {
//   showDialog(
//     context: context,
//     barrierColor: Colors.black87,
//     builder: (_) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.all(16),
//         child: Stack(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: InteractiveViewer(
//                 child: CachedNetworkImage(
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   width: double.infinity,
//                   imageUrl: imageUrl,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) =>
//                       const Center(child: CircularProgressIndicator()),
//                   errorWidget: (context, url, error) => const Center(
//                     child: Icon(Icons.error, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),

//             // Close button
//             Positioned(
//               top: 8,
//               right: 8,
//               child: InkWell(
//                 onTap: () => context.pop(),
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.black54,
//                   ),
//                   child: const Icon(Icons.close, color: Colors.white, size: 20),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// // Widget _showMoreOptions(BuildContext context) {
// //   return PopupMenuButton<String>(
// //     elevation: 3,
// //     onSelected: (value) {},
// //     itemBuilder: (context) => [
// //       const PopupMenuItem(
// //         value: 'edit',
// //         child: Row(
// //           children: [
// //             Icon(Icons.edit, size: UiConstants.iconMd),
// //             SizedBox(width: UiConstants.spacingSm),
// //             Text('Edit'),
// //           ],
// //         ),
// //       ),
// //       const PopupMenuItem(
// //         value: 'delete',
// //         child: Row(
// //           children: [
// //             Icon(Icons.delete, size: UiConstants.iconMd, color: Colors.red),
// //             SizedBox(width: UiConstants.spacingSm),
// //             Text('Delete', style: TextStyle(color: Colors.red)),
// //           ],
// //         ),
// //       ),
// //     ],
// //   );
// // }

// Widget _buildTitleAndPriceSection(
//   BuildContext context, {
//   required String title,
//   required double price,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         title,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//           fontSize: 20,
//         ),
//       ),
//       Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           const Text(
//             'Rs.',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               fontSize: 20,
//             ),
//           ),
//           Text(
//             '$price',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               fontSize: 20,
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }

// Widget _buildDescriptionSection(
//   BuildContext context, {
//   required String description,
//   required bool isExpanded,
//   required VoidCallback onToggleExpand,
// }) {
//   return LayoutBuilder(
//     builder: (context, constraints) {
//       final textStyle = const TextStyle(color: Colors.white);
//       final span = TextSpan(text: description, style: textStyle);

//       final textPainter = TextPainter(
//         text: span,
//         textDirection: TextDirection.ltr,
//         maxLines: 2,
//         ellipsis: '...',
//       )..layout(maxWidth: constraints.maxWidth);

//       final bool textExceedsThreeLines = textPainter.didExceedMaxLines;

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (isExpanded || !textExceedsThreeLines)
//             Text(description, style: textStyle, textAlign: TextAlign.justify)
//           else
//             Stack(
//               children: [
//                 Text(
//                   description,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: textStyle,
//                   textAlign: TextAlign.justify,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: GestureDetector(
//                     onTap: onToggleExpand,
//                     child: Container(
//                       color: Theme.of(context).scaffoldBackgroundColor,
//                       padding: const EdgeInsets.only(left: 8),
//                       child: Text(
//                         isExpanded ? 'View Less' : 'View More',
//                         style: TextStyle(
//                           color: Theme.of(context).colorScheme.primary,
//                           fontWeight: FontWeight.bold,
//                           backgroundColor: Theme.of(
//                             context,
//                           ).scaffoldBackgroundColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//           // Show "View Less" when expanded and text was long
//           if (isExpanded && textExceedsThreeLines)
//             GestureDetector(
//               onTap: onToggleExpand,
//               child: Text(
//                 'View Less',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//         ],
//       );
//     },
//   );
// }

// Widget _buildActionButtons(
//   BuildContext context, {
//   required String userId,
//   required Post post,
// }) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Expanded(
//         child: CustomButton(
//           text: 'Add to Library',
//           textColor: Colors.white,
//           icon: const Icon(Icons.bookmark_outline, color: Colors.white),
//           onPressed: () {},
//           isOutlined: true,
//         ),
//       ),
//       const SizedBox(width: UiConstants.spacingSm),
//       Expanded(
//         child: CustomButton(
//           text:
//               enumFromString(PostStatus.values, post.status.name) ==
//                   PostStatus.available
//               ? 'Book Now'
//               : 'Booked',
//           onPressed:
//               enumFromString(PostStatus.values, post.status.name) ==
//                   PostStatus.available
//               ? () {
//                   context.push(
//                     RouteConstants.bookingFormPage,
//                     extra: {'userId': userId, 'postId': post.id, 'post': post},
//                   );
//                 }
//               : null,
//           icon: Icon(
//             enumFromString(PostStatus.values, post.status.name) ==
//                     PostStatus.available
//                 ? Icons.event_available
//                 : Icons.event_busy_sharp,
//           ),
//         ),
//       ),
//     ],
//   );
// }

import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/home/domain/usecases/get_organization_list_based_on_global_score_use_case.dart';
import 'package:app/features/home/presentation/bloc/get_organization_list_based_on_global_score_bloc.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final double? latitude;
  final double? longitude;

  const HomePage({
    super.key,
    required this.userId,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetCurrentUserProfileDetailsBloc(
            getCurrentUserProfileUseCase:
                DependencyInjection.get<GetCurrentUserProfileUseCase>(),
          )..add(GetCurrentUserProfileDetailsRequested(userId: userId)),
        ),
        BlocProvider(
          create: (context) =>
              HomeBloc(
                getNearbyPostsUseCase:
                    DependencyInjection.get<GetAllPostsNearByUserUseCase>(),
                getOrganizationDetailByPostOrganizationIdUseCase:
                    DependencyInjection.get<
                      GetOrganizationDetailByPostOrganizationIdUseCase
                    >(),
              )..add(
                FetchNearbyPosts(
                  userId: userId,
                  latitude: latitude,
                  longitude: longitude,
                ),
              ),
        ),
        BlocProvider(
          create: (context) => GetOrganizationListBasedOnGlobalScoreBloc(
            getOrganizationListBasedOnGlobalScoreUseCase:
                DependencyInjection.get<
                  GetOrganizationListBasedOnGlobalScoreUseCase
                >(),
          )..add(const GetOrganizationListBasedOnGlobalScoreRequested()),
        ),
      ],
      child: HomeView(userId: userId),
    );
  }
}

class HomeView extends StatelessWidget {
  final String userId;
  const HomeView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(RefreshNearbyPosts(userId: userId));
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(child: Text(state.message));
            }

            if (state is HomeLoaded) {
              return CustomScrollView(
                slivers: [
                  /// APP BAR
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    expandedHeight: 200,
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chat_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.push(RouteConstants.chatUserListPage);
                        },
                      ),
                    ],
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(UiConstants.radiusXl),
                              ),
                            ),
                          ),
                        ),
                        const FlexibleSpaceBar(
                          titlePadding: EdgeInsets.only(left: 16, bottom: 12),
                          title: HomeProfileHeader(),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        BlocBuilder<
                          GetOrganizationListBasedOnGlobalScoreBloc,
                          GetOrganizationListBasedOnGlobalScoreState
                        >(
                          builder: (context, state) {
                            // 🔄 LOADING
                            if (state
                                is GetOrganizationListBasedOnGlobalScoreLoading) {
                              return SizedBox(
                                height: 100,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: UiConstants.spacingMd,
                                    vertical: UiConstants.spacingSm,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 8,
                                  separatorBuilder: (_, __) => const SizedBox(
                                    width: UiConstants.spacingMd,
                                  ),
                                  itemBuilder: (context, index) =>
                                      _shimmerCircle(),
                                ),
                              );
                            }
                            if (state
                                is GetOrganizationListBasedOnGlobalScoreError) {
                              return Center(child: Text(state.message));
                            }
                            if (state
                                is GetOrganizationListBasedOnGlobalScoreSuccess) {
                              final organizations = state.organizations;

                              final int displayCount = organizations.length >= 8
                                  ? organizations.length
                                  : 8;

                              return SizedBox(
                                height: 100,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: UiConstants.spacingMd,
                                    vertical: UiConstants.spacingSm,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: displayCount,
                                  separatorBuilder: (_, __) => const SizedBox(
                                    width: UiConstants.spacingMd,
                                  ),
                                  itemBuilder: (context, index) {
                                    if (index < organizations.length) {
                                      return _orgItem(
                                        context,
                                        organizations[index],
                                      );
                                    } else {
                                      // shimmer filler if less than 8 orgs
                                      return _shimmerCircle();
                                    }
                                  },
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                  ),

                  /// POSTS GRID
                  SliverPadding(
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = state.posts[index];
                        final organization =
                            state.organizations[post.organizationId];

                        if (organization == null) {
                          context.read<HomeBloc>().add(
                            FetchOrganizationDetails(post.organizationId),
                          );
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return PostGridCard(
                          post: post,
                          organization: organization,
                          userId: userId,
                        );
                      }, childCount: state.posts.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: UiConstants.spacingSm,
                            crossAxisSpacing: UiConstants.spacingSm,
                            childAspectRatio: 0.68,
                          ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _shimmerCircle() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: const CircleAvatar(radius: 28),
        ),
        const SizedBox(height: 6),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 10,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _orgItem(BuildContext context, Organization org) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: org.logoUrl != null && org.logoUrl!.isNotEmpty
              ? NetworkImage(org.logoUrl!)
              : null,
          child: (org.logoUrl == null || org.logoUrl!.isEmpty)
              ? Text(
                  org.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          org.name,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class PostGridCard extends StatelessWidget {
  final Post post;
  final Organization organization;
  final String userId;

  const PostGridCard({
    super.key,
    required this.post,
    required this.organization,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = post.status == PostStatus.available;

    return Material(
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      elevation: 2, // slightly softer
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias, // helps with rounded corners + inkwell
      child: InkWell(
        onTap: () {
          context.push(
            RouteConstants.postDetailsPage,
            extra: {'postId': post.id, 'post': post, 'userId': userId},
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image section (fixed height) ──
            AspectRatio(
              aspectRatio: 1.1, // slightly portrait — adjust 1.0–1.25 as needed
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: post.primaryImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        ColoredBox(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),

                  // Bookmark button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // TODO: bookmark / save logic
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.bookmark_border_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content section ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title – most important – generous space
                    Flexible(
                      flex: 3,
                      child: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Organization – smaller & lighter
                    Flexible(
                      flex: 2,
                      child: Text(
                        organization.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(), // pushes price/status/button to bottom
                    // Price + Status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          post.price != null ? 'Rs. ${post.price}' : 'Contact',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAvailable ? 'Available' : 'Booked',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Book button – fills remaining space horizontally
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: isAvailable
                            ? () {
                                context.push(
                                  RouteConstants.bookingFormPage,
                                  extra: {
                                    'userId': userId,
                                    'postId': post.id,
                                    'post': post,
                                  },
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable
                              ? theme.colorScheme.primary
                              : Colors.grey.shade300,
                          foregroundColor: isAvailable
                              ? Colors.white
                              : Colors.black54,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(
                          isAvailable ? 'Book Now' : 'Unavailable',
                          style: TextStyle(
                            color: isAvailable ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile header
class HomeProfileHeader extends StatelessWidget {
  const HomeProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GetCurrentUserProfileDetailsBloc,
      GetCurrentUserProfileDetailsState
    >(
      builder: (context, state) {
        if (state is GetCurrentUserProfileDetailsLoading) {
          return const SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (state is GetCurrentUserProfileDetailsError) {
          return const Text(
            'Welcome',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }

        if (state is GetCurrentUserProfileDetailsSuccess) {
          final user = state.user;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                user.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
