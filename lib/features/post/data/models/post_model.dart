import 'package:app/features/post/data/models/post_enums.dart';
import 'package:app/features/post/data/models/post_image_model.dart';
import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String organizationId; // hotel id
  final String title;
  final String? description;
  final String primaryImageUrl;
  final List<PostImageModel> additionalImages;
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
  final String createdBy; // manager/owner Id
  final String updatedBy; // manager/owner id , cause both can update the posts
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      primaryImageUrl: json['primary_image_url'] as String,
      additionalImages:
          (json['additional_images'] as List<dynamic>?)
              ?.map(
                (imageJson) =>
                    PostImageModel.fromJson(imageJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      youtubeUrl: json['youtube_url'] as String?,
      videoUrl: json['video_url'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      area: (json['area'] as num?)?.toDouble(),
      capacity: json['capacity'] as int?,
      roomType: enumFromString(RoomType.values, json['room_type'] as String?),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => enumFromString(AmenityType.values, e as String)!)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => enumFromString(PostTag.values, e as String)!)
          .toList(),
      status:
          enumFromString(PostStatus.values, json['status'] as String?) ??
          PostStatus.available,

      createdBy: json['created_by'] as String,
      updatedBy: json['updated_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'title': title,
      'description': description,
      'primary_image_url': primaryImageUrl,
      'youtube_url': youtubeUrl,
      'video_url': videoUrl,
      'longitude': longitude,
      'latitude': latitude,
      'price': price,
      'area': area,
      'capacity': capacity,
      'room_type': roomType?.name,
      'amenities': amenities?.map((e) => e.name).toList(),
      'tags': tags?.map((e) => e.name).toList(),
      'status': status.name,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      // Supabase PostGIS: location as "POINT(longitude latitude)"
      if (longitude != null && latitude != null)
        'location': 'POINT($longitude $latitude)',
    };
  }

  /// Convert to JSON for creating new posts (without id and timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'organization_id': organizationId,
      'title': title,
      'description': description,
      'primary_image_url': primaryImageUrl,
      'youtube_url': youtubeUrl,
      'video_url': videoUrl,
      'longitude': longitude,
      'latitude': latitude,
      'price': price,
      'area': area,
      'capacity': capacity,
      'room_type': roomType?.name,
      'amenities': amenities?.map((e) => e.name).toList(),
      'tags': tags?.map((e) => e.name).toList(),
      'status': status.name,
      'created_by': createdBy,
      'location': longitude != null && latitude != null
          ? 'POINT($longitude $latitude)'
          : null,
    };
  }

  /// Convert to JSON for updating posts (without id and created_at)
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'primary_image_url': primaryImageUrl,
      'youtube_url': youtubeUrl,
      'video_url': videoUrl,
      'longitude': longitude,
      'latitude': latitude,
      'price': price,
      'area': area,
      'capacity': capacity,
      'room_type': roomType?.name,
      'amenities': amenities?.map((e) => e.name).toList(),
      'tags': tags?.map((e) => e.name).toList(),
      'status': status.name,
      'updated_by': updatedBy,
      'location': longitude != null && latitude != null
          ? 'POINT($longitude $latitude)'
          : null,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy of this model with optional overrides
  PostModel copyWith({
    String? id,
    String? organizationId,
    String? title,
    String? description,
    String? primaryImageUrl,
    List<PostImageModel>? additionalImages,
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
    return PostModel(
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

  /// Validate post data
  bool isValid() {
    return id.isNotEmpty &&
        organizationId.isNotEmpty &&
        title.trim().isNotEmpty &&
        _isValidYoutubeUrl();
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (id.isEmpty) {
      errors.add('post ID is required');
    }

    if (organizationId.isEmpty) {
      errors.add('Organization ID is required');
    }

    if (title.trim().isEmpty) {
      errors.add('post title is required');
    }

    if (youtubeUrl != null && youtubeUrl!.isNotEmpty && !_isValidYoutubeUrl()) {
      errors.add('Invalid YouTube URL format');
    }

    return errors;
  }

  // Validate the youtube URL format
  bool _isValidYoutubeUrl() {
    if (youtubeUrl == null || youtubeUrl!.isEmpty) {
      return true; // this is an optional fiels
    }

    try {
      final uri = Uri.parse(youtubeUrl!);
      return (uri.host.contains('youtube.com') ||
              uri.host.contains('youtu.be')) &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Check if the posts has any additional images
  bool get hasAdditionalImages {
    return additionalImages.isNotEmpty;
  }

  // Check if the post has a video
  bool get hasVideo {
    return videoUrl != null && videoUrl!.trim().isNotEmpty;
  }

  //Check if the post has a youtube video link
  bool get hasYoutubeVideoLink {
    return youtubeUrl != null && youtubeUrl!.trim().isNotEmpty;
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
