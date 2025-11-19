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
  final bool? posts;
  final bool? videos;
  final bool? images;

  const PostCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.videoUrl,
    required this.description,
    required this.price,
    required this.onTap,
    this.posts,
    this.videos,
    this.images,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _duration;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      )
      ..initialize()
          .then((_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isVideoInitialized = true;
              final duration = _videoController!.value.duration;
              _duration =
                  '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
            });
            _videoController!.setLooping(true);
            _videoController!.setVolume(0); // Muted preview
            _videoController!.play();
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
    final double baseHeight = 180;
    final double heightVariation = (widget.title.length % 5) * 40.0;
    final double cardHeight = baseHeight + heightVariation;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
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
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                  ),
                )
              else
                Positioned.fill(child: Container(color: Colors.grey[300])),

              // Play icon for videos
              if (widget.videoUrl != null && _duration != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.black45, Colors.black54],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _duration!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Gradient + Text Overlay
              // Only show in a all posts tab not in a video and the images.
              if (widget.posts != null && widget.posts!)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black45, Colors.black54],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Rs. ${widget.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
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
