import 'package:equatable/equatable.dart';

class RoomMember extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? lastReadAt;

  const RoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.joinedAt,
    this.lastReadAt,
  });

  RoomMember copyWith({
    String? id,
    String? roomId,
    String? userId,
    DateTime? joinedAt,
    DateTime? lastReadAt,
  }) {
    return RoomMember(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }

  @override
  List<Object?> get props => [id, roomId, userId, joinedAt, lastReadAt];
}
