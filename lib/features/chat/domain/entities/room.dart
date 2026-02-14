import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/chat/domain/entities/room_member.dart';
import 'package:equatable/equatable.dart';

enum RoomType { dm, organization }

class Room extends Equatable {
  final String id;
  final RoomType type;
  final String? organizationId;
  final DateTime createdAt;

  final List<RoomMember>? members;
  final Organization? organization;

  const Room({
    required this.id,
    required this.type,
    this.organizationId,
    required this.createdAt,

    this.members,
    this.organization,
  });

  Room copyWith({
    String? id,
    RoomType? type,
    String? organizationId,
    DateTime? createdAt,
    List<RoomMember>? members,
    Organization? organization,
  }) {
    return Room(
      id: id ?? this.id,
      type: type ?? this.type,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      organization: organization ?? this.organization,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    organizationId,
    createdAt,
    members,
    organization,
  ];
}
