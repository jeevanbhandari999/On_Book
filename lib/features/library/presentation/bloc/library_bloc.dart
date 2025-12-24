import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/entities/library_filter_enum.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// EVENTS

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserLibrary extends LibraryEvent {
  final String userId;
  final String? organizationId;

  const LoadUserLibrary({required this.userId, this.organizationId});

  @override
  List<Object?> get props => [userId, organizationId];
}

class ChangeLibraryFilterTabRequested extends LibraryEvent {
  final LibraryFilter filter;

  const ChangeLibraryFilterTabRequested({required this.filter});

  @override
  List<Object> get props => [filter];
}

class RefreshUserLibrary extends LibraryEvent {
  final String userId;
  final String? organizationId;

  const RefreshUserLibrary({required this.userId, this.organizationId});

  @override
  List<Object?> get props => [userId, organizationId];
}

/// STATES

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

// class LibraryRefreshing extends LibraryState {
//   const LibraryRefreshing();
// }

class LibraryRefreshing extends LibraryLoaded {
  const LibraryRefreshing({
    required super.activeFilter,
    required super.upcomingBookings,
    required super.ongoingBookings,
    required super.pastBookings,
    required super.newBookings,
  });

  // Override copyWith to return LibraryRefreshing
  @override
  LibraryRefreshing copyWith({
    LibraryFilter? activeFilter,
    List<Booking>? ongoingBookings,
    List<Booking>? upcomingBookings,
    List<Booking>? pastBookings,
    List<Booking>? newBookings,
  }) {
    return LibraryRefreshing(
      activeFilter: activeFilter ?? this.activeFilter,
      ongoingBookings: ongoingBookings ?? this.ongoingBookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      newBookings: newBookings ?? this.newBookings,
    );
  }
}

class LibraryLoaded extends LibraryState {
  final LibraryFilter activeFilter;
  final List<Booking> upcomingBookings;
  final List<Booking> ongoingBookings;
  final List<Booking> pastBookings;
  final List<Booking>
  newBookings; // This booking is related to the organizations, mean booked by user

  const LibraryLoaded({
    required this.activeFilter,
    required this.upcomingBookings,
    required this.ongoingBookings,
    required this.pastBookings,
    required this.newBookings,
  });

  bool get hasBookings =>
      upcomingBookings.isNotEmpty ||
      ongoingBookings.isNotEmpty ||
      pastBookings.isNotEmpty ||
      newBookings.isNotEmpty;

  LibraryLoaded copyWith({
    LibraryFilter? activeFilter,
    List<Booking>? ongoingBookings,
    List<Booking>? upcomingBookings,
    List<Booking>? pastBookings,
    List<Booking>? newBookings,
  }) {
    return LibraryLoaded(
      activeFilter: activeFilter ?? this.activeFilter,
      ongoingBookings: ongoingBookings ?? this.ongoingBookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      newBookings: newBookings ?? this.newBookings,
    );
  }

  @override
  List<Object?> get props => [
    activeFilter,
    upcomingBookings,
    ongoingBookings,
    pastBookings,
    newBookings,
  ];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError({required this.message});

  @override
  List<Object> get props => [message];
}

