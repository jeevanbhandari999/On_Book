import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return _repository.markAsRead(notificationId: notificationId);
  }
}
