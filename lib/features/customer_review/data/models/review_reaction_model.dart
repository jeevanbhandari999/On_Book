import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
import 'package:equatable/equatable.dart';

class ReviewReactionModel extends Equatable {
  final String id;
  final String ratingId;
  final String userId;
  final ReviewReactionType reaction;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewReactionModel({
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

  factory ReviewReactionModel.fromJson(Map<String, dynamic> json) {
    return ReviewReactionModel(
      id: json['id'] as String,
      ratingId: json['rating_id'] as String,
      userId: json['user_id'] as String,
      reaction: _mapReaction(json['reaction'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rating_id': ratingId,
    'user_id': userId,
    'reaction': reaction,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Map<String, dynamic> toCreateJson() {
    return {
      'rating_id': ratingId,
      'user_id': userId,
      'reaction': reaction.name,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {'reaction': reaction.name, 'updated_at': updatedAt};
  }

  factory ReviewReactionModel.fromEntity(ReviewReaction entity) {
    return ReviewReactionModel(
      id: entity.id,
      ratingId: entity.ratingId,
      userId: entity.userId,
      reaction: entity.reaction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ReviewReaction toEntity() => ReviewReaction(
    id: id,
    ratingId: ratingId,
    userId: userId,
    reaction: reaction,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static ReviewReactionType _mapReaction(String value) {
    switch (value) {
      case 'like':
        return ReviewReactionType.like;
      case 'dislike':
        return ReviewReactionType.dislike;
      default:
        throw Exception('Invalid reaction type');
    }
  }
}
