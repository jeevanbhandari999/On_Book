import 'package:app/core/errors/failures.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllPostRecommendedByContentFilterUseCase {
  final HomeRepository repository;

  GetAllPostRecommendedByContentFilterUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call(
    GetAllPostRecommendedByContentFilterParams params,
  ) async {
    // Validate user ID
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    return await repository.getRecommendedPosts(
      userId: params.userId,
      longitude: params.longitude,
      latitude: params.latitude,
      limit: params.limit,
    );
  }
}

class GetAllPostRecommendedByContentFilterParams extends Equatable {
  final String userId;
  final double? latitude;
  final double? longitude;
  final int limit;

  const GetAllPostRecommendedByContentFilterParams({
    required this.userId,
    this.longitude,
    this.latitude,
    this.limit = 15,
  });

  @override
  List<Object?> get props => [userId, longitude, latitude, limit];
}
