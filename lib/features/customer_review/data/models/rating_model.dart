import 'package:equatable/equatable.dart';

class RatingModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final int ratingValue;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RatingModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.ratingValue,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      ratingValue: json['rating_value'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  

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
  List<Object> get props => [
    id,
    postId,
    userId,
    ratingValue,
    comment,
    createdAt,
    updatedAt,
  ];
}
