// // import 'package:equatable/equatable.dart';

// // // Events
// // abstract class CreateCustomerReviewEvent extends Equatable {
// //   const CreateCustomerReviewEvent();

// //   @override
// //   List<Object?> get props => [];
// // }

// // class CreateCustomerReviewRatingValueChanged extends CreateCustomerReviewEvent {
// //   final int ratingValue;

// //   const CreateCustomerReviewRatingValueChanged({required this.ratingValue});

// //   @override
// //   List<Object?> get props => [ratingValue];
// // }

// // class CreateCustomerReviewCommentChanged extends CreateCustomerReviewEvent {
// //   final String comment;

// //   const CreateCustomerReviewCommentChanged({required this.comment});

// //   @override
// //   List<Object?> get props => [comment];
// // }

// // class CreateCustomerReviewRequested extends CreateCustomerReviewEvent {
// //   final String userId;
// //   final String postId;
// //   final int ratingValue;
// //   final String? comment;

// //   const CreateCustomerReviewRequested({
// //     required this.userId,
// //     required this.postId,
// //     required this.ratingValue,
// //     this.comment,
// //   });
// // }

// // // States
// // abstract class CreateCustomerReviewState extends Equatable {
// //   const CreateCustomerReviewState();

// //   @override
// //   List<Object?> get props => [];
// // }

// // class CreateCustomerReviewInitial extends CreateCustomerReviewState {
// //   const CreateCustomerReviewInitial();
// // }

// // class CreateCustomerReviewLoading extends CreateCustomerReviewState {
// //   const CreateCustomerReviewLoading();
// // }

// import 'package:app/features/customer_review/domain/usecases/create_customer_review_for_specific_post_use_case.dart';
// import 'package:equatable/equatable.dart';
// import 'package:app/core/errors/failures.dart';
// import 'package:app/features/customer_review/domain/entities/rating.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// abstract class CreateReviewEvent extends Equatable {
//   const CreateReviewEvent();

//   @override
//   List<Object?> get props => [];
// }

// class RatingChanged extends CreateReviewEvent {
//   final int rating;
//   const RatingChanged(this.rating);

//   @override
//   List<Object?> get props => [rating];
// }

// class CommentChanged extends CreateReviewEvent {
//   final String comment;
//   const CommentChanged(this.comment);

//   @override
//   List<Object?> get props => [comment];
// }

// class SubmitReview extends CreateReviewEvent {
//   final String userId;
//   final String postId;
//   const SubmitReview({
//     required this.postId,
//     required this.userId,
//   });

//   @override
//   List<Object?> get props => [postId, userId];
// }

// enum ReviewSubmissionStatus { initial, invalid, submitting, success, failure }

// class CreateReviewState extends Equatable {
//   final int rating;
//   final String comment;
//   final bool isSubmitEnabled;
//   final ReviewSubmissionStatus status;
//   final String? errorMessage;
//   final Rating? createdRating;

//   const CreateReviewState({
//     required this.rating,
//     required this.comment,
//     required this.isSubmitEnabled,
//     required this.status,
//     this.errorMessage,
//     this.createdRating,
//   });

//   const CreateReviewState.initial()
//     : this(
//         rating: 0,
//         comment: '',
//         isSubmitEnabled: false,
//         status: ReviewSubmissionStatus.initial,
//       );

//   CreateReviewState copyWith({
//     int? rating,
//     String? comment,
//     bool? isSubmitEnabled,
//     ReviewSubmissionStatus? status,
//     String? errorMessage,
//     Rating? createdRating,
//   }) {
//     return CreateReviewState(
//       rating: rating ?? this.rating,
//       comment: comment ?? this.comment,
//       isSubmitEnabled: isSubmitEnabled ?? this.isSubmitEnabled,
//       status: status ?? this.status,
//       errorMessage: errorMessage,
//       createdRating: createdRating ?? this.createdRating,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     rating,
//     comment,
//     isSubmitEnabled,
//     status,
//     errorMessage,
//     createdRating,
//   ];
// }

// class CreateReviewBloc extends Bloc<CreateReviewEvent, CreateReviewState> {
//   final CreateCustomerReviewForSpecificPostUseCase
//   _createCustomerReviewForSpecificPostUseCase;

//   CreateReviewBloc({
//     required CreateCustomerReviewForSpecificPostUseCase
//     createCustomerReviewForSpecificPostUseCase,
//   }) : _createCustomerReviewForSpecificPostUseCase =
//            createCustomerReviewForSpecificPostUseCase,
//        super(const CreateReviewState.initial()) {
//     on<RatingChanged>(_onRatingChanged);
//     on<CommentChanged>(_onCommentChanged);
//     on<SubmitReview>(_onSubmitReview);
//   }

//   void _onRatingChanged(RatingChanged event, Emitter<CreateReviewState> emit) {
//     emit(
//       state.copyWith(rating: event.rating, isSubmitEnabled: event.rating >= 1),
//     );
//   }

//   void _onCommentChanged(
//     CommentChanged event,
//     Emitter<CreateReviewState> emit,
//   ) {
//     emit(state.copyWith(comment: event.comment));
//   }

//   Future<void> _onSubmitReview(
//     SubmitReview event,
//     Emitter<CreateReviewState> emit,
//   ) async {
//     if (state.rating < 1) {
//       emit(state.copyWith(status: ReviewSubmissionStatus.invalid));
//       return;
//     }

//     emit(state.copyWith(status: ReviewSubmissionStatus.submitting));

//     final params = CreateCustomerReviewForSpecificPostParams(
//       userId: event.userId,
//       postId: event.postId,
//       ratingValue: state.rating,
//       comment: state.comment.isEmpty ? null : state.comment,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );

