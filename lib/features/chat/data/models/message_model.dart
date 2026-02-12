import 'package:app/features/chat/domain/entities/message.dart';
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.type,
    this.text,
    this.mediaUrl,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      text: json['text'],
      mediaUrl: json['media_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'type': type.name,
      'text': text,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'room_id': roomId,
      'sender_id': senderId,
      'type': type.name,
      'text': text,
      'media_url': mediaUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() => {};

  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      id: entity.id,
      roomId: entity.roomId,
      senderId: entity.senderId,
      type: entity.type,
      text: entity.text,
      mediaUrl: entity.mediaUrl,
      createdAt: entity.createdAt,
    );
  }

  Message toEntity() => Message(
        id: id,
        roomId: roomId,
        senderId: senderId,
        type: type,
        text: text,
        mediaUrl: mediaUrl,
        createdAt: createdAt,
      );

  MessageModel copyWith({
    String? id,
    String? roomId,
    String? senderId,
    MessageType? type,
    String? text,
    String? mediaUrl,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, roomId, senderId, type, text, mediaUrl, createdAt];
}
