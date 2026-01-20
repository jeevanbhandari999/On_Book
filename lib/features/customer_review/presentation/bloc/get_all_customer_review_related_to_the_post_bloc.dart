import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:equatable/equatable.dart';

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
