import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
import 'package:app/features/customer_review/domain/repositories/customer_review_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ToggleReviewReactionUseCase {
  final CustomerReviewRepository repository;
  ToggleReviewReactionUseCase(this.repository);

  Future<Either<Failure, void>> call(ToggleReviewReactionParams params) async {
    // Validate the required parametrs first
    if (params.ratingId.trim().isEmpty) {
      return const Left(ValidationFailure('Rating id is required'));
    }

    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required'));
    }

    return await repository.toggleReaction(
      ratingId: params.ratingId,
      userId: params.userId,
      reaction: params.reaction,
    );
  }
}

class ToggleReviewReactionParams extends Equatable {
  final String ratingId;
  final String userId;
  final ReviewReactionType reaction;

  const ToggleReviewReactionParams({
    required this.ratingId,
    required this.userId,
    required this.reaction,
  });

  @override
  List<Object> get props => [ratingId, userId, reaction];
}
