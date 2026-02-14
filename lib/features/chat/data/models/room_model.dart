import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/chat/domain/entities/room_member.dart';

import '../../domain/entities/room.dart';
import 'package:equatable/equatable.dart';

class RoomModel extends Equatable {
  final String id;
  final RoomType type;
  final String? organizationId;
  final DateTime createdAt;

  const RoomModel({
    required this.id,
    required this.type,
    this.organizationId,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      type: RoomType.values.firstWhere((e) => e.name == json['type']),
      organizationId: json['organization_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'organization_id': organizationId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {'type': type.name, 'organization_id': organizationId};
  }

  Map<String, dynamic> toUpdateJson() => {};

  factory RoomModel.fromEntity(Room entity) {
    return RoomModel(
      id: entity.id,
      type: entity.type,
      organizationId: entity.organizationId,
      createdAt: entity.createdAt,
    );
  }

  Room toEntity() => Room(
    id: id,
    type: type,
    organizationId: organizationId,
    createdAt: createdAt,
  );

  // Room toEntity() {
  //   final membersJson = json['room_members'] as List?;
  //   final orgJson = json['organizations'];

  //   return Room(
  //     id: id,
  //     type: type,
  //     organizationId: organizationId,
  //     createdAt: createdAt,
  //     members: membersJson?.map((m) {
  //       final userJson = m['users'];
  //       return RoomMember(
  //         id: m['id'] ?? '',
  //         roomId: id,
  //         userId: m['user_id'],
  //         joinedAt: DateTime.now(), // adjust if available
  //         user: userJson != null
  //             ? ChatUser(
  //                 id: userJson['id'],
  //                 userId: userJson['user_id'],
  //                 fullName: userJson['full_name'],
  //                 imageUrl: userJson['image_url'],
  //               )
  //             : null,
  //       );
  //     }).toList(),
  //     organization: orgJson != null
  //         ? ChatOrganization(
  //             id: orgJson['id'],
  //             name: orgJson['name'],
  //             logoUrl: orgJson['logo_url'],
  //           )
  //         : null,
  //   );
  // }

  RoomModel copyWith({
    String? id,
    RoomType? type,
    String? organizationId,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      type: type ?? this.type,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, organizationId, createdAt];
}

class ChatUser extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String? imageUrl;

  const ChatUser({
    required this.id,
    required this.userId,
    required this.fullName,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, fullName, userId, imageUrl];
}

class ChatOrganization extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;

  const ChatOrganization({required this.id, required this.name, this.logoUrl});

  @override
  List<Object?> get props => [id, name, logoUrl];
}
