import 'dart:async';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
// import 'package:app/features/customer_review/domain/usecases/get_review_reaction_count_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/stream_review_reaction_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/toggle_review_reaction_use_case.dart';
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

    _reactionSubscription =
        _streamUseCase(
          StreamReviewReactionsParams(ratingId: event.ratingId),
        ).listen((either) {
          either.fold(
            (failure) {
              emit(state.copyWith(error: _mapFailure(failure), loading: false));
            },
            (reactions) {
              final likes = reactions
                  .where((r) => r.reaction == ReviewReactionType.like)
                  .length;
              final dislikes = reactions
                  .where((r) => r.reaction == ReviewReactionType.dislike)
                  .length;

              emit(
                state.copyWith(
                  loading: false,
                  reactions: reactions,
                  likes: likes,
                  dislikes: dislikes,
                  error: null,
                ),
              );
            },
          );
        });
  }

  Future<void> _onToggle(
    ReviewReactionToggleRequested event,
    Emitter<ReviewReactionState> emit,
  ) async {
    final result = await _toggleUseCase(
      ToggleReviewReactionParams(
        ratingId: event.ratingId,
        userId: event.userId,
        reaction: event.reaction,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(error: _mapFailure(failure)));
      },
      (_) {
        // No state update here
        // Realtime stream will update automatically, we don't have to do
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
