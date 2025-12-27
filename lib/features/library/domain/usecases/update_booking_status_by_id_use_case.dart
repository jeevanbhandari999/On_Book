import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/repositories/library_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateBookingStatusByIdUseCase {
  final LibraryRepository repository;
  UpdateBookingStatusByIdUseCase(this.repository);

  Future<Either<Failure, Booking>> call(
    UpdateBookingStatusByIdParams params,
  ) async {
    return repository.updateBookingStatus(params.bookingId, params.status);
  }
}

class UpdateBookingStatusByIdParams extends Equatable {
  final String bookingId;
  final String status;

  const UpdateBookingStatusByIdParams({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object> get props => [bookingId, status];
}
