import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:dartz/dartz.dart';

abstract class LibraryRepository {
  // Get user bookings lists
  Future<Either<Failure, List<Booking>>> getUserBookings(String userId);
}