/// BLOC

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetAllBookingsByUserIdUseCase _getAllBookingsByUserIdUseCase;
  final GetAllBookingRelatedToOrganizationUseCase
  _getAllBookingRelatedToOrganizationUseCase;

  LibraryBloc({
    required GetAllBookingsByUserIdUseCase getAllBookingsByUserIdUseCase,
    required GetAllBookingRelatedToOrganizationUseCase
    getAllBookingRelatedToOrganizationUseCase,
  }) : _getAllBookingsByUserIdUseCase = getAllBookingsByUserIdUseCase,
       _getAllBookingRelatedToOrganizationUseCase =
           getAllBookingRelatedToOrganizationUseCase,
       super(const LibraryInitial()) {
    on<LoadUserLibrary>(_onLoadUserLibrary);
    on<RefreshUserLibrary>(_onRefreshUserLibrary);
    on<ChangeLibraryFilterTabRequested>(_onChangeFilter);
  }

  Future<void> _onLoadUserLibrary(
    LoadUserLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    final previousFilter = state is LibraryLoaded
        ? (state as LibraryLoaded).activeFilter
        : null;
    emit(const LibraryLoading());

    final userBookingsResult = await _getAllBookingsByUserIdUseCase(
      GetAllBookingsByUserIdParams(userId: event.userId),
    );

    if (event.organizationId != null) {
      // Fetch organization-related bookings only if organizationId is provided
      final organizationBookingsResult =
          await _getAllBookingRelatedToOrganizationUseCase(
            GetAllBookingRelatedToOrganizationParams(
              organizationId: event.organizationId!,
            ),
          );

      await userBookingsResult.fold(
        (failure) async {
          emit(LibraryError(message: _mapFailureToMessage(failure)));
        },
        (userBookings) async {
          await organizationBookingsResult.fold(
            (failure) async {
              emit(LibraryError(message: _mapFailureToMessage(failure)));
            },
            (organizationBookings) async {
              emit(
                _buildLoadedState(
                  userBookings,
                  organizationBookings,
                  previousFilter,
                ),
              );
            },
          );
        },
      );
    } else {
      // If no organizationId is provided, just load user bookings
      await userBookingsResult.fold(
        (failure) async {
          emit(LibraryError(message: _mapFailureToMessage(failure)));
        },
        (userBookings) async {
          emit(_buildLoadedState(userBookings, [], previousFilter));
        },
      );
    }
  }

  Future<void> _onRefreshUserLibrary(
    RefreshUserLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded && state is! LibraryRefreshing) {
      final currentState = state as LibraryLoaded;
      emit(
        LibraryRefreshing(
          activeFilter: currentState.activeFilter,
          upcomingBookings: currentState.upcomingBookings,
          ongoingBookings: currentState.ongoingBookings,
          pastBookings: currentState.pastBookings,
          newBookings: currentState.newBookings,
        ),
      );
    }

    final previousFilter = state is LibraryLoaded
        ? (state as LibraryLoaded).activeFilter
        : null;

    final userBookingsResult = await _getAllBookingsByUserIdUseCase(
      GetAllBookingsByUserIdParams(userId: event.userId),
    );

    if (event.organizationId != null) {
      final organizationBookingsResult =
          await _getAllBookingRelatedToOrganizationUseCase(
            GetAllBookingRelatedToOrganizationParams(
              organizationId: event.organizationId!,
            ),
          );

      await userBookingsResult.fold(
        (failure) async {
          emit(LibraryError(message: _mapFailureToMessage(failure)));
        },
        (userBookings) async {
          await organizationBookingsResult.fold(
            (failure) async {
              emit(LibraryError(message: _mapFailureToMessage(failure)));
            },
            (organizationBookings) async {
              emit(
                _buildLoadedState(
                  userBookings,
                  organizationBookings,
                  previousFilter,
                ),
              );
            },
          );
        },
      );
    } else {
      await userBookingsResult.fold(
        (failure) async {
          emit(LibraryError(message: _mapFailureToMessage(failure)));
        },
        (userBookings) async {
          emit(_buildLoadedState(userBookings, [], previousFilter));
        },
      );
    }
  }

  void _onChangeFilter(
    ChangeLibraryFilterTabRequested event,
    Emitter<LibraryState> emit,
  ) {
    if (state is! LibraryLoaded) return;

    final current = state as LibraryLoaded;

    emit(current.copyWith(activeFilter: event.filter));
  }

  LibraryLoaded _buildLoadedState(
    List<Booking> bookings,
    List<Booking> newBookings,
    LibraryFilter? previousFilter,
  ) {
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
      activeFilter: previousFilter ?? LibraryFilter.all,
      upcomingBookings: upcoming,
      ongoingBookings: ongoing,
      pastBookings: past,
      newBookings: newBookings,
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
