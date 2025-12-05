import 'package:equatable/equatable.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/entities/post_image.dart';

class Post extends Equatable {
  final String id;
  final String organizationId;
  final String title;
  final String? description;
  final String primaryImageUrl;
  final List<PostImage> additionalImages;
  final String? youtubeUrl;
  final String? videoUrl;
  final double? longitude;
  final double? latitude;
  final double? price;
  final double? area;
  final int? capacity;
  final RoomType? roomType;
  final List<AmenityType>? amenities;
  final List<PostTag>? tags;
  final PostStatus status;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.organizationId,
    required this.title,
    this.description,
    required this.primaryImageUrl,
    this.additionalImages = const [],
    this.youtubeUrl,
    this.videoUrl,
    this.longitude,
    this.latitude,
    this.price,
    this.area,
    this.capacity,
    this.roomType,
    this.amenities,
    this.tags,
    this.status = PostStatus.available,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Validate post data
  bool isValid() {
    return id.trim().isNotEmpty &&
        organizationId.trim().isNotEmpty &&
        title.trim().isNotEmpty &&
        _isValidImageUrl(primaryImageUrl) &&
        _isValidYoutubeUrl();
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (id.trim().isEmpty) errors.add('Post ID is required');
    if (organizationId.trim().isEmpty) {
      errors.add('Organization ID is required');
    }
    if (title.trim().isEmpty) errors.add('Title is required');
    if (!_isValidImageUrl(primaryImageUrl)) {
      errors.add('Invalid primary image URL');
    }

    if (youtubeUrl != null && youtubeUrl!.isNotEmpty && !_isValidYoutubeUrl()) {
      errors.add('Invalid YouTube URL format');
    }

    return errors;
  }

  /// Check if post has additional images
  bool get hasAdditionalImages => additionalImages.isNotEmpty;

  /// Check if post has local video
  bool get hasVideo => videoUrl != null && videoUrl!.trim().isNotEmpty;

  /// Check if post has YouTube link
  bool get hasYoutubeVideoLink =>
      youtubeUrl != null && youtubeUrl!.trim().isNotEmpty;

  /// Check if location is set
  bool get hasLocation => longitude != null && latitude != null;

  /// Check if price is set
  bool get hasPrice => price != null && price! > 0;
  List<String>? get existingAdditionalImages {
    final images = <String>[];
    additionalImages.map((image) => images.add(image.imageUrl)).toList();
    return images;
  }

  // Private: Validate image URL
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

  // Private: Validate YouTube URL
  bool _isValidYoutubeUrl() {
    if (youtubeUrl == null || youtubeUrl!.isEmpty) return true;
    try {
      final uri = Uri.parse(youtubeUrl!);
      return (uri.host.contains('youtube.com') ||
              uri.host.contains('youtu.be')) &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Create a copy with updated values
  Post copyWith({
    String? id,
    String? organizationId,
    String? title,
    String? description,
    String? primaryImageUrl,
    List<PostImage>? additionalImages,
    String? youtubeUrl,
    String? videoUrl,
    double? longitude,
    double? latitude,
    double? price,
    double? area,
    int? capacity,
    RoomType? roomType,
    List<AmenityType>? amenities,
    List<PostTag>? tags,
    PostStatus? status,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      description: description ?? this.description,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      additionalImages: additionalImages ?? this.additionalImages,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      price: price ?? this.price,
      area: area ?? this.area,
      capacity: capacity ?? this.capacity,
      roomType: roomType ?? this.roomType,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    organizationId,
    title,
    description,
    primaryImageUrl,
    additionalImages,
    youtubeUrl,
    videoUrl,
    longitude,
    latitude,
    price,
    area,
    capacity,
    roomType,
    amenities,
    tags,
    status,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
}
