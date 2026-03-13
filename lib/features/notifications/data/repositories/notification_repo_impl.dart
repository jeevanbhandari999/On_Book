import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/notifications/data/datasources/notifiation_remote_data_source.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/domain/repositories/notification_repo.dart';
import 'package:dartz/dartz.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  // ===========================================================================
  // FETCH
  // ===========================================================================

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final models = await remoteDataSource.getNotifications(
        userId: userId,
        limit: limit,
        offset: offset,
      );

      final notifications = models.map((m) => m.toEntity()).toList();
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===========================================================================
  // STREAM
  // ===========================================================================

  @override
  Stream<Either<Failure, List<NotificationEntity>>> streamNotifications(
    String userId,
  ) {
    return remoteDataSource
        .streamNotifications(userId)
        .map((models) {
          final notifications = models.map((m) => m.toEntity()).toList();
          return Right<Failure, List<NotificationEntity>>(notifications);
        })
        .handleError((error) {
          if (error is ServerException) {
            return Left<Failure, List<NotificationEntity>>(
              ServerFailure(error.message),
            );
          }
          return Left<Failure, List<NotificationEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  // ===========================================================================
  // UNREAD COUNT
  // ===========================================================================

  @override
  Future<Either<Failure, int>> getUnreadCount({required String userId}) async {
    try {
      final count = await remoteDataSource.getUnreadCount(userId: userId);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===========================================================================
  // MUTATIONS
  // ===========================================================================

  @override
  Future<Either<Failure, void>> markAsRead({
    required String notificationId,
  }) async {
    try {
      await remoteDataSource.markAsRead(notificationId: notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> archiveNotification({
    required String notificationId,
  }) async {
    try {
      await remoteDataSource.archiveNotification(
        notificationId: notificationId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
