import 'package:equatable/equatable.dart';

class PostImage extends Equatable {
  final String id;
  final String postId;
  final String imageUrl;
  final String uploadedBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostImage({
    required this.id,
    required this.postId,
    required this.imageUrl,
    required this.uploadedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  PostImage copyWith({
    String? id,
    String? postId,
    String? imageUrl,
    String? uploadedBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostImage(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      imageUrl: imageUrl ?? this.imageUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    postId,
    imageUrl,
    uploadedBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];

  /// Validation: All required fields + valid image URL
  bool get isValid {
    return id.trim().isNotEmpty &&
        postId.trim().isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        uploadedBy.trim().isNotEmpty &&
        updatedBy.trim().isNotEmpty &&
        _isValidImageUrl(imageUrl);
  }

  /// Helper: Check if image URL is valid (http/https + image extension)
  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          (url.toLowerCase().endsWith('.jpg') ||
              url.toLowerCase().endsWith('.jpeg') ||
              url.toLowerCase().endsWith('.png') ||
              url.toLowerCase().endsWith('.gif') ||
              url.toLowerCase().endsWith('.webp'));
    } catch (e) {
      return false;
    }
  }

  /// Helper: Extract file extension from URL
  String get fileExtension {
    try {
      final uri = Uri.parse(imageUrl);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot != -1 && lastDot < path.length - 1) {
        return path.substring(lastDot + 1).toLowerCase();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Helper: Check if image is from Supabase Storage
  bool get isSupabaseImage {
    return imageUrl.contains('supabase.co') &&
        imageUrl.contains('storage/v1/object/public');
  }

  String? get supabaseStoragePath {
    if (!isSupabaseImage) return null;

    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final publicIndex = pathSegments.indexOf('public');
      if (publicIndex != -1 && publicIndex < pathSegments.length - 1) {
        return pathSegments.sublist(publicIndex + 1).join('/');
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
