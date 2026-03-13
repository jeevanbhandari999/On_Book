import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class StreamNotificationsUseCase {
  final NotificationRepository _repository;

  const StreamNotificationsUseCase(this._repository);

  Stream<Either<Failure, List<NotificationEntity>>> call(String userId) {
    return _repository.streamNotifications(userId);
  }
}
