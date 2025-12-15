import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:dartz/dartz.dart';

abstract class BookingRepository {
  /// Create a new booking
  Future<Either<Failure, Booking>> createBooking(Booking booking);

  /// Get a specific booking by Id
  Future<Either<Failure, Booking>> getBookingById(String bookingId);

  /// Update an existing booking
  Future<Either<Failure, Booking>> updateBooking(String bookingId, Booking booking);
}