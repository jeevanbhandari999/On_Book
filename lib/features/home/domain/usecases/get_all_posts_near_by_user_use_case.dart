import 'package:app/core/errors/failures.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllPostsNearByUserUseCase {
  final HomeRepository repository;

  GetAllPostsNearByUserUseCase(this.repository);

  Future<Either<Failure, ({String? nextCursor, List<Post> posts})>> call(
    GetAllPostsNearByUserParams params,
  ) async {
    // Validate user ID
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    return await repository.getNearByPosts(
      userId: params.userId,
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

class GetAllPostsNearByUserParams extends Equatable {
  final String userId;
  final double? latitude;
  final double? longitude;
  final int limit;
  final String? cursor;

  const GetAllPostsNearByUserParams({
    required this.userId,
    this.latitude,
    this.longitude,
    this.limit = 15,
    this.cursor,
  });
  @override
  List<Object?> get props => [userId, latitude, longitude, limit, cursor];
}
