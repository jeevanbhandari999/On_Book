import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final int ratingValue;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Rating({
    required this.id,
    required this.postId,
    required this.userId,
    required this.ratingValue,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  Rating copyWith({
    String? id,
    String? postId,
    String? userId,
    int? ratingValue,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rating(
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
