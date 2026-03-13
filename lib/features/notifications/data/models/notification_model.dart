import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String recipientId;
  final String? senderId;
  final NotificationType type;
  final NotificationStatus status;
  final String title;
  final String body;
  final String? referenceId;
  final String? referenceType;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? archivedAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.type,
    required this.status,
    required this.title,
    required this.body,
    this.referenceId,
    this.referenceType,
    this.metadata = const {},
    required this.createdAt,
    this.readAt,
    this.archivedAt,
  });

  // JSON serialization/deserialization
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      senderId: json['sender_id'] as String?,
      type: NotificationType.values.firstWhere(
        (e) => e.name == _snakeToCamel(json['type'] as String),
        orElse: () => NotificationType.system,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => NotificationStatus.unread,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
    );
  }

  // Converts the model back to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'type': _camelToSnake(type.name),
      'status': status.name,
      'title': title,
      'body': body,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
    };
  }

  // Used when inserting a new notification (omits server-generated fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'recipient_id': recipientId,
      'sender_id': senderId,
      'type': _camelToSnake(type.name),
      'title': title,
      'body': body,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'metadata': metadata,
    };
  }

  // Used when patching status / timestamps only
  Map<String, dynamic> toUpdateJson() {
    return {
      'status': status.name,
      'read_at': readAt?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
    };
  }

  // Factory method to convert from entity to model and vice versa
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      recipientId: entity.recipientId,
      senderId: entity.senderId,
      type: entity.type,
      status: entity.status,
      title: entity.title,
      body: entity.body,
      referenceId: entity.referenceId,
      referenceType: entity.referenceType,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
      archivedAt: entity.archivedAt,
    );
  }

  // Converts the model back to an entity for use in the domain layer
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      type: type,
      status: status,
      title: title,
      body: body,
      referenceId: referenceId,
      referenceType: referenceType,
      metadata: metadata,
      createdAt: createdAt,
      readAt: readAt,
      archivedAt: archivedAt,
    );
  }

  // CopyWith method for immutability and easy updates
  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    NotificationType? type,
    NotificationStatus? status,
    String? title,
    String? body,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? archivedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipientId,
    senderId,
    type,
    status,
    title,
    body,
    referenceId,
    referenceType,
    metadata,
    createdAt,
    readAt,
    archivedAt,
  ];
}

// Helpers to convert between snake_case (API) and camelCase (Dart) for enum values
String _snakeToCamel(String value) {
  final parts = value.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

String _camelToSnake(String value) {
  return value.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (m) => '_${m.group(0)!.toLowerCase()}',
  );
}
