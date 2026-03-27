import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization with full presentation options
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
      // optional: add background handler if needed
      // onDidReceiveBackgroundNotificationResponse: _onBackgroundTapped,
    );

    // Request Android 13+ notification permission
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    // Request iOS permission explicitly
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    // Create Android notification channels
    await _createChannels();

    _initialised = true;
    debugPrint('✅ NotificationService initialized');
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
  Future<void> showFromEntity(NotificationEntity notification) async {
    if (!_initialised) await init();

    final channelId = _channelIdForType(notification.type);
    final color = _colorForType(notification.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channelNameForId(channelId),
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: false,
      styleInformation: BigTextStyleInformation(notification.body),
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true, // MUST for iOS 14+
      presentList: true, // MUST for iOS 16+
      sound: 'default',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload:
          '${notification.referenceType ?? ''}|${notification.referenceId ?? ''}',
    );

    debugPrint('🔔 Notification shown: ${notification.title}');
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
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    final referenceType = parts.isNotEmpty ? parts[0] : null;
    final referenceId = parts.length > 1 ? parts[1] : null;

    if (referenceType == null || referenceId == null) return;
    if (referenceType.isEmpty || referenceId.isEmpty) return;

    onNotificationTapped?.call(referenceType, referenceId);
  }

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

  String? _iconForType(NotificationType type) => null;
}
