import 'dart:async';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/presentation/services/notification_service.dart';
import 'package:app/features/notifications/domain/usecases/stream_notifications_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ── States ─────────────────────────────────────────────────────
abstract class NotificationCubitState extends Equatable {
  const NotificationCubitState();
  @override
  List<Object?> get props => [];
}

class NotificationCubitInitial extends NotificationCubitState {}

class NotificationCubitLoading extends NotificationCubitState {}

class NotificationCubitLoaded extends NotificationCubitState {
  final List<NotificationEntity> notifications;
  const NotificationCubitLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationCubitError extends NotificationCubitState {
  final String message;
  const NotificationCubitError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────
class NotificationCubit extends Cubit<NotificationCubitState> {
  final NotificationService _notificationService;
  final StreamNotificationsUseCase _streamNotifications;

  StreamSubscription? _subscription;
  final Set<String> _shownIds = {};

  NotificationCubit({
    required NotificationService notificationService,
    required StreamNotificationsUseCase streamNotifications,
  }) : _notificationService = notificationService,
       _streamNotifications = streamNotifications,
       super(NotificationCubitInitial());

  /// Call this once the user is authenticated.
  bool _isFirstEmission = true;

  void start(String userId) {
    _subscription?.cancel();
    _shownIds.clear();
    _isFirstEmission = true; // ✅ reset on every start
    emit(NotificationCubitLoading());

    _subscription = _streamNotifications(userId).listen((result) {
      result.fold(
        (failure) => emit(NotificationCubitError(message: failure.message)),
        (notifications) {
          if (_isFirstEmission) {
            // Seed read + archived — these never get a banner
            final alreadyRead = notifications
                .where((n) => n.isRead || n.isArchived)
                .map((n) => n.id)
                .toSet();
            _shownIds.addAll(alreadyRead);
            _isFirstEmission = false; // ✅ never runs this block again
          }

          // Banner only for unread notifications we haven't seen yet
          final brandNew = notifications
              .where((n) => n.isUnread && !_shownIds.contains(n.id))
              .toList();

          for (final n in brandNew) {
            _shownIds.add(n.id);
            _notificationService.showFromEntity(n);
          }

          emit(NotificationCubitLoaded(notifications: notifications));
        },
      );
    });
  }

  /// Call this when the user logs out.
  void stop() {
    _subscription?.cancel();
    _shownIds.clear();
    _isFirstEmission = true;
    emit(NotificationCubitInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
