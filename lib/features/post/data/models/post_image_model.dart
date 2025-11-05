import 'package:equatable/equatable.dart';

class PostImageModel extends Equatable {
  final String id;
  final String organizationId;
  final String imageUrl;
  final String uploadedBy;
  final String updatedBy;
  final String createdAt;
  final String updatedAt;

  const PostImageModel({
    required this.id,
    required this.organizationId,
    required this.imageUrl,
    required this.uploadedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostImageModel.fromJson(Map<String, dynamic> json) {
    return PostImageModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      imageUrl: json['image_url'] as String,
      uploadedBy: json['uploaded_by'] as String,
      updatedBy: json['updated_by'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'image_url': imageUrl,
      'uploaded_by': uploadedBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert to JSON for creating new post images (without id and timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'organization_id': organizationId,
      'image_url': imageUrl,
      'uploaded_by': uploadedBy,
      'updated_by': updatedBy,
    };
  }

  PostImageModel copyWith({
    String? id,
    String? organizationId,
    String? imageUrl,
    String? uploadedBy,
    String? updatedBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return PostImageModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      imageUrl: imageUrl ?? this.imageUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert PostImageModel to PostImage entity
  // PostImage toEntity() {
  //   return PostImage(
  //     id: id,
  //     organizationId: organizationId,
  //     imageUrl: imageUrl,
  //     uploadedBy: uploadedBy,
  //     updatedBy: updatedBy,
  //     createdAt: createdAt,
  //     updatedAt: updatedAt,
  //   );
  // }

  // /// Create PostImageModel from PostImage entity
  // factory PostImageModel.fromEntity(PostImage postImage) {
  //   return PostImageModel(
  //     id: postImage.id,
  //     organizationId: postImage.organizationId,
  //     imageUrl: postImage.imageUrl,
  //     uploadedBy: postImage.uploadedBy,
  //     updatedBy: postImage.updatedBy,
  //     createdAt: postImage.createdAt,
  //     updatedAt: postImage.updatedAt,
  //   );
  // }

  /// Validate post image data
  bool isValid() {
    return id.isNotEmpty &&
        organizationId.isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        _isValidImageUrl(imageUrl);
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('Image ID is required');
    if (organizationId.isEmpty) errors.add('Organization ID is required');
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

  /// Helper method to get file extension
  String get fileExtension {
    try {
      final uri = Uri.parse(imageUrl);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot != -1 && lastDot < path.length - 1) {
        return path.substring(lastDot + 1).toLowerCase();
      }
      return '';
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
      if (publicIndex != -1 && publicIndex < pathSegments.length - 1) {
        return pathSegments.sublist(publicIndex + 1).join('/');
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        organizationId,
        imageUrl,
        uploadedBy,
        updatedBy,
        createdAt,
        updatedAt,
      ];
}
