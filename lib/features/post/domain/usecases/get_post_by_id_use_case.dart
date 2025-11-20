import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetPostByIdUseCase {
  final PostRepository repository;

  const GetPostByIdUseCase(this.repository);

  Future<Either<Failure, Post>> call(GetPostByIdParams params) async {
    // Validate post id
    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID is required.'));
    }

    // Get posts by id
    final result = await repository.getPostById(params.postId);

    // If post is found and the user id is also provided the go through the additional features
    if (result.isRight() && params.userId != null) {
      final post = result.fold((_) => null, (post) => post);

      if (post != null) {
        // Check if the user can manage the post or not
        final permissionResult = await repository.canManagePosts(
          params.userId!,
          post.organizationId,
        );

        if (permissionResult.isLeft()) {
          // log the message if needed but not crash the project
        }
      }
    }

    // return the result
    return result;
  }
}

class GetPostByIdParams extends Equatable {
  final String postId;
  final String? userId;
  final bool includePermissionCheck;

  const GetPostByIdParams({
    required this.postId,
    this.userId,
    this.includePermissionCheck = true,
  });

  @override
  List<Object?> get props => [postId, userId, includePermissionCheck];

  // Create params for simple post fetching without any permission needed(user, staff and others)
  factory GetPostByIdParams.generalFetch(String postId) {
    return GetPostByIdParams(postId: postId, includePermissionCheck: false);
  }

  // Create params for managable post fetching with user permission(admin, owner, manager, etc)
  factory GetPostByIdParams.fetchWithUser({
    required String postId,
    required String userId,
  }) {
    return GetPostByIdParams(
      postId: postId,
      userId: userId,
      includePermissionCheck: true,
    );
  }

  // Validation for fields
  List<String> validatePost() {
    final errors = <String>[];

    if (postId.trim().isEmpty) {
      errors.add('Post ID ir required');
    }
    // more validation if needed here
    return errors;
  }

  // Check if the paramaters are valid
  bool get isValid => validatePost().isEmpty;

  // Get the updated paramters with the help of copyeith
  GetPostByIdParams copyWith({
    String? postId,
    String? userId,
    bool? includePermissionChecked,
  }) {
    return GetPostByIdParams(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      includePermissionCheck: includePermissionCheck,
    );
  }
}
