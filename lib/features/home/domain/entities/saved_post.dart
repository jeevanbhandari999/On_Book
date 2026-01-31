import 'package:equatable/equatable.dart';

class SavedPost extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String organizationId;
  final DateTime savedAt;

  const SavedPost({
    required this.id,
    required this.postId,
    required this.userId,
    required this.organizationId,
    required this.savedAt,
  });

  @override
  List<Object> get props => [id, postId, userId, organizationId, savedAt];

  SavedPost copyWith({
    String? id,
    String? postId,
    String? userId,
    String? organizationId,
    DateTime? savedAt,
  }) {
    return SavedPost(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      organizationId: organizationId ?? this.organizationId,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
