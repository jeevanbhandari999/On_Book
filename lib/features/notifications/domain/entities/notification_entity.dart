import 'package:equatable/equatable.dart';

// Notification types for different events in the app
enum NotificationType {
  bookingRequested,
  bookingConfirmed,
  bookingCancelled,
  bookingRejected,
  paymentReceived,
  paymentFailed,
  paymentRefunded,
  chatMessage,
  reviewReceived,
  postApproved,
  postRejected,
  system,
}

// Notification status to track read/unread/archived state
enum NotificationStatus { unread, read, archived, viewed }

// The main notification entity used across the app
class NotificationEntity extends Equatable {
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

  const NotificationEntity({
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
  // Helper getters for common status checks
  bool get isUnread => status == NotificationStatus.unread;
  bool get isRead => status == NotificationStatus.read;
  bool get isArchived => status == NotificationStatus.archived;
  bool get isViewed => status == NotificationStatus.viewed;

  // Method to create a copy of the notification with updated fields
  NotificationEntity copyWith({
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
    return NotificationEntity(
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
