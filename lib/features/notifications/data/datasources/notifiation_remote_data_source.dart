import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/notifications/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contract
// ─────────────────────────────────────────────────────────────────────────────

abstract class NotificationRemoteDataSource {
  /// Fetch paginated notifications for [userId].
  /// Excludes archived rows by default.
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  });

  /// Real-time stream of notifications for [userId].
  /// Emits the full updated list on every INSERT / UPDATE.
  Stream<List<NotificationModel>> streamNotifications(String userId);

  /// Returns the current unread notification count for [userId].
  Future<int> getUnreadCount({required String userId});

  /// Mark a single notification as read (calls DB RPC for atomicity).
  Future<void> markAsRead({required String notificationId});

  /// Mark every unread notification for the signed-in user as read.
  Future<void> markAllAsRead();

  /// Mark every new notification as viewed when the user opens the notifications screen.
  Future<void> markAllAsViewed();

  /// Soft-archive a notification — hidden from the default list, kept in DB.
  Future<void> archiveNotification({required String notificationId});
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient client;

  NotificationRemoteDataSourceImpl(this.client);

  static const _table = 'notifications';

  // ── Fetch ─────────────────────────────────────────────────────────────────

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final res = await client
          .from(_table)
          .select()
          .eq('recipient_id', userId)
          .neq('status', 'archived')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (res as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch notifications: ${e.toString()}');
    }
  }

  // ── Realtime stream ───────────────────────────────────────────────────────

  @override
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('recipient_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((e) => NotificationModel.fromJson(e)).toList());
  }

  // ── Unread count ──────────────────────────────────────────────────────────

  @override
  Future<int> getUnreadCount({required String userId}) async {
    try {
      final res = await client
          .from(_table)
          .select('id')
          .eq('recipient_id', userId)
          .eq('status', 'unread');

      return (res as List).length;
    } catch (e) {
      throw ServerException('Failed to fetch unread count: ${e.toString()}');
    }
  }

  // ── Mark single as read ───────────────────────────────────────────────────

  @override
  Future<void> markAsRead({required String notificationId}) async {
    try {
      await client.rpc(
        'mark_notification_read',
        params: {'p_notification_id': notificationId},
      );
    } catch (e) {
      throw ServerException(
        'Failed to mark notification as read: ${e.toString()}',
      );
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────

  @override
  Future<void> markAllAsRead() async {
    try {
      await client.rpc('mark_all_notifications_read');
    } catch (e) {
      throw ServerException(
        'Failed to mark all notifications as read: ${e.toString()}',
      );
    }
  }

  // ── Archive ───────────────────────────────────────────────────────────────

  @override
  Future<void> archiveNotification({required String notificationId}) async {
    try {
      final userId = client.auth.currentUser!.id;

      await client
          .from(_table)
          .update({
            'status': 'archived',
            'archived_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .eq('recipient_id', userId);
    } catch (e) {
      throw ServerException('Failed to archive notification: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllAsViewed() async {
    try {
      await client.rpc('mark_all_notifications_viewed');
    } catch (e) {
      throw ServerException(
        'Failed to mark all notifications as viewed: ${e.toString()}',
      );
    }
  }
}
