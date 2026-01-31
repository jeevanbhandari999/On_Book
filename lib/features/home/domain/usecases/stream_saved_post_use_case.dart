import 'package:app/core/errors/failures.dart';
import 'package:app/features/home/domain/entities/saved_post.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class StreamSavedPostsUseCase {
  final HomeRepository repository;

  StreamSavedPostsUseCase(this.repository);

  Stream<Either<Failure, List<SavedPost>>> call(
    StreamSavedPostsParams params,
  ) {
    // Validation
    if (params.userId.trim().isEmpty) {
      return Stream.value(
        const Left(ValidationFailure('User id is required')),
      );
    }

    return repository.streamSavedPosts(params.userId);
  }
}

class StreamSavedPostsParams {
  final String userId;

  const StreamSavedPostsParams({required this.userId});
}
