import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotificationService
//
// Responsibilities:
//   1. Initialise flutter_local_notifications once at app startup.
//   2. Show a heads-up (in-app) banner whenever a new NotificationEntity
//      arrives from the Supabase realtime stream.
//   3. Provide channel constants so the rest of the app can reference them.
//
// This service does NOT insert rows into Supabase – that is done by
// NotificationCreatorService (see below).  It only presents local UI banners.
// ─────────────────────────────────────────────────────────────────────────────

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialised = false;

  // ── Channel IDs ───────────────────────────────────────────────────────────
  static const _channelIdGeneral = 'general_channel';
  static const _channelIdChat = 'chat_channel';
  static const _channelIdBooking = 'booking_channel';
  static const _channelIdPayment = 'payment_channel';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialised) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    await _createChannels();

    _initialised = true;
  }

  Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelIdGeneral,
        'General',
        description: 'General app notifications',
        importance: Importance.high,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelIdChat,
        'Messages',
        description: 'New chat messages',
        importance: Importance.high,
        playSound: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelIdBooking,
        'Bookings',
        description: 'Booking updates',
        importance: Importance.high,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelIdPayment,
        'Payments',
        description: 'Payment updates',
        importance: Importance.high,
      ),
    );
  }

  // ── Show banner ───────────────────────────────────────────────────────────

  /// Call this whenever a new [NotificationEntity] is received from the
  /// realtime stream.  It shows a heads-up banner appropriate to the type.
  Future<void> showFromEntity(NotificationEntity notification) async {
    if (!_initialised) await init();

    final channelId = _channelIdForType(notification.type);
    final color = _colorForType(notification.type);
    final icon = _iconForType(notification.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channelNameForId(channelId),
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      icon: icon,
      // Heads-up banner behaviour
      fullScreenIntent: false,
      styleInformation: BigTextStyleInformation(notification.body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      // Use a stable int ID derived from the UUID so duplicates are replaced
      id: notification.id.hashCode.abs() % 100000,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      // Pass referenceId + referenceType as payload for tap navigation
      payload:
          '${notification.referenceType ?? ''}|${notification.referenceId ?? ''}',
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<void> cancel(String notificationId) async {
    await _plugin.cancel(id: notificationId.hashCode.abs() % 100000);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Tap handler ───────────────────────────────────────────────────────────

  void _onNotificationTapped(NotificationResponse response) {
    // Payload format: 'referenceType|referenceId'
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    final referenceType = parts.isNotEmpty ? parts[0] : null;
    final referenceId = parts.length > 1 ? parts[1] : null;

    if (referenceType == null || referenceId == null) return;
    if (referenceType.isEmpty || referenceId.isEmpty) return;

    // Delegate to the tap callback if set by the app shell
    onNotificationTapped?.call(referenceType, referenceId);
  }

  /// Set this from your app's root widget / router so taps can trigger
  /// navigation even when the notification arrives while the app is backgrounded.
  ///
  /// Example in main.dart:
  ///   NotificationService.instance.onNotificationTapped = (type, id) {
  ///     router.push(...);
  ///   };
  void Function(String referenceType, String referenceId)? onNotificationTapped;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _channelIdForType(NotificationType type) {
    return switch (type) {
      NotificationType.chatMessage => _channelIdChat,
      NotificationType.bookingRequested ||
      NotificationType.bookingConfirmed ||
      NotificationType.bookingCancelled ||
      NotificationType.bookingRejected => _channelIdBooking,
      NotificationType.paymentReceived ||
      NotificationType.paymentFailed ||
      NotificationType.paymentRefunded => _channelIdPayment,
      _ => _channelIdGeneral,
    };
  }

  String _channelNameForId(String id) {
    return switch (id) {
      _channelIdChat => 'Messages',
      _channelIdBooking => 'Bookings',
      _channelIdPayment => 'Payments',
      _ => 'General',
    };
  }

  Color _colorForType(NotificationType type) {
    return switch (type) {
      NotificationType.chatMessage => const Color(0xFF4A90E2),
      NotificationType.bookingRequested ||
      NotificationType.bookingConfirmed ||
      NotificationType.bookingCancelled ||
      NotificationType.bookingRejected => const Color(0xFF7B61FF),
      NotificationType.paymentReceived ||
      NotificationType.paymentFailed ||
      NotificationType.paymentRefunded => const Color(0xFF27AE60),
      NotificationType.reviewReceived => const Color(0xFFF39C12),
      NotificationType.postApproved ||
      NotificationType.postRejected => const Color(0xFFE67E22),
      NotificationType.system => const Color(0xFF546E7A),
    };
  }

  // Android drawable name – keep @drawable/ic_notif_* assets in your project
  // or fall back to the default app icon.
  String? _iconForType(NotificationType type) =>
      null; // use default launcher icon
}
