import 'dart:async';

import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/domain/usecases/archievt_notification_use_case.dart';
import 'package:app/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_all_notifiations_as_read_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_all_notification_as_viewed_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:app/features/notifications/domain/usecases/stream_notifications_use_case.dart';
import 'package:app/features/notifications/presentation/services/notification_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────────────────────────────

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationStarted extends NotificationEvent {
  final String userId;
  const NotificationStarted({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final class NotificationRefreshRequested extends NotificationEvent {
  const NotificationRefreshRequested();
}

// Internal – emitted by the realtime stream listener only.
final class _NotificationStreamUpdated extends NotificationEvent {
  final List<NotificationEntity> notifications;
  const _NotificationStreamUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

final class NotificationTapped extends NotificationEvent {
  final NotificationEntity notification;
  const NotificationTapped({required this.notification});

  @override
  List<Object?> get props => [notification];
}

final class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;
  const NotificationMarkAsReadRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

final class NotificationMarkAllAsReadRequested extends NotificationEvent {
  const NotificationMarkAllAsReadRequested();
}

final class NotificationMarkAllAsViewedRequested extends NotificationEvent {
  const NotificationMarkAllAsViewedRequested();
}

final class NotificationArchiveRequested extends NotificationEvent {
  final String notificationId;
  const NotificationArchiveRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

final class NotificationTypeFilterChanged extends NotificationEvent {
  final String filter;
  const NotificationTypeFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

final class NotificationReadFilterChanged extends NotificationEvent {
  final NotificationReadFilter filter;
  const NotificationReadFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

// ─────────────────────────────────────────────────────────────────────────────
// READ FILTER ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum NotificationReadFilter { all, unread, read, archived }

// ─────────────────────────────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────────────────────────────

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> allNotifications;
  final String typeFilter;
  final NotificationReadFilter readFilter;
  final NotificationEntity? pendingNavigation;

  const NotificationLoaded({
    required this.allNotifications,
    this.typeFilter = 'All',
    this.readFilter = NotificationReadFilter.all,
    this.pendingNavigation,
  });

  // ── Derived ───────────────────────────────────────────────────────────────

  int get unreadCount => allNotifications.where((n) => n.isUnread).length;
  int get viewedCount => allNotifications.where((n) => n.isViewed).length;

  List<NotificationEntity> get filtered {
    final byType = switch (typeFilter) {
      'Messages' =>
        allNotifications
            .where((n) => n.type == NotificationType.chatMessage)
            .toList(),
      'Booking' =>
        allNotifications
            .where(
              (n) =>
                  n.type == NotificationType.bookingRequested ||
                  n.type == NotificationType.bookingConfirmed ||
                  n.type == NotificationType.bookingCancelled ||
                  n.type == NotificationType.bookingRejected,
            )
            .toList(),
      'Payment' =>
        allNotifications
            .where(
              (n) =>
                  n.type == NotificationType.paymentReceived ||
                  n.type == NotificationType.paymentFailed ||
                  n.type == NotificationType.paymentRefunded,
            )
            .toList(),
      'System' =>
        allNotifications
            .where((n) => n.type == NotificationType.system)
            .toList(),
      _ => allNotifications,
    };

    return switch (readFilter) {
      NotificationReadFilter.unread => byType.where((n) => n.isViewed).toList(),
      NotificationReadFilter.read => byType.where((n) => n.isRead).toList(),
      NotificationReadFilter.archived =>
        byType.where((n) => n.isArchived).toList(),
      NotificationReadFilter.all => byType.where((n) => !n.isArchived).toList(),
    };
  }

  Map<String, List<NotificationEntity>> get grouped {
    final now = DateTime.now();
    final Map<String, List<NotificationEntity>> groups = {};

    for (final n in filtered) {
      final diff = now.difference(n.createdAt).inDays;
      final label = switch (diff) {
        0 => 'Today',
        1 => 'Yesterday',
        _ when diff < 7 => 'This Week',
        _ => 'Earlier',
      };
      groups.putIfAbsent(label, () => []).add(n);
    }

    const order = ['Today', 'Yesterday', 'This Week', 'Earlier'];
    return Map.fromEntries(
      order.where(groups.containsKey).map((k) => MapEntry(k, groups[k]!)),
    );
  }

  NotificationLoaded copyWith({
    List<NotificationEntity>? allNotifications,
    String? typeFilter,
    NotificationReadFilter? readFilter,
    NotificationEntity? pendingNavigation,
    bool clearPendingNavigation = false,
  }) {
    return NotificationLoaded(
      allNotifications: allNotifications ?? this.allNotifications,
      typeFilter: typeFilter ?? this.typeFilter,
      readFilter: readFilter ?? this.readFilter,
      pendingNavigation: clearPendingNavigation
          ? null
          : pendingNavigation ?? this.pendingNavigation,
    );
  }

  @override
  List<Object?> get props => [
    allNotifications,
    typeFilter,
    readFilter,
    pendingNavigation,
  ];
}

final class NotificationError extends NotificationState {
  final String message;
  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final StreamNotificationsUseCase _streamNotifications;
  final MarkNotificationAsReadUseCase _markAsRead;
  final MarkAllNotificationsAsReadUseCase _markAllAsRead;
  final ArchiveNotificationUseCase _archive;
  final MarkAllNotificationsAsViewedUseCase _markAllAsViewed;
  final NotificationService _notificationService;

  String? _currentUserId;
  StreamSubscription<dynamic>? _streamSubscription;

  // IDs already seeded on first load – prevents banner-spamming
  // notifications that existed before the session started.
  final Set<String> _shownIds = {};

  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required StreamNotificationsUseCase streamNotifications,
    required MarkNotificationAsReadUseCase markAsRead,
    required MarkAllNotificationsAsReadUseCase markAllAsRead,
    required ArchiveNotificationUseCase archive,
    required MarkAllNotificationsAsViewedUseCase markAllAsViewed,
    NotificationService? notificationService,
  }) : _getNotifications = getNotifications,
       _streamNotifications = streamNotifications,
       _markAsRead = markAsRead,
       _markAllAsRead = markAllAsRead,
       _archive = archive,
       _markAllAsViewed = markAllAsViewed,
       _notificationService =
           notificationService ?? NotificationService.instance,
       super(const NotificationInitial()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationRefreshRequested>(_onRefreshRequested);
    on<_NotificationStreamUpdated>(_onStreamUpdated);
    on<NotificationTapped>(_onTapped);
    on<NotificationMarkAsReadRequested>(_onMarkAsRead);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsRead);
    on<NotificationArchiveRequested>(_onArchive);
    on<NotificationTypeFilterChanged>(_onTypeFilterChanged);
    on<NotificationReadFilterChanged>(_onReadFilterChanged);
    on<NotificationMarkAllAsViewedRequested>(_onMarkAllAsViewed);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(const NotificationLoading());

    final result = await _getNotifications(
      GetNotificationsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        // Seed shown IDs with the initial fetch so we never banner
        // notifications that already existed before this session.
        _shownIds.addAll(notifications.map((n) => n.id));
        emit(NotificationLoaded(allNotifications: notifications));
        _subscribeToStream(event.userId);
      },
    );
  }

  Future<void> _onRefreshRequested(
    NotificationRefreshRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (_currentUserId == null) return;

    final result = await _getNotifications(
      GetNotificationsParams(userId: _currentUserId!),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) {
        _shownIds.addAll(notifications.map((n) => n.id));
        if (state case NotificationLoaded loaded) {
          emit(loaded.copyWith(allNotifications: notifications));
        } else {
          emit(NotificationLoaded(allNotifications: notifications));
        }
        _subscribeToStream(_currentUserId!);
      },
    );
  }

  Future<void> _onStreamUpdated(
    _NotificationStreamUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    if (state case NotificationLoaded loaded) {
      print('object: $event');
      // Only show banners for IDs we have never seen before.
      final brandNew = event.notifications
          .where((n) => n.isUnread && !_shownIds.contains(n.id))
          .toList();

      for (final n in brandNew) {
        _shownIds.add(n.id);
        // Fire-and-forget – banner display doesn't block state emission.
        _notificationService.showFromEntity(n);
      }

      emit(loaded.copyWith(allNotifications: event.notifications));
    }
  }

  Future<void> _onTapped(
    NotificationTapped event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.notification.isViewed) {
      _applyLocalRead(event.notification.id, emit);
      _markAsRead(event.notification.id);
    }

    if (state case NotificationLoaded loaded) {
      emit(loaded.copyWith(pendingNavigation: event.notification));
      emit(loaded.copyWith(clearPendingNavigation: true));
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    _applyLocalRead(event.notificationId, emit);
    await _markAsRead(event.notificationId);
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state case NotificationLoaded loaded) {
      final updated = loaded.allNotifications.map((n) {
        return n.isUnread ? n.copyWith(status: NotificationStatus.read) : n;
      }).toList();
      emit(loaded.copyWith(allNotifications: updated));
    }
    await _markAllAsRead();
  }

  Future<void> _onMarkAllAsViewed(
    NotificationMarkAllAsViewedRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state case NotificationLoaded loaded) {
      final updated = loaded.allNotifications.map((n) {
        return n.isUnread ? n.copyWith(status: NotificationStatus.viewed) : n;
      }).toList();
      emit(loaded.copyWith(allNotifications: updated));
    }
    await _markAllAsViewed();
  }

  Future<void> _onArchive(
    NotificationArchiveRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state case NotificationLoaded loaded) {
      final updated = loaded.allNotifications
          .where((n) => n.id != event.notificationId)
          .toList();
      emit(loaded.copyWith(allNotifications: updated));
    }
    await _archive(event.notificationId);
  }

  Future<void> _onTypeFilterChanged(
    NotificationTypeFilterChanged event,
    Emitter<NotificationState> emit,
  ) async {
    if (state case NotificationLoaded loaded) {
      emit(loaded.copyWith(typeFilter: event.filter));
    }
  }

  Future<void> _onReadFilterChanged(
    NotificationReadFilterChanged event,
    Emitter<NotificationState> emit,
  ) async {
    if (state case NotificationLoaded loaded) {
      emit(loaded.copyWith(readFilter: event.filter));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _applyLocalRead(String notificationId, Emitter<NotificationState> emit) {
    if (state case NotificationLoaded loaded) {
      final updated = loaded.allNotifications.map((n) {
        return n.id == notificationId && (n.isViewed)
            ? n.copyWith(status: NotificationStatus.read)
            : n;
      }).toList();
      emit(loaded.copyWith(allNotifications: updated));
    }
  }

  void _subscribeToStream(String userId) {
    _streamSubscription?.cancel();
    _streamSubscription = _streamNotifications(userId).listen((result) {
      result.fold(
        (_) {},
        (notifications) => add(_NotificationStreamUpdated(notifications)),
      );
    });
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
