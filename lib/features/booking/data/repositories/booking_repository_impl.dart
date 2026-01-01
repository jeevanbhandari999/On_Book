import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  const BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Booking>> createBooking(Booking booking, String postId) async {
    try {
      final bookingModel = await remoteDataSource.createBooking(
        BookingModel.fromEntity(booking),
        postId,
      );
      return Right(bookingModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to create booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    try {
      final bookingModel = await remoteDataSource.getBookingById(bookingId);
      return Right(bookingModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to fetch booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> updateBooking(String bookingId, Booking booking) async {
    try {
      final bookingModel = await remoteDataSource.updateBooking(
        bookingId,
        BookingModel.fromEntity(booking),
      );
      return Right(bookingModel.toEntity());
    } catch (e) {
      return Left(ServerFailure( 'Failed to update booking: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isOwnerLogin(String userId, String bookingId)async {
    try {
      final canManage = await remoteDataSource.isOwnerLogin(
        userId,
        bookingId,
      );
      return Right(canManage);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}