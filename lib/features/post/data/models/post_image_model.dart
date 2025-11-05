import 'package:app/features/post/domain/entities/post_image.dart';
import 'package:equatable/equatable.dart';

class PostImageModel extends Equatable {
  final String id;
  final String postId;
  final String imageUrl;
  final String uploadedBy;
  final String updatedBy;
  final DateTime createdAt; 
  final DateTime updatedAt; 

  const PostImageModel({
    required this.id,
    required this.postId,
    required this.imageUrl,
    required this.uploadedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostImageModel.fromJson(Map<String, dynamic> json) {
    return PostImageModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      imageUrl: json['image_url'] as String,
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
      'image_url': imageUrl,
      'uploaded_by': uploadedBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'post_id': postId,
      'image_url': imageUrl,
      'uploaded_by': uploadedBy,
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'image_url': imageUrl,
      'updated_by': updatedBy,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  PostImageModel copyWith({
    String? id,
    String? postId,
    String? imageUrl,
    String? uploadedBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostImageModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      imageUrl: imageUrl ?? this.imageUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Entity
  PostImage toEntity() {
    return PostImage(
      id: id,
      postId: postId,
      imageUrl: imageUrl,
      uploadedBy: uploadedBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // From Entity
  factory PostImageModel.fromEntity(PostImage postImage) {
    return PostImageModel(
      id: postImage.id,
      postId: postImage.postId,
      imageUrl: postImage.imageUrl,
      uploadedBy: postImage.uploadedBy,
      updatedBy: postImage.updatedBy,
      createdAt: postImage.createdAt,
      updatedAt: postImage.updatedAt,
    );
  }

  bool isValid() {
    return id.isNotEmpty &&
        postId.isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        _isValidImageUrl(imageUrl);
  }

  List<String> getValidationErrors() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Image ID is required');
    if (postId.isEmpty) errors.add('Post ID is required');
    if (imageUrl.trim().isEmpty) {
      errors.add('Image URL is required');
    } else if (!_isValidImageUrl(imageUrl)) {
      errors.add('Invalid image URL format');
    }
    return errors;
  }

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
    } catch (_) {
      return false;
    }
  }

  String get fileExtension {
    try {
      final uri = Uri.parse(imageUrl);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      return lastDot != -1 ? path.substring(lastDot + 1).toLowerCase() : '';
    } catch (_) {
      return '';
    }
  }

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
        imageUrl,
        uploadedBy,
        updatedBy,
        createdAt,
        updatedAt,
      ];
}