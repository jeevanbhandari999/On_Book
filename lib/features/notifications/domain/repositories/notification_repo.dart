import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:dartz/dartz.dart';

abstract class NotificationRepository {
  /// Fetch paginated notifications for [userId].
  /// Excludes archived notifications by default.
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  });

  /// Real-time stream of notifications for [userId].
  /// Emits the full updated list on every change.
  Stream<Either<Failure, List<NotificationEntity>>> streamNotifications(
    String userId,
  );

  /// Returns the current unread notification count for [userId].
  Future<Either<Failure, int>> getUnreadCount({required String userId});

  /// Mark a single notification as read.
  Future<Either<Failure, void>> markAsRead({required String notificationId});

  /// Mark a multiple notification as read(calls DB RPC for automatically)
  Future<Either<Failure, void>> markAsReadMultipleNotification({
    required List<String> notificationIds,
  });

  /// Mark all unread notifications for the signed-in user as read.
  Future<Either<Failure, void>> markAllAsRead();

  /// Mark all new notifications as viewed when the user opens the notifications screen.
  Future<Either<Failure, void>> markAllAsViewed();

  /// Soft-archive a notification (hidden from default list, kept in DB).
  Future<Either<Failure, void>> archiveNotification({
    required String notificationId,
  });
}
