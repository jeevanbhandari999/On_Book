import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/repositories/library_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllBookingRelatedToOrganizationUseCase {
  final LibraryRepository repository;

  GetAllBookingRelatedToOrganizationUseCase(this.repository);

  Future<Either<Failure, List<Booking>>> call(
    GetAllBookingRelatedToOrganizationParams params,
  ) async {
    return await repository.getAllBookingsRelatedToOrganization(
      params.organizationId,
    );
  }
}

class GetAllBookingRelatedToOrganizationParams extends Equatable {
  final String organizationId;

  const GetAllBookingRelatedToOrganizationParams({
    required this.organizationId,
  });

  @override
  List<Object> get props => [organizationId];
}
