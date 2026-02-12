import 'package:equatable/equatable.dart';

enum MessageType { text, image, file }

class Message extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.type,
    this.text,
    this.mediaUrl,
    required this.createdAt,
  });

  Message copyWith({
    String? id,
    String? roomId,
    String? senderId,
    MessageType? type,
    String? text,
    String? mediaUrl,
    DateTime? createdAt,
  }) {
    return Message(
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
  List<Object?> get props => [
    id,
    roomId,
    senderId,
    type,
    text,
    mediaUrl,
    createdAt,
  ];
}
