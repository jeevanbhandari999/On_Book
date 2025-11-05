import 'package:app/features/post/domain/entities/post_video.dart';
import 'package:equatable/equatable.dart';

class PostVideoModel extends Equatable {
  final String id;
  final String postId;
  final String videoUrl;
  final String uploadedBy;
  final String updatedBy;
  final DateTime createdAt;  // ← NOW DateTime
  final DateTime updatedAt;  // ← NOW DateTime

  const PostVideoModel({
    required this.id,
    required this.postId,
    required this.videoUrl,
    required this.uploadedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostVideoModel.fromJson(Map<String, dynamic> json) {
    return PostVideoModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      videoUrl: json['video_url'] as String,
      uploadedBy: json['uploaded_by'] as String,
      updatedBy: json['updated_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'video_url': videoUrl,
      'uploaded_by': uploadedBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'post_id': postId,
      'video_url': videoUrl,
      'uploaded_by': uploadedBy,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'video_url': videoUrl,
      'updated_by': updatedBy,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  PostVideoModel copyWith({
    String? id,
    String? postId,
    String? videoUrl,
    String? uploadedBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostVideoModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      videoUrl: videoUrl ?? this.videoUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Entity
  PostVideo toEntity() {
    return PostVideo(
      id: id,
      postId: postId,
      videoUrl: videoUrl,
      uploadedBy: uploadedBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // From Entity
  factory PostVideoModel.fromEntity(PostVideo video) {
    return PostVideoModel(
      id: video.id,
      postId: video.postId,
      videoUrl: video.videoUrl,
      uploadedBy: video.uploadedBy,
      updatedBy: video.updatedBy,
      createdAt: video.createdAt,
      updatedAt: video.updatedAt,
    );
  }

  bool isValid() {
    return id.isNotEmpty &&
        postId.isNotEmpty &&
        videoUrl.trim().isNotEmpty &&
        _isValidVideoUrl(videoUrl);
  }

  List<String> getValidationErrors() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Video ID is required');
    if (postId.isEmpty) errors.add('Post ID is required');
    if (videoUrl.trim().isEmpty) {
      errors.add('Video URL is required');
    } else if (!_isValidVideoUrl(videoUrl)) {
      errors.add('Invalid video URL format');
    }
    return errors;
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

  bool get isSupabaseVideo {
    return videoUrl.contains('supabase.co') &&
        videoUrl.contains('storage/v1/object/public');
  }

  String? get supabaseStoragePath {
    if (!isSupabaseVideo) return null;
    try {
      final uri = Uri.parse(videoUrl);
      final pathSegments = uri.pathSegments;
      final publicIndex = pathSegments.indexOf('public');
      return publicIndex != -1 && publicIndex < pathSegments.length - 1
          ? pathSegments.sublist(publicIndex + 1).join('/')
          : null;
    } catch (_) {
      return null;
    }
  }

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
}