import 'dart:async';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//  Events

abstract class PostRatingSummaryEvent extends Equatable {
  const PostRatingSummaryEvent();
  @override
  List<Object?> get props => [];
}

class PostRatingSummaryRequested extends PostRatingSummaryEvent {
  final String postId;
  const PostRatingSummaryRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

//  States─

abstract class PostRatingSummaryState extends Equatable {
  const PostRatingSummaryState();
  @override
  List<Object?> get props => [];
}

class PostRatingSummaryInitial extends PostRatingSummaryState {
  const PostRatingSummaryInitial();
}

class PostRatingSummaryLoading extends PostRatingSummaryState {
  const PostRatingSummaryLoading();
}

class PostRatingSummaryLoaded extends PostRatingSummaryState {
  final double average; // e.g. 4.3
  final int reviewCount; // e.g. 12

  const PostRatingSummaryLoaded({
    required this.average,
    required this.reviewCount,
  });

  @override
  List<Object?> get props => [average, reviewCount];
}

class PostRatingSummaryError extends PostRatingSummaryState {
  // Silent failure — card just shows nothing instead of crashing
  const PostRatingSummaryError();
}

//  BLoC─

class PostRatingSummaryBloc
    extends Bloc<PostRatingSummaryEvent, PostRatingSummaryState> {
  final GetAllCustomerReviewRelatedToPostUseCase _getReviewsUseCase;

  PostRatingSummaryBloc({
    required GetAllCustomerReviewRelatedToPostUseCase getReviewsUseCase,
  }) : _getReviewsUseCase = getReviewsUseCase,
       super(const PostRatingSummaryInitial()) {
    on<PostRatingSummaryRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PostRatingSummaryRequested event,
    Emitter<PostRatingSummaryState> emit,
  ) async {
    emit(const PostRatingSummaryLoading());
    try {
      final result = await _getReviewsUseCase(
        GetAllCustomerReviewRelatedToPostParams(postId: event.postId),
      );

      result.fold((_) => emit(const PostRatingSummaryError()), (ratings) {
        if (ratings.isEmpty) {
          emit(const PostRatingSummaryLoaded(average: 0, reviewCount: 0));
          return;
        }
        final avg =
            ratings.fold<double>(0, (sum, r) => sum + r.ratingValue) /
            ratings.length;
        emit(
          PostRatingSummaryLoaded(
            average: double.parse(avg.toStringAsFixed(1)),
            reviewCount: ratings.length,
          ),
        );
      });
    } catch (_) {
      emit(const PostRatingSummaryError());
    }
  }
}
