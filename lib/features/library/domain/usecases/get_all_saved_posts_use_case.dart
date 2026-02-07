import 'package:app/core/errors/failures.dart';
import 'package:app/features/library/domain/repositories/library_repository.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllSavedPostsUseCase {
  final LibraryRepository repository;
  GetAllSavedPostsUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call(
    GetAllSavedPostsParams params,
  ) async {
    // First of all validate the required fields;
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required'));
    }

    return await repository.getAllSavedPosts(params.userId);
  }
}

class GetAllSavedPostsParams extends Equatable {
  final String userId;

  const GetAllSavedPostsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
