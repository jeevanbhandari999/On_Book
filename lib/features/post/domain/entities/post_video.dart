import 'package:equatable/equatable.dart';

class PostVideo extends Equatable {
  final String id;
  final String postId;
  final String videoUrl;
  final String uploadedBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostVideo({
    required this.id,
    required this.postId,
    required this.videoUrl,
    required this.uploadedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    postId,
    videoUrl,
    uploadedBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];

  PostVideo copyWith({
    String? id,
    String? postId,
    String? videoUrl,
    String? uploadedBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostVideo(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      videoUrl: videoUrl ?? this.videoUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validate video URL
  bool get isValid {
    return id.trim().isNotEmpty &&
        postId.trim().isNotEmpty &&
        videoUrl.trim().isNotEmpty &&
        _isValidVideoUrl(videoUrl);
  }

  /// Extract file extension
  String get fileExtension {
    try {
      final uri = Uri.parse(videoUrl);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      return lastDot != -1 ? path.substring(lastDot + 1).toLowerCase() : '';
    } catch (_) {
      return '';
    }
  }

  /// Check if from Supabase Storage
  bool get isSupabaseVideo {
    return videoUrl.contains('supabase.co') &&
        videoUrl.contains('storage/v1/object/public');
  }

  bool _isValidVideoUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          (url.toLowerCase().endsWith('.mp4') ||
              url.toLowerCase().endsWith('.mov') ||
              url.toLowerCase().endsWith('.avi') ||
              url.toLowerCase().endsWith('.webm') ||
              url.toLowerCase().endsWith('.mkv'));
    } catch (_) {
      return false;
    }
  }
}
