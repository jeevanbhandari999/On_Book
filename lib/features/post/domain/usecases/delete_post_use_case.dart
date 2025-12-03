import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeletePostUseCase {
  final PostRepository repository;

  const DeletePostUseCase(this.repository);

  Future<Either<Failure, void>> call(DeletePostParams params) async {
    // validate the post
    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID is required'));
    }

    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    // Check the permission for the deletion whether the user is authorized to delete or not
    final permissionResult = await repository.canDeletePost(
      params.userId,
      params.postId,
    );
    print(permissionResult);

    if (permissionResult.isLeft()) {
      return permissionResult.fold(
        (failure) => Left(failure),
        (_) => const Left(UnknownFailure('Unexpected permission result')),
      );
    }

    final canDelete = permissionResult.fold(
      (_) => false,
      (canDelete) => canDelete,
    );

    if (!canDelete) {
      return const Left(
        PermissionFailure('Insufficient permission to delete this post.'),
      );
    }

    // Delete the post
    return await repository.deletePost(params.postId);
  }
}

class DeletePostParams extends Equatable {
  final String postId;
  final String userId;
  const DeletePostParams({required this.postId, required this.userId});

  @override
  List<Object?> get props => [postId, userId];

  // Create a copy with updated parameters
  DeletePostParams copyWith({String? postId, String? userId}) {
    return DeletePostParams(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
    );
  }

  // Post validate
  List<String> validate() {
    final errors = <String>[];
    if (userId.trim().isEmpty) {
      errors.add('User ID is required');
    }
    if (postId.trim().isEmpty) {
      errors.add('Post ID is required');
    }

    return errors;
  }

  // Check if the post is valid or not to delete
  bool get isValid => validate().isEmpty;
}
