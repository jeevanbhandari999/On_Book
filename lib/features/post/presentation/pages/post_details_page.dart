import 'package:app/app/app_config.dart';
import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/usecases/delete_post_use_case.dart';
import 'package:app/features/post/domain/usecases/get_post_by_id_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PostDetailsPage extends StatelessWidget {
  final String postId;
  final Post? post;
  final String? userId;
  const PostDetailsPage({
    super.key,
    required this.postId,
    this.post,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailsBloc>(
      create: (context) {
        return PostDetailsBloc(
          getPostByIdUseCase: DependencyInjection.get<GetPostByIdUseCase>(),
          deletePostUseCase: DependencyInjection.get<DeletePostUseCase>(),
        )..add(PostDetailLoadRequested(postId: postId, userId: userId));
      },
      child: PostDetailsView(postId: postId, post: post, userId: userId),
    );
  }
}

class PostDetailsView extends StatelessWidget {
  final String postId;
  final Post? post;
  final String? userId;
  const PostDetailsView({
    super.key,
    required this.postId,
    this.post,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post!.title)),
      body: BlocBuilder<PostDetailsBloc, PostDetailState>(
        builder: (context, state) {
          if (state is PostdetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PostDetailLoaded) {
            return Text('Loaded');
          }
          if (state is PostDetailNotFound) {
            return _buildNotFoundState(context);
          }
          if (state is PostDetailError) {
            return _buildErrorState(context);
          }
          // show try again in fall back
          return _buildFallBackTryAgainState(context);
        },
      ),
    );
  }
}

Widget _buildNotFoundState(BuildContext context) {
  return Column();
}

Widget _buildErrorState(BuildContext context) {
  return Column();
}

Widget _buildFallBackTryAgainState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.remove_red_eye, size: UiConstants.iconLg),
          const SizedBox(height: UiConstants.spacingMd),
          const Text(
            'Somethign went wrong!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: UiConstants.spacingSm),
          const Text(
            'Looks like something is happening while fetching the post details, please try again.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UiConstants.spacingLg),

          CustomButton(
            text: 'Retry',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PostDetailsBloc>().add(
                const PostDetailRefreshRequested(),
              );
            },
          ),
        ],
      ),
    ),
  );
}

// class PostDetailsView extends StatelessWidget {
//   final String title;
//   final double? latitude;
//   final double? longitude;

//   const PostDetailsView({
//     super.key,
//     required this.title,
//     this.latitude,
//     this.longitude,
//   });

//   bool get hasLocation => latitude != null && longitude != null;
//   LatLng? get latLng => hasLocation ? LatLng(latitude!, longitude!) : null;
//   @override
//   Widget build(BuildContext context) {
//     final location = latLng;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Post Details'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             Text(
//               title,
//               style: Theme.of(
//                 context,
//               ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),

//             // Location Section
//             Text(
//               'Location',
//               style: Theme.of(
//                 context,
//               ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),

//             // Mini Map
//             if (location != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Container(
//                   height: 300,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: FlutterMap(
//                     options: MapOptions(
//                       initialCenter: location,
//                       initialZoom: 16,
//                       minZoom: 3,
//                       maxZoom: 20,
//                     ),
//                     children: [
//                       TileLayer(
//                         urlTemplate:
//                             'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.png?key=${AppConfig.mapTilerKey}',
//                         userAgentPackageName: 'com.example.app',
//                         subdomains: const ['a', 'b', 'c', 'd'],
//                         maxZoom: 20,
//                       ),
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: location,
//                             width: 80,
//                             height: 80,
//                             child: const Icon(
//                               Icons.location_on,
//                               color: Colors.blue,
//                               size: 50,
//                               shadows: [
//                                 BoxShadow(
//                                   color: Colors.black26,
//                                   blurRadius: 10,
//                                   offset: Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Center(child: Text('No location available')),
//               ),

//             const SizedBox(height: 16),

//             // Coordinates Text
//             if (location != null) ...[
//               const SizedBox(height: 16),
//               Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.pin_drop, color: Colors.blue),
//                   title: Text(
//                     'Coordinates',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   subtitle: Text(
//                     'Lat: ${location.latitude.toStringAsFixed(6)}\nLng: ${location.longitude.toStringAsFixed(6)}',
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.open_in_new),
//                     onPressed: () {
//                       // Optional: copy to clipboard
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Coordinates copied!')),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }
