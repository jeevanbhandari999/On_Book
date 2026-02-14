import '../../domain/entities/chat_user.dart';

class ChatUserModel {
  final String id;
  final String userId;
  final String fullName;
  final String? imageUrl;

  ChatUserModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.imageUrl,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'],
      userId: json['user_id'],
      fullName: json['full_name'],
      imageUrl: json['image_url'],
    );
  }

  ChatUser toEntity() {
    return ChatUser(
      id: id,
      userId: userId,
      fullName: fullName,
      imageUrl: imageUrl,
    );
  }
}
