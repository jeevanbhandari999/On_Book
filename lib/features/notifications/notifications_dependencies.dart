import 'package:app/features/notifications/data/datasources/notifiation_remote_data_source.dart';
import 'package:app/features/notifications/data/repositories/notification_repo_impl.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:app/features/notifications/domain/usecases/archievt_notification_use_case.dart';
import 'package:app/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:app/features/notifications/domain/usecases/get_unread_count_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_all_notifiations_as_read_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_all_notification_as_viewed_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_as_read_multiple_notifications_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:app/features/notifications/domain/usecases/stream_notifications_use_case.dart';
import 'package:app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:app/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:app/features/notifications/presentation/services/notification_service.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationDependencies {
  static Future<void> register(GetIt getIt) async {
    // ── Data sources ──────────────────────────────────────────────────────────
    getIt.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(Supabase.instance.client),
    );

    // ── Repository ────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: getIt<NotificationRemoteDataSource>(),
      ),
    );

    // ── Use cases ─────────────────────────────────────────────────────────────
    getIt.registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<StreamNotificationsUseCase>(
      () => StreamNotificationsUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<MarkNotificationAsReadUseCase>(
      () => MarkNotificationAsReadUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<MarkAllNotificationsAsReadUseCase>(
      () => MarkAllNotificationsAsReadUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<MarkAllNotificationsAsViewedUseCase>(
      () =>
          MarkAllNotificationsAsViewedUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<ArchiveNotificationUseCase>(
      () => ArchiveNotificationUseCase(getIt<NotificationRepository>()),
    );
    getIt.registerLazySingleton<MarkAsReadMultipleNotificationsUseCase>(
      () => MarkAsReadMultipleNotificationsUseCase(
        getIt<NotificationRepository>(),
      ),
    );

    // ── BLoC ──────────────────────────────────────────────────────────────────
    getIt.registerFactory<NotificationBloc>(
      () => NotificationBloc(
        getNotifications: GetNotificationsUseCase(
          getIt<NotificationRepository>(),
        ),
        streamNotifications: StreamNotificationsUseCase(
          getIt<NotificationRepository>(),
        ),
        markAsRead: MarkNotificationAsReadUseCase(
          getIt<NotificationRepository>(),
        ),
        markAllAsRead: MarkAllNotificationsAsReadUseCase(
          getIt<NotificationRepository>(),
        ),
        markAllAsViewed: MarkAllNotificationsAsViewedUseCase(
          getIt<NotificationRepository>(),
        ),
        archive: ArchiveNotificationUseCase(getIt<NotificationRepository>()),
      ),
    );

    getIt.registerFactory<NotificationCubit>(
      () => NotificationCubit(
        notificationService: NotificationService.instance,
        streamNotifications: getIt<StreamNotificationsUseCase>(),
      ),
    );
  }
}
