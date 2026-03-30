import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class MarkAllNotificationsAsViewedUseCase {
  final NotificationRepository _repository;

  const MarkAllNotificationsAsViewedUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.markAllAsViewed();
  }
}
