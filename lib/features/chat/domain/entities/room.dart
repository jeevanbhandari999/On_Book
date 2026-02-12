import 'package:equatable/equatable.dart';

enum RoomType { dm, organization }

class Room extends Equatable {
  final String id;
  final RoomType type;
  final String? organizationId;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.type,
    this.organizationId,
    required this.createdAt,
  });

  Room copyWith({
    String? id,
    RoomType? type,
    String? organizationId,
    DateTime? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      type: type ?? this.type,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, organizationId, createdAt];
}
