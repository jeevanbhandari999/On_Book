import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/data/datasources/library_local_data_source.dart';
import 'package:app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:app/features/library/domain/repositories/library_repository.dart';
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
}
