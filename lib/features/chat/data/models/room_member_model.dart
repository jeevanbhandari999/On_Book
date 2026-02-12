import 'package:app/features/chat/domain/entities/room_member.dart';
import 'package:equatable/equatable.dart';

class RoomMemberModel extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? lastReadAt;

  const RoomMemberModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.joinedAt,
    this.lastReadAt,
  });

  factory RoomMemberModel.fromJson(Map<String, dynamic> json) {
    return RoomMemberModel(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      joinedAt: DateTime.parse(json['joined_at']),
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {'room_id': roomId, 'user_id': userId};
  }

  Map<String, dynamic> toUpdateJson() {
    return {'last_read_at': lastReadAt?.toIso8601String()};
  }

  factory RoomMemberModel.fromEntity(RoomMember entity) {
    return RoomMemberModel(
      id: entity.id,
      roomId: entity.roomId,
      userId: entity.userId,
      joinedAt: entity.joinedAt,
      lastReadAt: entity.lastReadAt,
    );
  }

  RoomMember toEntity() => RoomMember(
    id: id,
    roomId: roomId,
    userId: userId,
    joinedAt: joinedAt,
    lastReadAt: lastReadAt,
  );

  RoomMemberModel copyWith({
    String? id,
    String? roomId,
    String? userId,
    DateTime? joinedAt,
    DateTime? lastReadAt,
  }) {
    return RoomMemberModel(
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
