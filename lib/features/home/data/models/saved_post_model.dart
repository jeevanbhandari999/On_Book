import 'package:app/features/home/domain/entities/saved_post.dart';
import 'package:equatable/equatable.dart';

class SavedPostModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String organizationId;
  final DateTime savedAt;

  const SavedPostModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.organizationId,
    required this.savedAt,
  });

  @override
  List<Object> get props => [id, postId, userId, organizationId, savedAt];

  /// FROM JSON (DB → APP)
  factory SavedPostModel.fromJson(Map<String, dynamic> json) {
    return SavedPostModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      organizationId: json['organization_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
    );
  }

  /// FULL JSON (rarely needed)
  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'user_id': userId,
    'organization_id': organizationId,
    'saved_at': savedAt.toIso8601String(),
  };

  /// CREATE JSON (insert)
  Map<String, dynamic> toCreateJson() => {
    'post_id': postId,
    'user_id': userId,
    'organization_id': organizationId,
  };

  /// ENTITY → MODEL
  factory SavedPostModel.fromEntity(SavedPost entity) {
    return SavedPostModel(
      id: entity.id,
      postId: entity.postId,
      userId: entity.userId,
      organizationId: entity.organizationId,
      savedAt: entity.savedAt,
    );
  }

  /// MODEL → ENTITY
  SavedPost toEntity() => SavedPost(
    id: id,
    postId: postId,
    userId: userId,
    organizationId: organizationId,
    savedAt: savedAt,
  );
}
