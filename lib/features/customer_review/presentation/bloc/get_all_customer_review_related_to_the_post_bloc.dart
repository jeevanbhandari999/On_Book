import 'dart:async';

import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class GetAllCustomerReviewRelatedToThePostEvent extends Equatable {
  const GetAllCustomerReviewRelatedToThePostEvent();

  @override
  List<Object?> get props => [];
}

class GetAllCustomerReviewRelatedToThePostRequested
    extends GetAllCustomerReviewRelatedToThePostEvent {
  final String postId;
  final String? userId; // For future need

  const GetAllCustomerReviewRelatedToThePostRequested({
    required this.postId,
    this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

// States
abstract class GetAllCustomerReviewRelatedToThePostState extends Equatable {
  const GetAllCustomerReviewRelatedToThePostState();

  @override
  List<Object?> get props => [];
}

// Initial state
class GetAllCustomerReviewRelatedToThePostInitial
    extends GetAllCustomerReviewRelatedToThePostState {
  const GetAllCustomerReviewRelatedToThePostInitial();
}

// Loading class
class GetAllCustomerReviewRelatedToThePostLoading
    extends GetAllCustomerReviewRelatedToThePostState {
  const GetAllCustomerReviewRelatedToThePostLoading();
}

// Success state after get all rating requested
class GetAllCustomerReviewRelatedToThePostSuccess
    extends GetAllCustomerReviewRelatedToThePostInitial {
  final List<Rating> ratings;
  const GetAllCustomerReviewRelatedToThePostSuccess({required this.ratings});

  @override
  List<Object> get props => [ratings];
}

// Error state for failure case
class GetAllCustomerReviewRelatedToThePostError
    extends GetAllCustomerReviewRelatedToThePostState {
  final String message;
  const GetAllCustomerReviewRelatedToThePostError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class GetAllCustomerReviewRelatedToThePostBloc
    extends
        Bloc<
          GetAllCustomerReviewRelatedToThePostEvent,
          GetAllCustomerReviewRelatedToThePostState
        > {
  final GetAllCustomerReviewRelatedToPostUseCase
  _getAllCustomerReviewRelatedToPostUseCase;

  GetAllCustomerReviewRelatedToThePostBloc({
    required GetAllCustomerReviewRelatedToPostUseCase
    getAllCustomerReviewRelatedToPostUseCase,
  }) : _getAllCustomerReviewRelatedToPostUseCase =
           getAllCustomerReviewRelatedToPostUseCase,
       super(const GetAllCustomerReviewRelatedToThePostInitial()) {
    on<GetAllCustomerReviewRelatedToThePostRequested>(
      _onGetAllCustomerReviewRelatedToThePostRequested,
    );
  }

  Future<void> _onGetAllCustomerReviewRelatedToThePostRequested(
    GetAllCustomerReviewRelatedToThePostRequested event,
    Emitter<GetAllCustomerReviewRelatedToThePostState> emit,
  ) async {
    try {
      final getAllCustomerReviewRelatedToPostParams =
          GetAllCustomerReviewRelatedToPostParams(
            postId: event.postId,
            userId: event.userId,
          );

      final response = await _getAllCustomerReviewRelatedToPostUseCase(
        getAllCustomerReviewRelatedToPostParams,
      );

      response.fold(
        (failure) => emit(
          GetAllCustomerReviewRelatedToThePostError(message: failure.message),
        ),
        (customerReviewRatings) => emit(
          GetAllCustomerReviewRelatedToThePostSuccess(
            ratings: customerReviewRatings,
          ),
        ),
      );
    } catch (e) {
      emit(
        GetAllCustomerReviewRelatedToThePostError(
          message: 'Failed to fetch the customer review $e',
        ),
      );
    }
  }
}
