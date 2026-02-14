import 'package:app/features/chat/domain/entities/chat_organization.dart';
import 'package:app/features/chat/domain/entities/message.dart';
import 'package:app/features/chat/domain/entities/room_member.dart';
import 'package:equatable/equatable.dart';

enum RoomType { dm, organization }

class Room extends Equatable {
  final String id;
  final RoomType type;
  final String? organizationId;
  final DateTime createdAt;

  final List<RoomMember>? members;
  final ChatOrganization? organization;

  final Message? lastMessage;

  const Room({
    required this.id,
    required this.type,
    this.organizationId,
    required this.createdAt,

    this.members,
    this.organization,

    this.lastMessage,
  });

  Room copyWith({
    String? id,
    RoomType? type,
    String? organizationId,
    DateTime? createdAt,
    List<RoomMember>? members,
    ChatOrganization? organization,
    Message? lastMessage,
  }) {
    return Room(
      id: id ?? this.id,
      type: type ?? this.type,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      organization: organization ?? this.organization,
      lastMessage: lastMessage ?? this.lastMessage,
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
    lastMessage,
  ];

  String getLastMessagePreview(String currentUserId) {
    if (lastMessage == null) return 'No messages yet';

    final prefix = lastMessage!.senderId == currentUserId ? 'You: ' : '';
    return '$prefix${lastMessage!.text ?? (lastMessage!.mediaUrl != null ? '📷 Media' : '')}';
  }

  String getDisplayName(String currentUserId) {
    if (type == RoomType.organization) {
      return organization?.name ?? 'Organization';
    }

    if (members == null) return 'Unknown';

    final otherUser = members!.firstWhere(
      (m) => m.userId != currentUserId,
      orElse: () => members!.first,
    );

    return otherUser.user?.fullName ?? 'Unknown';
  }

  String? getDisplayImage(String currentUserId) {
    if (type == RoomType.organization) {
      return organization?.logoUrl;
    }

    if (members == null) return null;

    final otherUser = members!.firstWhere(
      (m) => m.userId != currentUserId,
      orElse: () => members!.first,
    );

    return otherUser.user?.imageUrl;
  }
}
