import 'dart:async';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
// import 'package:app/features/customer_review/domain/usecases/get_review_reaction_count_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/stream_review_reaction_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/toggle_review_reaction_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events

abstract class ReviewReactionEvent extends Equatable {
  const ReviewReactionEvent();

  @override
  List<Object> get props => [];
}

/// Start listening to reactions (realtime)
class ReviewReactionStarted extends ReviewReactionEvent {
  final String ratingId;

  const ReviewReactionStarted(this.ratingId);

  @override
  List<Object> get props => [ratingId];
}

/// Toggle like/dislike
class ReviewReactionToggleRequested extends ReviewReactionEvent {
  final String ratingId;
  final String userId;
  final ReviewReactionType reaction;

  const ReviewReactionToggleRequested({
    required this.ratingId,
    required this.userId,
    required this.reaction,
  });

  @override
  List<Object> get props => [ratingId, userId, reaction];
}

// States

class ReviewReactionState extends Equatable {
  final bool loading;
  final int likes;
  final int dislikes;
  final List<ReviewReaction> reactions;
  final String? error;

  const ReviewReactionState({
    required this.loading,
    required this.likes,
    required this.dislikes,
    required this.reactions,
    this.error,
  });

  factory ReviewReactionState.initial() => const ReviewReactionState(
    loading: false,
    likes: 0,
    dislikes: 0,
    reactions: [],
    error: null,
  );

  ReviewReactionState copyWith({
    bool? loading,
    int? likes,
    int? dislikes,
    List<ReviewReaction>? reactions,
    String? error,
  }) {
    return ReviewReactionState(
      loading: loading ?? this.loading,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      reactions: reactions ?? this.reactions,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, likes, dislikes, reactions, error];
}

// BLoC
class ReviewReactionBloc
    extends Bloc<ReviewReactionEvent, ReviewReactionState> {
  final ToggleReviewReactionUseCase _toggleUseCase;
  final StreamReviewReactionsUseCase _streamUseCase;
  // final GetReviewReactionCountsUseCase _countUseCase;

  StreamSubscription? _reactionSubscription;

  ReviewReactionBloc({
    required ToggleReviewReactionUseCase toggleUseCase,
    required StreamReviewReactionsUseCase streamUseCase,
    // required GetReviewReactionCountsUseCase countUseCase,
  }) : _toggleUseCase = toggleUseCase,
       _streamUseCase = streamUseCase,
       //  _countUseCase = countUseCase,
       super(ReviewReactionState.initial()) {
    on<ReviewReactionStarted>(_onStarted);
    on<ReviewReactionToggleRequested>(_onToggle);
  }

  Future<void> _onStarted(
    ReviewReactionStarted event,
    Emitter<ReviewReactionState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    await _reactionSubscription?.cancel();

    await emit.forEach<Either<Failure, List<ReviewReaction>>>(
      _streamUseCase(StreamReviewReactionsParams(ratingId: event.ratingId)),
      onData: (either) => either.fold(
        (failure) =>
            state.copyWith(loading: false, error: _mapFailure(failure)),
        (reactions) {
          final likes = reactions
              .where((r) => r.reaction == ReviewReactionType.like)
              .length;
          final dislikes = reactions
              .where((r) => r.reaction == ReviewReactionType.dislike)
              .length;

          return state.copyWith(
            loading: false,
            reactions: reactions,
            likes: likes,
            dislikes: dislikes,
            error: null,
          );
        },
      ),
      onError: (error, stackTrace) =>
          state.copyWith(loading: false, error: error.toString()),
    );
  }

  // Future<void> _onToggle(
  //   ReviewReactionToggleRequested event,
  //   Emitter<ReviewReactionState> emit,
  // ) async {
  //   final result = await _toggleUseCase(
  //     ToggleReviewReactionParams(
  //       ratingId: event.ratingId,
  //       userId: event.userId,
  //       reaction: event.reaction,
  //     ),
  //   );

  //   result.fold(
  //     (failure) {
  //       emit(state.copyWith(error: _mapFailure(failure)));
  //     },
  //     (_) {
  //       // No state update here
  //       // Realtime stream will update automatically, we don't have to do
  //     },
  //   );
  // }

  // inside review_reaction_bloc.dart

  Future<void> _onToggle(
    ReviewReactionToggleRequested event,
    Emitter<ReviewReactionState> emit,
  ) async {
    // 1. KEEP A COPY OF THE OLD STATE (For rollback if API fails)
    final previousState = state;

    // 2. CALCULATE OPTIMISTIC DATA
    // We need to determine:
    // - Did the user already react?
    // - Are they removing a like? Switching from like to dislike? Adding a new like?

    final existingReactionIndex = state.reactions.indexWhere(
      (r) => r.userId == event.userId,
    );

    ReviewReaction? existingReaction;
    if (existingReactionIndex != -1) {
      existingReaction = state.reactions[existingReactionIndex];
    }

    // Create a modifiable copy of the list
    List<ReviewReaction> newReactionsList = List.from(state.reactions);

    // Calculate new counts
    int newLikes = state.likes;
    int newDislikes = state.dislikes;

    if (existingReaction == null) {
      // SCENARIO A: No previous reaction -> ADD NEW REACTION
      newReactionsList.add(
        ReviewReaction(
          id: 'temp_id', // distinct ID not needed for UI logic usually
          ratingId: event.ratingId,
          userId: event.userId,
          reaction: event.reaction,
          createdAt: DateTime.now(), // Use standard package if needed
          updatedAt: DateTime.now(),
        ),
      );

      if (event.reaction == ReviewReactionType.like) newLikes++;
      if (event.reaction == ReviewReactionType.dislike) newDislikes++;
    } else {
      if (existingReaction.reaction == event.reaction) {
        // SCENARIO B: Tapping same reaction -> REMOVE REACTION
        newReactionsList.removeAt(existingReactionIndex);

        if (event.reaction == ReviewReactionType.like) newLikes--;
        if (event.reaction == ReviewReactionType.dislike) newDislikes--;
      } else {
        // SCENARIO C: Switching (e.g., Like -> Dislike) -> UPDATE REACTION
        // Remove old count
        if (existingReaction.reaction == ReviewReactionType.like) newLikes--;
        if (existingReaction.reaction == ReviewReactionType.dislike) {
          newDislikes--;
        }

        // Add new count
        if (event.reaction == ReviewReactionType.like) newLikes++;
        if (event.reaction == ReviewReactionType.dislike) newDislikes++;

        // Update the object in the list
        newReactionsList[existingReactionIndex] = existingReaction.copyWith(
          reaction: event.reaction,
        );
      }
    }

    // 3. EMIT OPTIMISTIC STATE IMMEDIATELY
    emit(
      state.copyWith(
        reactions: newReactionsList,
        likes: newLikes,
        dislikes: newDislikes,
      ),
    );

    // 4. CALL THE API
    final result = await _toggleUseCase(
      ToggleReviewReactionParams(
        ratingId: event.ratingId,
        userId: event.userId,
        reaction: event.reaction,
      ),
    );

    // 5. HANDLE FAILURE (Rollback)
    result.fold(
      (failure) {
        // If server failed, revert to the previous state immediately
        emit(previousState.copyWith(error: _mapFailure(failure)));
      },
      (_) {
        // Success! Do nothing.
        // The Supabase Stream will eventually arrive with the "real" server data,
        // which should match our optimistic data closely.
      },
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is ValidationFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    return 'Unexpected error occurred';
  }

  @override
  Future<void> close() async {
    await _reactionSubscription?.cancel();
    return super.close();
  }
}
