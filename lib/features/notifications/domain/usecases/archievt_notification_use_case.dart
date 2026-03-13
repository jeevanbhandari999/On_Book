import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class ArchiveNotificationUseCase {
  final NotificationRepository _repository;

  const ArchiveNotificationUseCase(this._repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return _repository.archiveNotification(notificationId: notificationId);
  }
}
