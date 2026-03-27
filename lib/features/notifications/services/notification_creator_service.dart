import 'package:app/features/notifications/data/models/notification_model.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotificationCreatorService
//
// Inserts notification rows into Supabase on behalf of the client.
// Call these methods from your feature BLoCs / repositories right after
// the primary action succeeds (booking confirmed, payment received, etc.).
//
// Each method is a thin factory that builds the correct NotificationModel
// and inserts it.  The realtime stream in NotificationBloc will then pick
// it up and call NotificationService.showFromEntity() automatically.
// ─────────────────────────────────────────────────────────────────────────────

class NotificationCreatorService {
  NotificationCreatorService._();
  static final NotificationCreatorService instance =
      NotificationCreatorService._();

  final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'notifications';

  // ── Core insert ───────────────────────────────────────────────────────────

  Future<void> _insert(NotificationModel model) async {
    await _client.from(_table).insert(model.toCreateJson());
  }

  // ── Booking ───────────────────────────────────────────────────────────────

  Future<void> bookingRequested({
    required String recipientId, // host's userId
    required String senderId, // guest's userId
    required String bookingId,
    required String postTitle,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        senderId: senderId,
        type: NotificationType.bookingRequested,
        title: 'New Booking Request',
        body: 'Someone requested to book "$postTitle".',
        referenceId: bookingId,
        referenceType: 'booking',
        metadata: {'post_title': postTitle},
      ),
    );
  }

  Future<void> bookingConfirmed({
    required String recipientId, // guest's userId
    required String senderId, // host's userId
    required String bookingId,
    required String postTitle,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        senderId: senderId,
        type: NotificationType.bookingConfirmed,
        title: 'Booking Confirmed 🎉',
        body: 'Your booking for "$postTitle" has been confirmed.',
        referenceId: bookingId,
        referenceType: 'booking',
        metadata: {'post_title': postTitle},
      ),
    );
  }

  Future<void> bookingCancelled({
    required String recipientId,
    required String senderId,
    required String bookingId,
    required String postTitle,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        senderId: senderId,
        type: NotificationType.bookingCancelled,
        title: 'Booking Cancelled',
        body: 'Your booking for "$postTitle" has been cancelled.',
        referenceId: bookingId,
        referenceType: 'booking',
        metadata: {'post_title': postTitle},
      ),
    );
  }

  Future<void> bookingRejected({
    required String recipientId,
    required String senderId,
    required String bookingId,
    required String postTitle,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        senderId: senderId,
        type: NotificationType.bookingRejected,
        title: 'Booking Rejected',
        body: 'Your booking request for "$postTitle" was declined.',
        referenceId: bookingId,
        referenceType: 'booking',
        metadata: {'post_title': postTitle},
      ),
    );
  }

  // ── Payment ───────────────────────────────────────────────────────────────

  Future<void> paymentReceived({
    required String recipientId,
    required String senderId,
    required String paymentId,
    required double amount,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        senderId: senderId,
        type: NotificationType.paymentReceived,
        title: 'Payment Received',
        body: 'You received a payment of Rs. ${amount.toStringAsFixed(0)}.',
        referenceId: paymentId,
        referenceType: 'payment',
        metadata: {'amount': amount},
      ),
    );
  }

  Future<void> paymentFailed({
    required String recipientId,
    required String paymentId,
    required double amount,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        type: NotificationType.paymentFailed,
        title: 'Payment Failed',
        body:
            'Your payment of Rs. ${amount.toStringAsFixed(0)} could not be processed.',
        referenceId: paymentId,
        referenceType: 'payment',
        metadata: {'amount': amount},
      ),
    );
  }

  Future<void> paymentRefunded({
    required String recipientId,
    required String paymentId,
    required double amount,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        type: NotificationType.paymentRefunded,
        title: 'Refund Issued',
        body:
            'Rs. ${amount.toStringAsFixed(0)} has been refunded to your account.',
        referenceId: paymentId,
        referenceType: 'payment',
        metadata: {'amount': amount},
      ),
    );
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  Future<void> chatMessage({
    required String recipientId,
    required String senderId,
    required String roomId,
    required String senderName,
    required String messagePreview,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        senderId: senderId,
        type: NotificationType.chatMessage,
        title: senderName,
        body: messagePreview,
        referenceId: roomId,
        referenceType: 'chat',
        metadata: {'sender_name': senderName},
      ),
    );
  }

  // ── Review ────────────────────────────────────────────────────────────────

  Future<void> reviewReceived({
    required String recipientId,
    required String senderId,
    required String postId,
    required String postTitle,
    required int rating,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        senderId: senderId,
        type: NotificationType.reviewReceived,
        title: 'New Review Received ⭐',
        body: 'Someone left a $rating-star review on "$postTitle".',
        referenceId: postId,
        referenceType: 'post',
        metadata: {'rating': rating, 'post_title': postTitle},
      ),
    );
  }

  // ── Post ──────────────────────────────────────────────────────────────────

  Future<void> postApproved({
    required String recipientId,
    required String postId,
    required String postTitle,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        type: NotificationType.postApproved,
        title: 'Post Approved ✅',
        body: 'Your post "$postTitle" is now live.',
        referenceId: postId,
        referenceType: 'post',
        metadata: {'post_title': postTitle},
      ),
    );
  }

  Future<void> postRejected({
    required String recipientId,
    required String postId,
    required String postTitle,
    String? reason,
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        type: NotificationType.postRejected,
        title: 'Post Rejected',
        body: reason != null
            ? 'Your post "$postTitle" was rejected: $reason'
            : 'Your post "$postTitle" was rejected.',
        referenceId: postId,
        referenceType: 'post',
        metadata: {
          'post_title': postTitle,
          if (reason != null) 'reason': reason,
        },
      ),
    );
  }

  // ── System ────────────────────────────────────────────────────────────────

  Future<void> system({
    required String recipientId,
    required String title,
    required String body,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _insert(
      _build(
        recipientId: recipientId,
        type: NotificationType.system,
        title: title,
        body: body,
        metadata: metadata,
      ),
    );
  }

  // ── Builder ───────────────────────────────────────────────────────────────

  NotificationModel _build({
    required String recipientId,
    String? senderId,
    required NotificationType type,
    required String title,
    required String body,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic> metadata = const {},
  }) {
    return NotificationModel(
      id: '', // ignored – Supabase generates via gen_random_uuid()
      recipientId: recipientId,
      senderId: senderId,
      type: type,
      status: NotificationStatus.unread,
      title: title,
      body: body,
      referenceId: referenceId,
      referenceType: referenceType,
      metadata: metadata,
      createdAt: DateTime.now(), // ignored – Supabase uses DEFAULT NOW()
    );
  }
}
