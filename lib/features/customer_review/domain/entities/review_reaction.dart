import 'package:equatable/equatable.dart';

enum ReviewReactionType { like, dislike }

class ReviewReaction extends Equatable {
  final String id;
  final String ratingId;
  final String userId;
  final ReviewReactionType reaction;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewReaction({
    required this.id,
    required this.ratingId,
    required this.userId,
    required this.reaction,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
    id,
    ratingId,
    userId,
    reaction,
    createdAt,
    updatedAt,
  ];

  ReviewReaction copyWith({
    String? id,
    String? ratingId,
    String? userId,
    ReviewReactionType? reaction,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewReaction(
      id: id ?? this.id,
      ratingId: ratingId ?? this.ratingId,
      userId: userId ?? this.userId,
      reaction: reaction ?? this.reaction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
