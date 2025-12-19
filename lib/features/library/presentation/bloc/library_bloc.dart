import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ==================== EVENTS ====================

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserLibrary extends LibraryEvent {
  final String userId;

  const LoadUserLibrary(this.userId);

  @override
  List<Object> get props => [userId];
}

class RefreshUserLibrary extends LibraryEvent {
  final String userId;

  const RefreshUserLibrary(this.userId);

  @override
  List<Object> get props => [userId];
}

/// ==================== STATES ====================

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

class LibraryLoaded extends LibraryState {
  final List<Booking> upcomingBookings;
  final List<Booking> ongoingBookings;
  final List<Booking> pastBookings;

  const LibraryLoaded({
    required this.upcomingBookings,
    required this.ongoingBookings,
    required this.pastBookings,
  });

  bool get hasBookings =>
      upcomingBookings.isNotEmpty ||
      ongoingBookings.isNotEmpty ||
      pastBookings.isNotEmpty;

  @override
  List<Object?> get props => [upcomingBookings, ongoingBookings, pastBookings];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError({required this.message});

  @override
  List<Object> get props => [message];
}

/// ==================== BLOC ====================

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetAllBookingsByUserIdUseCase _getAllBookingsByUserIdUseCase;

  LibraryBloc({
    required GetAllBookingsByUserIdUseCase getAllBookingsByUserIdUseCase,
  }) : _getAllBookingsByUserIdUseCase = getAllBookingsByUserIdUseCase,
       super(const LibraryInitial()) {
    on<LoadUserLibrary>(_onLoadUserLibrary);
    on<RefreshUserLibrary>(_onRefreshUserLibrary);
  }

  Future<void> _onLoadUserLibrary(
    LoadUserLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    final result = await _getAllBookingsByUserIdUseCase(
      GetAllBookingsByUserIdParams(userId: event.userId),
    );

    await result.fold(
      (failure) async {
        emit(LibraryError(message: _mapFailureToMessage(failure)));
      },
      (bookings) async {
        print(bookings.length);
        emit(_buildLoadedState(bookings));
      },
    );
  }

  Future<void> _onRefreshUserLibrary(
    RefreshUserLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    // Optional: show loading only if current state is not loading
    if (state is! LibraryLoading) {
      emit(const LibraryLoading());
    }

    final result = await _getAllBookingsByUserIdUseCase(
      GetAllBookingsByUserIdParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(LibraryError(message: _mapFailureToMessage(failure))),
      (bookings) {
        print(bookings.length);
        emit(_buildLoadedState(bookings));
      },
    );
  }

  LibraryLoaded _buildLoadedState(List<Booking> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming =
        bookings
            .where(
              (b) =>
                  b.checkInDate.isAfter(
                    today.subtract(const Duration(days: 1)),
                  ) && // check-in today or future
                  b.status != BookingStatus.cancelled,
            )
            .toList()
          ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

    final ongoing = bookings
        .where(
          (b) =>
              b.checkInDate.isBefore(now) &&
              b.checkOutDate.isAfter(now) &&
              b.status == BookingStatus.confirmed,
        )
        .toList();

    final past =
        bookings
            .where(
              (b) =>
                  b.checkOutDate.isBefore(now) ||
                  b.status == BookingStatus.cancelled,
            )
            .toList()
          ..sort((a, b) => b.checkOutDate.compareTo(a.checkOutDate));

    return LibraryLoaded(
      upcomingBookings: upcoming,
      ongoingBookings: ongoing,
      pastBookings: past,
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    if (failure is NetworkFailure) {
      return 'No internet connection';
    }
    if (failure is CacheFailure) {
      return 'Failed to load from cache';
    }
    return 'Failed to load your bookings. Please try again.';
  }
}
