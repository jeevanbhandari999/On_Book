import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetBookingByIdUseCase {
  final BookingRepository repository;

  const GetBookingByIdUseCase(this.repository);

  Future<Either<Failure, Booking>> call(GetBookingByIdParams params) async {
    // Validate post id
    if (params.bookingId.trim().isEmpty) {
      return const Left(ValidationFailure('Booking ID is required.'));
    }

    //Get the booking by id
    final result = await repository.getBookingById(params.bookingId);

    // If post is found and the user id is also provided the go through the additional features
    if (result.isRight()) {
      final booking = result.fold((_) => null, (booking) => booking);

      if (booking != null) {
        // Check if the user can manage the post or not
        final permissionResult = await repository.isOwnerLogin(
          params.userId,
          booking.id,
        );

        // final canManage = permissionResult.fold((_) => false, (_) => true);

        // print('In use case $canManage');

        if (permissionResult.isLeft()) {
          // log the message if needed but not crash the project
        }
      }
    }
    // return the result
    return result;
  }
}

class GetBookingByIdParams extends Equatable {
  final String bookingId;
  final String userId;

  const GetBookingByIdParams({required this.bookingId, required this.userId});

  @override
  List<Object?> get props => [bookingId, userId];
}
