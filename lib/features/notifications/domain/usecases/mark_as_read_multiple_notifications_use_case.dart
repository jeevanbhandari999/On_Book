import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class MarkAsReadMultipleNotificationsUseCase {
  final NotificationRepository _repository;

  const MarkAsReadMultipleNotificationsUseCase(this._repository);

  Future<Either<Failure, void>> call(List<String> notificationIds) {
    return _repository.markAsReadMultipleNotification(
      notificationIds: notificationIds,
    );
  }
}
