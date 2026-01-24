import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/repositories/customer_review_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CreateCustomerReviewForSpecificPostUseCase {
  final CustomerReviewRepository repository;
  CreateCustomerReviewForSpecificPostUseCase(this.repository);

  Future<Either<Failure, Rating>> call(
    CreateCustomerReviewForSpecificPostParams params,
  ) async {
    // Validate required parameters
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID is required'));
    }

    if (params.ratingValue == 0) {
      return const Left(ValidationFailure('Ratign value is required'));
    }

    final now = DateTime.now();

    final customerRating = Rating(
      id: '',
      postId: params.postId,
      userId: params.userId,
      ratingValue: params.ratingValue,
      comment: params.comment,
      createdAt: now,
      updatedAt: now,
    );

    // Finally create the custoemr review
    return await repository.createRating(
      params.postId,
      params.postId,
      customerRating,
    );
  }
}

class CreateCustomerReviewForSpecificPostParams extends Equatable {
  final String userId;
  final String postId;
  final int ratingValue;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreateCustomerReviewForSpecificPostParams({
    required this.userId,
    required this.postId,
    required this.ratingValue,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    postId,
    ratingValue,
    comment,
    createdAt,
    updatedAt,
  ];
}
