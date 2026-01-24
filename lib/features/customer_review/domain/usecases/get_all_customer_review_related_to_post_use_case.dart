import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/repositories/customer_review_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllCustomerReviewRelatedToPostUseCase {
  final CustomerReviewRepository repository;

  GetAllCustomerReviewRelatedToPostUseCase(this.repository);

  Future<Either<Failure, List<Rating>>> call(
    GetAllCustomerReviewRelatedToPostParams params,
  ) async {
    // Validate post ID
    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID is required'));
    }

    final data = await repository.getAllUserRatingsRelatedToThePost(
      params.postId,
      params.userId,
    );

    return data;
  }
}

class GetAllCustomerReviewRelatedToPostParams extends Equatable {
  final String postId;
  final String? userId; // Made optional for

  const GetAllCustomerReviewRelatedToPostParams({
    required this.postId,
    this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}
