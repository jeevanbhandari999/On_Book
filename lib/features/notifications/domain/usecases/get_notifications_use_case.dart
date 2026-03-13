import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class GetNotificationsParams {
  final String userId;
  final int limit;
  final int offset;

  const GetNotificationsParams({
    required this.userId,
    this.limit = 30,
    this.offset = 0,
  });
}

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(
      userId: params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
