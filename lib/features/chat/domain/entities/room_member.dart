
import 'package:app/features/chat/domain/entities/chat_user.dart';
import 'package:equatable/equatable.dart';

class RoomMember extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? lastReadAt;
  final ChatUser? user;


  const RoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.joinedAt,
    this.lastReadAt,

    this.user,
  });

  RoomMember copyWith({
    String? id,
    String? roomId,
    String? userId,
    DateTime? joinedAt,
    DateTime? lastReadAt,
    ChatUser? user,
  }) {
    return RoomMember(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [id, roomId, userId, joinedAt, lastReadAt, user];
}
