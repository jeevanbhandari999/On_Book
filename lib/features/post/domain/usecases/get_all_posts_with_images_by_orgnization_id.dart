import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_image.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllPostsWithImagesByOrganizationIdUseCase {
  final PostRepository repository;

  GetAllPostsWithImagesByOrganizationIdUseCase(this.repository);

  Future<Either<Failure, List<PostImage>>> call(
    GetAllPostsWithImagesByOrganizationIdParams params,
  ) async {
    // Validate organization ID
    if (params.organizationId.trim().isEmpty) {
      return const Left(ValidationFailure('Organization ID is required'));
    }

    // Check user permissions if userId is provided
    if (params.userId != null) {
      await repository.canManagePosts(params.userId!, params.organizationId);

      // Note: We don't fail if user can't manage posts, as they can still view posts
      // This is just for potential future use or logging
    }

    // Get posts based on cached type,

    return await repository.getPostsWithImagesByOrganizationId(
      params.organizationId,
    );
  }
}

class GetAllPostsWithImagesByOrganizationIdParams extends Equatable {
  final String? userId; // Made optional
  final String organizationId;

  const GetAllPostsWithImagesByOrganizationIdParams({
    this.userId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [userId, organizationId];
}
