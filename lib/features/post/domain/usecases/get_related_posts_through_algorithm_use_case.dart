import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetRelatedPostsThroughAlgorithmUseCase {
  final PostRepository repository;

  const GetRelatedPostsThroughAlgorithmUseCase({required this.repository});

  Future<Either<Failure, List<Post>>> call(
    GetRelatedPostsThroughAlgorithmParams params,
  ) async {
    // First of all validate the required parametrs
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required'));
    }

    return repository.getRelatedPosts(
      userId: params.userId,
      currentPost: params.currentPost,
      limit: params.limit,
    );
  }
}

class GetRelatedPostsThroughAlgorithmParams extends Equatable {
  final String userId;
  final Post currentPost;
  final int limit;

  const GetRelatedPostsThroughAlgorithmParams({
    required this.userId,
    required this.currentPost,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, currentPost, limit];
}
