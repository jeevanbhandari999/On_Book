import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/repositories/library_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllBookingsByUserIdUseCase {
  final LibraryRepository repository;

  GetAllBookingsByUserIdUseCase(this.repository);

  Future<Either<Failure, List<Booking>>> call(GetAllBookingsByUserIdParams params) async {
    return await repository.getUserBookings(params.userId);
  }
}

class GetAllBookingsByUserIdParams extends Equatable {
  final String userId;

  const GetAllBookingsByUserIdParams({required this.userId});

  @override
  List<Object> get props => [userId];
}