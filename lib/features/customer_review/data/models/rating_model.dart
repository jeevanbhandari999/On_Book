import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:equatable/equatable.dart';

class RatingModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final int ratingValue;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RatingModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.ratingValue,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      ratingValue: json['rating_value'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'rating_value': ratingValue,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'rating_value': ratingValue,
      'comment': comment,
      // // No need just provide the current date time also in the db there is already a default current time
      // 'created_at': createdAt.toIso8601String(),
      // 'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'rating_value': ratingValue,
      'comment': comment,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RatingModel.fromEntity(Rating entity) {
    return RatingModel(
      id: entity.id,
      postId: entity.postId,
      userId: entity.userId,
      ratingValue: entity.ratingValue,
      comment: entity.comment,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Rating toEntity() => Rating(
    id: id,
    postId: postId,
    userId: userId,
    ratingValue: ratingValue,
    comment: comment,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  RatingModel copyWith({
    String? id,
    String? postId,
    String? userId,
    int? ratingValue,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      ratingValue: ratingValue ?? this.ratingValue,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    ratingValue,
    comment,
    createdAt,
    updatedAt,
  ];
}
