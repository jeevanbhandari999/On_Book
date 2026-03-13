import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class GetUnreadCountUseCase {
  final NotificationRepository _repository;

  const GetUnreadCountUseCase(this._repository);

  Future<Either<Failure, int>> call(String userId) {
    return _repository.getUnreadCount(userId: userId);
  }
}
