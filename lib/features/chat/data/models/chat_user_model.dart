import '../../domain/entities/chat_user.dart';

class ChatUserModel {
  final String id;
  final String userId;
  final String fullName;
  final String role;
  final String? imageUrl;

  ChatUserModel({
    required this.id,
    required this.role,
    required this.userId,
    required this.fullName,
    this.imageUrl,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  ChatUser toEntity() {
    return ChatUser(
      id: id,
      role: role,
      userId: userId,
      fullName: fullName,
      imageUrl: imageUrl,
    );
  }
}
