import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/repositories/customer_review_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetReviewReactionCountsUseCase {
  final CustomerReviewRepository repository;

  GetReviewReactionCountsUseCase(this.repository);

  Future<Either<Failure, Map<String, int>>> call(
    GetReviewReactionCountsParams params,
  ) async {
    if (params.ratingId.trim().isEmpty) {
      return const Left(ValidationFailure('Rating id is required'));
    }

    return repository.getReactionCounts(params.ratingId);
  }
}

// THough we don't need just for one params there is no need for params object, how ever
class GetReviewReactionCountsParams extends Equatable {
  final String ratingId;

  const GetReviewReactionCountsParams({required this.ratingId});

  @override
  List<Object> get props => [ratingId];
}