//     final result = await _createCustomerReviewForSpecificPostUseCase(params);

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           status: ReviewSubmissionStatus.failure,
//           errorMessage: _mapFailureToMessage(failure),
//         ),
//       ),
//       (rating) => emit(
//         state.copyWith(
//           status: ReviewSubmissionStatus.success,
//           createdRating: rating,
//         ),
//       ),
//     );
//   }

//   String _mapFailureToMessage(Failure failure) {
//     if (failure is ValidationFailure) return failure.message;
//     if (failure is ServerFailure) return 'Server error occurred';
//     if (failure is NetworkFailure) return 'No internet connection';
//     return 'An unexpected error occurred';
//   }

//   @override
//   Future<void> close() {
//     // Clean up if needed (e.g. cancel timers, streams…)
//     return super.close();
//   }
// }


import 'package:app/core/errors/failures.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/usecases/create_customer_review_for_specific_post_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────

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

  const CreateReviewRequested({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

// ── States ────────────────────────────────────────────────────────────────

abstract class CreateCustomerReviewState extends Equatable {
  const CreateCustomerReviewState();

  @override
  List<Object?> get props => [];
}

class CreateCustomerReviewInitial extends CreateCustomerReviewState {
  final int rating;
  final String comment;

  const CreateCustomerReviewInitial({
    this.rating = 0,
    this.comment = '',
  });

  bool get canSubmit => rating >= 1;

  @override
  List<Object?> get props => [rating, comment];
}

class CreateCustomerReviewLoading extends CreateCustomerReviewState {
  final int rating;
  final String comment;

  const CreateCustomerReviewLoading({
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [rating, comment];
}

class CreateCustomerReviewValidationError extends CreateCustomerReviewState {
  final int rating;
  final String comment;
  final String message;

  const CreateCustomerReviewValidationError({
    required this.rating,
    required this.comment,
    required this.message,
  });

  @override
  List<Object?> get props => [rating, comment, message];
}

class CreateCustomerReviewSuccess extends CreateCustomerReviewState {
  final Rating ratingEntity;

  const CreateCustomerReviewSuccess({required this.ratingEntity});

  @override
  List<Object?> get props => [ratingEntity];
}

class CreateCustomerReviewError extends CreateCustomerReviewState {
  final String message;

  const CreateCustomerReviewError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────

class CreateCustomerReviewBloc
    extends Bloc<CreateCustomerReviewEvent, CreateCustomerReviewState> {
  final CreateCustomerReviewForSpecificPostUseCase _useCase;

  CreateCustomerReviewBloc({
    required CreateCustomerReviewForSpecificPostUseCase useCase,
  })  : _useCase = useCase,
        super(const CreateCustomerReviewInitial()) {
    on<RatingValueChanged>(_onRatingChanged);
    on<CommentChanged>(_onCommentChanged);
    on<CreateReviewRequested>(_onCreateReviewRequested);
  }

  void _onRatingChanged(
    RatingValueChanged event,
    Emitter<CreateCustomerReviewState> emit,
  ) {
    if (state is CreateCustomerReviewInitial) {
      final current = state as CreateCustomerReviewInitial;
      emit(CreateCustomerReviewInitial(
        rating: event.rating,
        comment: current.comment,
      ));
    } else if (state is CreateCustomerReviewValidationError) {
      final current = state as CreateCustomerReviewValidationError;
      emit(CreateCustomerReviewInitial(
        rating: event.rating,
        comment: current.comment,
      ));
    }
    // other states → ignore change or handle differently if needed
  }

  void _onCommentChanged(
    CommentChanged event,
    Emitter<CreateCustomerReviewState> emit,
  ) {
    if (state is CreateCustomerReviewInitial) {
      final current = state as CreateCustomerReviewInitial;
      emit(CreateCustomerReviewInitial(
        rating: current.rating,
        comment: event.comment,
      ));
    } else if (state is CreateCustomerReviewValidationError) {
      final current = state as CreateCustomerReviewValidationError;
      emit(CreateCustomerReviewInitial(
        rating: current.rating,
        comment: event.comment,
      ));
    }
    // other states → ignore or handle differently
  }

  Future<void> _onCreateReviewRequested(
    CreateReviewRequested event,
    Emitter<CreateCustomerReviewState> emit,
  ) async {
    final currentState = state;

    int currentRating = 0;
    String currentComment = '';

    if (currentState is CreateCustomerReviewInitial) {
      currentRating = currentState.rating;
      currentComment = currentState.comment;
    } else if (currentState is CreateCustomerReviewValidationError) {
      currentRating = currentState.rating;
      currentComment = currentState.comment;
    } else if (currentState is CreateCustomerReviewLoading) {
      currentRating = currentState.rating;
      currentComment = currentState.comment;
    } else {
      // unexpected state → reset to initial
      emit(const CreateCustomerReviewInitial());
      return;
    }

    if (currentRating < 1) {
      emit(CreateCustomerReviewValidationError(
        rating: currentRating,
        comment: currentComment,
        message: 'Please select a rating',
      ));
      return;
    }

    emit(CreateCustomerReviewLoading(
      rating: currentRating,
      comment: currentComment,
    ));

    final params = CreateCustomerReviewForSpecificPostParams(
      userId: event.userId,
      postId: event.postId,
      ratingValue: currentRating,
      comment: currentComment.isEmpty ? null : currentComment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _useCase(params);

    result.fold(
      (failure) {
        emit(CreateCustomerReviewError(
          message: _mapFailureToMessage(failure),
        ));
      },
      (createdRating) {
        emit(CreateCustomerReviewSuccess(
          ratingEntity: createdRating,
        ));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    }
    return 'Failed to submit review. Please try again.';
  }
}