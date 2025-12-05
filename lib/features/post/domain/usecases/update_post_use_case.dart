import 'dart:io';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdatePostUseCase {
  final PostRepository repository;

  UpdatePostUseCase(this.repository);

  Future<Either<Failure, Post>> call(UpdatePostParams params) async {
    // Validate required parameters
    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID is required'));
    }

    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure('Title is required'));
    }

    // Check permissions
    final permissionResult = await repository.canEditPost(
      params.userId,
      params.postId,
    );

    if (permissionResult.isLeft()) {
      return permissionResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected permission result'),
      );
    }

    final canEdit = permissionResult.fold((_) => false, (canEdit) => canEdit);

    if (!canEdit) {
      return const Left(
        PermissionFailure('Insufficient permissions to edit this post'),
      );
    }

    // Fetch existing post
    final existingResult = await repository.getPostById(params.postId);
    if (existingResult.isLeft()) {
      return existingResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected post result'),
      );
    }

    final existing = existingResult.fold(
      (_) => throw Exception('Post not found'),
      (p) => p,
    );

    String? primaryImageUrl = params.primaryImageUrl;
    if (params.newPrimaryImageFile != null) {
      final uploadResult = await repository.uploadImage(
        params.newPrimaryImageFile!,
        existing.organizationId,
        'primary_image', // primary_image postId before creation (backend may not need it)
      );

      if (uploadResult.isLeft()) {
        return uploadResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected upload result'),
        );
      }

      primaryImageUrl = uploadResult.getOrElse(() => '');
    }

    final now = DateTime.now();
    final updated = existing.copyWith(
      title: params.title.trim(),
      description: params.description.trim(),
      primaryImageUrl: params.newPrimaryImageFile != null
          ? primaryImageUrl
          : (params.primaryImageToDelete != null
                ? null
                : existing.primaryImageUrl),
      youtubeUrl: params.youtubeUrl?.trim().isNotEmpty == true
          ? params.youtubeUrl!.trim()
          : null,
      longitude: params.longitude,
      latitude: params.latitude,
      price: params.price,
      area: params.area,
      capacity: params.capacity,
      roomType: params.roomType,
      amenities: params.amenities,
      tags: params.tags,
      status: params.status,
      updatedBy: params.updatedBy,
      updatedAt: now,
    );

    return await repository.updatePost(
      updated,
      params.newPrimaryImageFile,
      params.primaryImageToDelete,
      params.additionalImages,
      params.additionalImagesToDelete,
      null, // right now let's do it without video
      null,
    );
  }
}

class UpdatePostParams extends Equatable {
  final String postId;
  final String userId;
  final String title;
  final String description;
  final String primaryImageUrl;
  final File? newPrimaryImageFile;
  final String? primaryImageToDelete;
  final List<File> additionalImages;
  final List<String> additionalImagesToDelete;
  final String? youtubeUrl;
  final double? longitude;
  final double? latitude;
  final double price;
  final double? area;
  final int? capacity;
  final RoomType? roomType;
  final List<AmenityType>? amenities;
  final List<PostTag>? tags;
  final PostStatus? status;
  final String updatedBy;
  final DateTime updatedAt;
  const UpdatePostParams({
    required this.postId,
    required this.userId,
    required this.title,
    required this.description,
    required this.primaryImageUrl,
    this.newPrimaryImageFile,
    this.primaryImageToDelete,
    this.additionalImages = const [],
    this.additionalImagesToDelete = const [],
    this.youtubeUrl,
    this.longitude,
    this.latitude,
    required this.price,
    this.area,
    this.capacity,
    this.roomType,
    this.amenities,
    this.tags,
    this.status,
    required this.updatedBy,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    postId,
    userId,
    title,
    description,
    primaryImageUrl,
    newPrimaryImageFile,
    primaryImageToDelete,
    additionalImages,
    additionalImagesToDelete,
    youtubeUrl,
    longitude,
    latitude,
    price,
    area,
    capacity,
    roomType,
    amenities,
    tags,
    status,
    updatedBy,
    updatedAt,
  ];

  UpdatePostParams copyWith({
    String? postId,
    String? userId,
    String? title,
    String? description,
    String? primaryImageUrl,
    File? newPrimaryImageFile,
    String? primaryImageToDelete,
    List<File>? additionalImages,
    List<String>? additionalImagesToDelete,
    String? youtubeUrl,
    double? longitude,
    double? latitude,
    double? price,
    double? area,
    int? capacity,
    RoomType? roomType,
    List<AmenityType>? amenities,
    List<PostTag>? tags,
    PostStatus? status,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return UpdatePostParams(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      newPrimaryImageFile: newPrimaryImageFile ?? this.newPrimaryImageFile,
      primaryImageToDelete: primaryImageToDelete ?? this.primaryImageToDelete,
      additionalImages: additionalImages ?? this.additionalImages,
      additionalImagesToDelete:
          additionalImagesToDelete ?? this.additionalImagesToDelete,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      price: price ?? this.price,
      area: area ?? this.area,
      capacity: capacity ?? this.capacity,
      roomType: roomType ?? this.roomType,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validate parameters
  List<String> validate() {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Title is required');
    }

    if (description.trim().isEmpty) {
      errors.add('Description is required');
    }

    // Price (required in ctor) must be positive
    if (price <= 0) {
      errors.add('Price must be greater than 0');
    }

    // Area if provided must be non-negative
    if (area != null && area! < 0) {
      errors.add('Area must be 0 or greater');
    }

    // Capacity if provided must be positive integer
    if (capacity != null && capacity! <= 0) {
      errors.add('Capacity must be greater than 0');
    }

    // Latitude/Longitude: either both provided or neither
    if ((latitude == null) ^ (longitude == null)) {
      errors.add('Both latitude and longitude must be provided together');
    } else if (latitude != null && longitude != null) {
      if (latitude! < -90.0 || latitude! > 90.0) {
        errors.add('Latitude must be between -90 and 90');
      }
      if (longitude! < -180.0 || longitude! > 180.0) {
        errors.add('Longitude must be between -180 and 180');
      }
    }

    // YouTube URL validation (if provided)
    if (youtubeUrl != null && youtubeUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(youtubeUrl!);
        final host = uri.host.toLowerCase();
        if (!(host.contains('youtube.com') || host.contains('youtu.be')) ||
            !uri.hasScheme ||
            !(uri.scheme == 'http' || uri.scheme == 'https')) {
          errors.add('Invalid YouTube URL format');
        }
      } catch (e) {
        errors.add('Invalid YouTube URL format');
      }
    }

    if (updatedBy.trim().isEmpty) {
      errors.add('updatedBy is required');
    }

    // Optional: roomType, amenities, tags, status - no strict validation here
    // but you can add domain-specific checks later if needed.

    return errors;
  }

  /// Check if parameters are valid
  bool get isValid => validate().isEmpty;
}
