import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
import 'package:app/features/customer_review/domain/repositories/customer_review_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class StreamReviewReactionsUseCase {
  final CustomerReviewRepository repository;

  StreamReviewReactionsUseCase(this.repository);

  Stream<Either<Failure, List<ReviewReaction>>> call(
    StreamReviewReactionsParams params,
  ) {
    if (params.ratingId.trim().isEmpty) {
      return Stream.value(
        const Left(ValidationFailure('Rating id is required')),
      );
    }
    return repository.streamReactions(params.ratingId);
  }
}

// THough we don't need just for one params there is no need for params object, how ever
class StreamReviewReactionsParams extends Equatable {
  final String ratingId;

  const StreamReviewReactionsParams({required this.ratingId});

  @override
  List<Object> get props => [ratingId];
}
