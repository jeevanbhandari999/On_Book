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
