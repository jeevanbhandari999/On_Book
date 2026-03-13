import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository _repository;

  const MarkAllNotificationsAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.markAllAsRead();
  }
}
