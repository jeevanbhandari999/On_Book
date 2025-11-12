// import 'package:flutter/material.dart';

// class PostCard extends StatelessWidget {
//   final String title;
//   final String? imageUrl;
//   final String description;
//   final double price;
//   final String? videoUrl;
//   final VoidCallback onTap;
//   const PostCard({
//     super.key,
//     required this.title,
//     this.imageUrl,
//     required this.description,
//     required this.price,
//     this.videoUrl,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(
//           children: [
//             // Image section or Video section
//             if (imageUrl != null)
//               Image.network(
//                 imageUrl!,
//                 height: (250 + (30 * (title.length % 3))).toDouble(),
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),

//             // Text section
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.black.withAlpha(185),
//                       Colors.black.withAlpha(50),
//                     ],
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
//                     Text('Rs. ${price.toStringAsFixed(2)}'),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// post_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final String? videoUrl;
  final String description;
  final double price;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.videoUrl,
    required this.description,
    required this.price,
    required this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
          ..initialize()
              .then((_) {
                if (mounted) {
                  setState(() => _isVideoInitialized = true);
                  _videoController!.setLooping(true);
                  _videoController!.setVolume(0); // Muted preview
                  _videoController!.play();
                }
              })
              .catchError((error) {
                if (mounted) setState(() => _isVideoInitialized = false);
              });
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _videoController?.dispose();
      _isVideoInitialized = false;
      if (widget.videoUrl != null) {
        _initializeVideo();
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseHeight = 220;
    final double heightVariation = (widget.title.length % 5) * 40.0;
    final double cardHeight = baseHeight + heightVariation;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: cardHeight,
          child: Stack(
            children: [
              // Media: Image or Video
              if (widget.videoUrl != null && _isVideoInitialized)
                Positioned.fill(child: VideoPlayer(_videoController!))
              else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                )
              else
                Positioned.fill(child: Container(color: Colors.grey[300])),

              // Play icon for videos
              if (widget.videoUrl != null)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

              // Gradient + Text Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  // decoration: const BoxDecoration(
                  //   gradient: LinearGradient(
                  //     colors: [Colors.black45, Colors.black54],
                  //     begin: Alignment.bottomCenter,
                  //     end: Alignment.topCenter,
                  //   ),
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Rs. ${widget.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
