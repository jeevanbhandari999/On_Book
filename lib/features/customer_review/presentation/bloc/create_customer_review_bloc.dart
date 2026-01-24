import 'dart:async';

import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/usecases/create_customer_review_for_specific_post_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class CreateCustomerReviewEvent extends Equatable {
  const CreateCustomerReviewEvent();

  @override
  List<Object?> get props => [];
}

class RatingValueChanged extends CreateCustomerReviewEvent {
  final int rating;

  const RatingValueChanged({required this.rating});

  @override
  List<Object?> get props => [rating];
}

class CommentChanged extends CreateCustomerReviewEvent {
  final String comment;

  const CommentChanged({required this.comment});

  @override
  List<Object?> get props => [comment];
}

class CreateReviewRequested extends CreateCustomerReviewEvent {
  final String postId;
  final String userId;
  final int ratingValue;
  final String? comment;

  const CreateReviewRequested({
    required this.postId,
    required this.userId,
    required this.ratingValue,
    this.comment,
  });

  @override
  List<Object?> get props => [postId, userId];
}

// States
abstract class CreateCustomerReviewState extends Equatable {
  const CreateCustomerReviewState();

  @override
  List<Object?> get props => [];
}

class CreateCustomerReviewInitial extends CreateCustomerReviewState {
  const CreateCustomerReviewInitial();
}

class CreateCustomerReviewLoading extends CreateCustomerReviewState {
  const CreateCustomerReviewLoading();
}

class CreateCustomerReviewValidationError extends CreateCustomerReviewState {
  final String message;

  const CreateCustomerReviewValidationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateCustomerReviewSuccess extends CreateCustomerReviewState {
  final Rating ratingResponse;

  const CreateCustomerReviewSuccess({required this.ratingResponse});

  @override
  List<Object?> get props => [ratingResponse];
}

class CreateCustomerReviewError extends CreateCustomerReviewState {
  final String message;

  const CreateCustomerReviewError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class CreateCustomerReviewBloc
    extends Bloc<CreateCustomerReviewEvent, CreateCustomerReviewState> {
  final CreateCustomerReviewForSpecificPostUseCase
  _createCustomerReviewForSpecificPostUseCase;

  CreateCustomerReviewBloc({
    required CreateCustomerReviewForSpecificPostUseCase
    createCustomerReviewForSpecificPostUseCase,
  }) : _createCustomerReviewForSpecificPostUseCase =
           createCustomerReviewForSpecificPostUseCase,
       super(const CreateCustomerReviewInitial()) {
    on<RatingValueChanged>(_onRatingChanged);
    on<CommentChanged>(_onCommentChanged);
    on<CreateReviewRequested>(_onCreateReviewRequested);
  }

  // void _onRatingChanged(
  //   RatingValueChanged event,
  //   Emitter<CreateCustomerReviewState> emit,
  // ) {
  //   if (state is CreateCustomerReviewInitial) {
  //     final current = state as CreateCustomerReviewInitial;
  //     emit(
  //       CreateCustomerReviewInitial(
  //         rating: event.rating,
  //         comment: current.comment,
  //       ),
  //     );
  //   } else if (state is CreateCustomerReviewValidationError) {
  //     final current = state as CreateCustomerReviewValidationError;
  //     emit(
  //       CreateCustomerReviewInitial(
  //         rating: event.rating,
  //         comment: current.comment,
  //       ),
  //     );
  //   }
  //   // other states → ignore change or handle differently if needed
  // }

  // void _onCommentChanged(
  //   CommentChanged event,
  //   Emitter<CreateCustomerReviewState> emit,
  // ) {
  //   if (state is CreateCustomerReviewInitial) {
  //     final current = state as CreateCustomerReviewInitial;
  //     emit(
  //       CreateCustomerReviewInitial(
  //         rating: current.rating,
  //         comment: event.comment,
  //       ),
  //     );
  //   } else if (state is CreateCustomerReviewValidationError) {
  //     final current = state as CreateCustomerReviewValidationError;
  //     emit(
  //       CreateCustomerReviewInitial(
  //         rating: current.rating,
  //         comment: event.comment,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _onCreateReviewRequested(
  //   CreateReviewRequested event,
  //   Emitter<CreateCustomerReviewState> emit,
  // ) async {
  //   final currentState = state;

  //   int currentRating = 0;
  //   String currentComment = '';

  //   if (currentState is CreateCustomerReviewInitial) {
  //     currentRating = currentState.rating;
  //     currentComment = currentState.comment;
  //   } else if (currentState is CreateCustomerReviewValidationError) {
  //     currentRating = currentState.rating;
  //     currentComment = currentState.comment;
  //   } else if (currentState is CreateCustomerReviewLoading) {
  //     currentRating = currentState.rating;
  //     currentComment = currentState.comment;
  //   } else {
  //     // unexpected state → reset to initial
  //     emit(const CreateCustomerReviewInitial());
  //     return;
  //   }

  //   if (currentRating < 1) {
  //     emit(
  //       CreateCustomerReviewValidationError(
  //         rating: currentRating,
  //         comment: currentComment,
  //         message: 'Please select a rating',
  //       ),
  //     );
  //     return;
  //   }

  //   emit(
  //     CreateCustomerReviewLoading(
  //       rating: currentRating,
  //       comment: currentComment,
  //     ),
  //   );

  //   final params = CreateCustomerReviewForSpecificPostParams(
  //     userId: event.userId,
  //     postId: event.postId,
  //     ratingValue: currentRating,
  //     comment: currentComment.isEmpty ? null : currentComment,
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   );

  //   final result = await _useCase(params);

  //   result.fold(
  //     (failure) {
  //       emit(CreateCustomerReviewError(message: _mapFailureToMessage(failure)));
  //     },
  //     (createdRating) {
  //       emit(CreateCustomerReviewSuccess(ratingEntity: createdRating));
  //     },
  //   );
  // }

  // String _mapFailureToMessage(Failure failure) {
  //   if (failure is ValidationFailure) {
  //     return failure.message;
  //   }
  //   return 'Failed to submit review. Please try again.';
  // }

  FutureOr<void> _onRatingChanged(
    RatingValueChanged event,
    Emitter<CreateCustomerReviewState> emit,
  ) {}

  FutureOr<void> _onCommentChanged(
    CommentChanged event,
    Emitter<CreateCustomerReviewState> emit,
  ) {}

  FutureOr<void> _onCreateReviewRequested(
    CreateReviewRequested event,
    Emitter<CreateCustomerReviewState> emit,
  ) async {
    emit(const CreateCustomerReviewLoading());
    try {
      final createRatingParams = CreateCustomerReviewForSpecificPostParams(
        userId: event.userId,
        postId: event.postId,
        ratingValue: event.ratingValue,
        comment: event.comment,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _createCustomerReviewForSpecificPostUseCase(
        createRatingParams,
      );
      response.fold(
        (failure) => emit(CreateCustomerReviewError(message: failure.message)),
        (succesResponse) =>
            emit(CreateCustomerReviewSuccess(ratingResponse: succesResponse)),
      );
    } catch (e) {
      emit(CreateCustomerReviewError(message: e.toString()));
    }
  }
}
