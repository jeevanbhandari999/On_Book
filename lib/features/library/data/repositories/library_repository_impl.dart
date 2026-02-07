import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/data/datasources/library_local_data_source.dart';
import 'package:app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:app/features/library/domain/repositories/library_repository.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:dartz/dartz.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;
  final LibraryLocalDataSource localDataSource;

  LibraryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings(String userId) async {
    try {
      final remoteBookings = await remoteDataSource.getUserBookings(userId);

      // Cache fresh data
      await localDataSource.cacheUserBookings(userId, remoteBookings);

      return Right(remoteBookings.map((model) => model.toEntity()).toList());
    } catch (e) {
      // Fallback to cache
      try {
        final cached = await localDataSource.getCachedUserBookings(userId);
        if (cached != null && cached.isNotEmpty) {
          return Right(cached.map((model) => model.toEntity()).toList());
        }
      } catch (_) {}

      return const Left(ServerFailure('Failed to load your bookings'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getAllBookingsRelatedToOrganization(
    String organizationId,
  ) async {
    try {
      final remoteBookings = await remoteDataSource
          .getAllBookingsRelatedToOrganization(organizationId);

      // Cache fresh data
      await localDataSource.cacheOrganizationBookings(
        organizationId,
        remoteBookings,
      );

      return Right(remoteBookings.map((model) => model.toEntity()).toList());
    } catch (e) {
      // Fallback to cache
      try {
        final cached = await localDataSource.getCachedOrganizationBookings(
          organizationId,
        );
        if (cached != null && cached.isNotEmpty) {
          return Right(cached.map((model) => model.toEntity()).toList());
        }
      } catch (_) {}

      return const Left(
        ServerFailure('Failed to load your organization bookings'),
      );
    }
  }

  @override
  Future<Either<Failure, Booking>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final updatedBooking = await remoteDataSource.updateBookingStatus(
        bookingId,
        status,
      );

      return Right(updatedBooking.toEntity());
    } catch (e) {
      return const Left(ServerFailure('Failed to load your bookings'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getAllSavedPosts(String userId) async {
    try {
      final resultModel = await remoteDataSource.getAllSavedPosts(userId);
      final posts = resultModel.map((model) => model.toEntity()).toList();
      return Right(posts);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
