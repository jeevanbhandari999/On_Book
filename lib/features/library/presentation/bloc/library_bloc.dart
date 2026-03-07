// // // import 'dart:async';

// // // import 'package:app/core/errors/failures.dart';
// // // import 'package:app/features/booking/domain/entities/booking.dart';
// // // import 'package:app/features/library/domain/entities/library_filter_enum.dart';
// // // import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
// // // import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
// // // import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
// // // import 'package:equatable/equatable.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';

// // // /// EVENTS
// // // abstract class LibraryEvent extends Equatable {
// // //   const LibraryEvent();

// // //   @override
// // //   List<Object?> get props => [];
// // // }

// // // class LoadUserLibrary extends LibraryEvent {
// // //   final String userId;
// // //   final String? organizationId;

// // //   const LoadUserLibrary({required this.userId, this.organizationId});

// // //   @override
// // //   List<Object?> get props => [userId, organizationId];
// // // }

// // // class ChangeLibraryFilterTabRequested extends LibraryEvent {
// // //   final LibraryFilter filter;

// // //   const ChangeLibraryFilterTabRequested({required this.filter});

// // //   @override
// // //   List<Object> get props => [filter];
// // // }

// // // class RefreshUserLibrary extends LibraryEvent {
// // //   final String userId;
// // //   final String? organizationId;

// // //   const RefreshUserLibrary({required this.userId, this.organizationId});

// // //   @override
// // //   List<Object?> get props => [userId, organizationId];
// // // }

// // // /// Update the booking status (cancel(through user(the booked user, who actually booked the resturant)), reject, comfirm)
// // // class UpdateBookingStatusFromLibraryPage extends LibraryEvent {
// // //   final String bookingId;
// // //   final String status;

// // //   const UpdateBookingStatusFromLibraryPage({
// // //     required this.bookingId,
// // //     required this.status,
// // //   });

// // //   @override
// // //   List<Object> get props => [bookingId, status];
// // // }

// // // /// STATES
// // // abstract class LibraryState extends Equatable {
// // //   const LibraryState();

// // //   @override
// // //   List<Object?> get props => [];
// // // }

// // // class LibraryInitial extends LibraryState {
// // //   const LibraryInitial();
// // // }

// // // class LibraryLoading extends LibraryState {
// // //   const LibraryLoading();
// // // }

// // // // class LibraryRefreshing extends LibraryState {
// // // //   const LibraryRefreshing();
// // // // }

// // // class UpdatingBookingStatusFromLibraryPage extends LibraryState {
// // //   const UpdatingBookingStatusFromLibraryPage();
// // // }

// // // class UpdateBookingStatusFromLibraryPageSuccess extends LibraryState {
// // //   final Booking booking;
// // //   final String? successMessage;

// // //   const UpdateBookingStatusFromLibraryPageSuccess({
// // //     required this.booking,
// // //     this.successMessage,
// // //   });

// // //   @override
// // //   List<Object?> get props => [booking, successMessage];
// // // }

// // // class LibraryRefreshing extends LibraryLoaded {
// // //   const LibraryRefreshing({
// // //     required super.activeFilter,
// // //     required super.myBooking,
// // //     required super.upcomingBookings,
// // //     required super.ongoingBookings,
// // //     required super.pastBookings,
// // //     required super.newBookings,
// // //     required super.cancledBookings,
// // //     required super.confirmedBookings,
// // //     required super.rejectedBookings,
// // //   });

// // //   // Override copyWith to return LibraryRefreshing
// // //   @override
// // //   LibraryRefreshing copyWith({
// // //     LibraryFilter? activeFilter,
// // //     List<Booking>? myBooking,
// // //     List<Booking>? ongoingBookings,
// // //     List<Booking>? upcomingBookings,
// // //     List<Booking>? pastBookings,
// // //     List<Booking>? newBookings,
// // //     List<Booking>? cancledBookings,
// // //     List<Booking>? confirmedBookings,
// // //     List<Booking>? rejectedBookings,
// // //   }) {
// // //     return LibraryRefreshing(
// // //       activeFilter: activeFilter ?? this.activeFilter,
// // //       myBooking: myBooking ?? this.myBooking,
// // //       ongoingBookings: ongoingBookings ?? this.ongoingBookings,
// // //       upcomingBookings: upcomingBookings ?? this.upcomingBookings,
// // //       pastBookings: pastBookings ?? this.pastBookings,
// // //       newBookings: newBookings ?? this.newBookings,
// // //       cancledBookings: cancledBookings ?? this.cancledBookings,
// // //       confirmedBookings: confirmedBookings ?? this.confirmedBookings,
// // //       rejectedBookings: rejectedBookings ?? this.rejectedBookings,
// // //     );
// // //   }
// // // }

// // // class LibraryLoaded extends LibraryState {
// // //   final LibraryFilter activeFilter;
// // //   final List<Booking> myBooking;
// // //   final List<Booking> upcomingBookings;
// // //   final List<Booking> ongoingBookings;
// // //   final List<Booking> pastBookings;
// // //   // This booking is related to the organizations, mean booked by user
// // //   final List<Booking> newBookings;
// // //   final List<Booking> cancledBookings;
// // //   final List<Booking> confirmedBookings;
// // //   final List<Booking> rejectedBookings;

// // //   const LibraryLoaded({
// // //     required this.activeFilter,
// // //     required this.myBooking,
// // //     required this.upcomingBookings,
// // //     required this.ongoingBookings,
// // //     required this.pastBookings,
// // //     required this.newBookings,
// // //     required this.cancledBookings,
// // //     required this.confirmedBookings,
// // //     required this.rejectedBookings,
// // //   });

// // //   bool get hasBookings =>
// // //       upcomingBookings.isNotEmpty ||
// // //       ongoingBookings.isNotEmpty ||
// // //       pastBookings.isNotEmpty ||
// // //       newBookings.isNotEmpty ||
// // //       myBooking.isNotEmpty;

// // //   LibraryLoaded copyWith({
// // //     LibraryFilter? activeFilter,
// // //     List<Booking>? myBooking,
// // //     List<Booking>? ongoingBookings,
// // //     List<Booking>? upcomingBookings,
// // //     List<Booking>? pastBookings,
// // //     List<Booking>? newBookings,
// // //     List<Booking>? cancledBookings,
// // //     List<Booking>? confirmedBookings,
// // //     List<Booking>? rejectedBookings,
// // //   }) {
// // //     return LibraryLoaded(
// // //       activeFilter: activeFilter ?? this.activeFilter,
// // //       myBooking: myBooking ?? this.myBooking,
// // //       ongoingBookings: ongoingBookings ?? this.ongoingBookings,
// // //       upcomingBookings: upcomingBookings ?? this.upcomingBookings,
// // //       pastBookings: pastBookings ?? this.pastBookings,
// // //       newBookings: newBookings ?? this.newBookings,
// // //       cancledBookings: cancledBookings ?? this.cancledBookings,
// // //       confirmedBookings: confirmedBookings ?? this.confirmedBookings,
// // //       rejectedBookings: rejectedBookings ?? this.rejectedBookings,
// // //     );
// // //   }

// // //   @override
// // //   List<Object?> get props => [
// // //     activeFilter,
// // //     myBooking,
// // //     upcomingBookings,
// // //     ongoingBookings,
// // //     pastBookings,
// // //     newBookings,
// // //     cancledBookings,
// // //     confirmedBookings,
// // //     rejectedBookings,
// // //   ];
// // // }

// // // class LibraryError extends LibraryState {
// // //   final String message;

// // //   const LibraryError({required this.message});

// // //   @override
// // //   List<Object> get props => [message];
// // // }

// // // /// BLOC

// // // class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
// // //   final GetAllBookingsByUserIdUseCase _getAllBookingsByUserIdUseCase;
// // //   final GetAllBookingRelatedToOrganizationUseCase
// // //   _getAllBookingRelatedToOrganizationUseCase;
// // //   final UpdateBookingStatusByIdUseCase _updateBookingStatusByIdUseCase;

// // //   LibraryBloc({
// // //     required GetAllBookingsByUserIdUseCase getAllBookingsByUserIdUseCase,
// // //     required GetAllBookingRelatedToOrganizationUseCase
// // //     getAllBookingRelatedToOrganizationUseCase,
// // //     required UpdateBookingStatusByIdUseCase updateBookingStatusByIdUseCase,
// // //   }) : _getAllBookingsByUserIdUseCase = getAllBookingsByUserIdUseCase,
// // //        _getAllBookingRelatedToOrganizationUseCase =
// // //            getAllBookingRelatedToOrganizationUseCase,
// // //        _updateBookingStatusByIdUseCase = updateBookingStatusByIdUseCase,
// // //        super(const LibraryInitial()) {
// // //     on<LoadUserLibrary>(_onLoadUserLibrary);
// // //     on<RefreshUserLibrary>(_onRefreshUserLibrary);
// // //     on<ChangeLibraryFilterTabRequested>(_onChangeFilter);
// // //     on<UpdateBookingStatusFromLibraryPage>(
// // //       _onUpdateBookingStatusFromLibraryPage,
// // //     );
// // //   }

// // //   Future<void> _onLoadUserLibrary(
// // //     LoadUserLibrary event,
// // //     Emitter<LibraryState> emit,
// // //   ) async {
// // //     final previousFilter = state is LibraryLoaded
// // //         ? (state as LibraryLoaded).activeFilter
// // //         : null;
// // //     emit(const LibraryLoading());

// // //     final userBookingsResult = await _getAllBookingsByUserIdUseCase(
// // //       GetAllBookingsByUserIdParams(userId: event.userId),
// // //     );

// // //     if (event.organizationId != null) {
// // //       // Fetch organization-related bookings only if organizationId is provided
// // //       final organizationBookingsResult =
// // //           await _getAllBookingRelatedToOrganizationUseCase(
// // //             GetAllBookingRelatedToOrganizationParams(
// // //               organizationId: event.organizationId!,
// // //             ),
// // //           );

// // //       await userBookingsResult.fold(
// // //         (failure) async {
// // //           emit(LibraryError(message: _mapFailureToMessage(failure)));
// // //         },
// // //         (userBookings) async {
// // //           await organizationBookingsResult.fold(
// // //             (failure) async {
// // //               emit(LibraryError(message: _mapFailureToMessage(failure)));
// // //             },
// // //             (organizationBookings) async {
// // //               final mergedBookings = _mergeUniqueBookings(
// // //                 userBookings,
// // //                 organizationBookings,
// // //               );

// // //               emit(
// // //                 _buildLoadedState(
// // //                   mergedBookings,
// // //                   userBookings,
// // //                   organizationBookings,
// // //                   previousFilter,
// // //                 ),
// // //               );
// // //             },
// // //           );
// // //         },
// // //       );
// // //     } else {
// // //       // If no organizationId is provided, just load user bookings
// // //       await userBookingsResult.fold(
// // //         (failure) async {
// // //           emit(LibraryError(message: _mapFailureToMessage(failure)));
// // //         },
// // //         (userBookings) async {
// // //           emit(
// // //             _buildLoadedState(userBookings, userBookings, [], previousFilter),
// // //           );
// // //         },
// // //       );
// // //     }
// // //   }

// // //   Future<void> _onRefreshUserLibrary(
// // //     RefreshUserLibrary event,
// // //     Emitter<LibraryState> emit,
// // //   ) async {
// // //     if (state is LibraryRefreshing) return;
// // //     if (state is LibraryLoaded && state is! LibraryRefreshing) {
// // //       final currentState = state as LibraryLoaded;
// // //       emit(
// // //         LibraryRefreshing(
// // //           activeFilter: currentState.activeFilter,
// // //           myBooking: currentState.myBooking,
// // //           upcomingBookings: currentState.upcomingBookings,
// // //           ongoingBookings: currentState.ongoingBookings,
// // //           pastBookings: currentState.pastBookings,
// // //           newBookings: currentState.newBookings,
// // //           cancledBookings: currentState.cancledBookings,
// // //           confirmedBookings: currentState.confirmedBookings,
// // //           rejectedBookings: currentState.rejectedBookings,
// // //         ),
// // //       );
// // //     }

// // //     final previousFilter = state is LibraryLoaded
// // //         ? (state as LibraryLoaded).activeFilter
// // //         : null;

// // //     final userBookingsResult = await _getAllBookingsByUserIdUseCase(
// // //       GetAllBookingsByUserIdParams(userId: event.userId),
// // //     );

// // //     if (event.organizationId != null) {
// // //       final organizationBookingsResult =
// // //           await _getAllBookingRelatedToOrganizationUseCase(
// // //             GetAllBookingRelatedToOrganizationParams(
// // //               organizationId: event.organizationId!,
// // //             ),
// // //           );

// // //       await userBookingsResult.fold(
// // //         (failure) async {
// // //           emit(LibraryError(message: _mapFailureToMessage(failure)));
// // //         },
// // //         (userBookings) async {
// // //           await organizationBookingsResult.fold(
// // //             (failure) async {
// // //               emit(LibraryError(message: _mapFailureToMessage(failure)));
// // //             },
// // //             (organizationBookings) async {
// // //               final mergedBookings = _mergeUniqueBookings(
// // //                 userBookings,
// // //                 organizationBookings,
// // //               );

// // //               emit(
// // //                 _buildLoadedState(
// // //                   mergedBookings,
// // //                   userBookings,
// // //                   organizationBookings,
// // //                   previousFilter,
// // //                 ),
// // //               );
// // //             },
// // //           );
// // //         },
// // //       );
// // //     } else {
// // //       await userBookingsResult.fold(
// // //         (failure) async {
// // //           emit(LibraryError(message: _mapFailureToMessage(failure)));
// // //         },
// // //         (userBookings) async {
// // //           emit(
// // //             _buildLoadedState(userBookings, userBookings, [], previousFilter),
// // //           );
// // //         },
// // //       );
// // //     }
// // //   }

// // //   void _onChangeFilter(
// // //     ChangeLibraryFilterTabRequested event,
// // //     Emitter<LibraryState> emit,
// // //   ) {
// // //     if (state is! LibraryLoaded) return;

// // //     final current = state as LibraryLoaded;

// // //     emit(current.copyWith(activeFilter: event.filter));
// // //   }

// // //   LibraryLoaded _buildLoadedState(
// // //     List<Booking> bookings,
// // //     List<Booking> myBooking,
// // //     List<Booking> newBookings,
// // //     LibraryFilter? previousFilter,
// // //   ) {
// // //     final now = DateTime.now();
// // //     final today = DateTime(now.year, now.month, now.day);

// // //     final upcoming =
// // //         bookings
// // //             .where(
// // //               (b) =>
// // //                   b.checkInDate.isAfter(
// // //                     today.subtract(const Duration(days: 1)),
// // //                   ) && // check-in today or future
// // //                   b.status != BookingStatus.cancelled,
// // //             )
// // //             .toList()
// // //           ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

// // //     final ongoing = bookings
// // //         .where(
// // //           (b) =>
// // //               b.checkInDate.isBefore(now) &&
// // //               b.checkOutDate.isAfter(now) &&
// // //               b.status == BookingStatus.confirmed,
// // //         )
// // //         .toList();

// // //     final past =
// // //         bookings
// // //             .where(
// // //               (b) =>
// // //                   b.checkOutDate.isBefore(now) ||
// // //                   b.status == BookingStatus.cancelled,
// // //             )
// // //             .toList()
// // //           ..sort((a, b) => b.checkOutDate.compareTo(a.checkOutDate));

// // //     final canceldBooking = bookings
// // //         .where((b) => b.status == BookingStatus.cancelled)
// // //         .toList();
// // //     final confirmedBooking = bookings
// // //         .where((b) => b.status == BookingStatus.confirmed)
// // //         .toList();
// // //     final rejectedBooking = bookings
// // //         .where((b) => b.status == BookingStatus.rejected)
// // //         .toList();

// // //     return LibraryLoaded(
// // //       activeFilter: previousFilter ?? LibraryFilter.all,
// // //       upcomingBookings: upcoming,
// // //       myBooking: myBooking,
// // //       ongoingBookings: ongoing,
// // //       pastBookings: past,
// // //       newBookings: newBookings,
// // //       rejectedBookings: rejectedBooking,
// // //       confirmedBookings: confirmedBooking,
// // //       cancledBookings: canceldBooking,
// // //     );
// // //   }

// // //   String _mapFailureToMessage(Failure failure) {
// // //     if (failure is ServerFailure) {
// // //       return failure.message;
// // //     }
// // //     if (failure is NetworkFailure) {
// // //       return 'No internet connection';
// // //     }
// // //     if (failure is CacheFailure) {
// // //       return 'Failed to load from cache';
// // //     }
// // //     return 'Failed to load your bookings. Please try again.';
// // //   }

// // //   List<Booking> _mergeUniqueBookings(
// // //     List<Booking> userBookings,
// // //     List<Booking> organizationBookings,
// // //   ) {
// // //     final map = <String, Booking>{};

// // //     for (final booking in userBookings) {
// // //       map[booking.id] = booking;
// // //     }

// // //     for (final booking in organizationBookings) {
// // //       map[booking.id] = booking; // overrides if duplicate
// // //     }

// // //     return map.values.toList();
// // //   }

// // //   Future<void> _onUpdateBookingStatusFromLibraryPage(
// // //     UpdateBookingStatusFromLibraryPage event,
// // //     Emitter<LibraryState> emit,
// // //   ) async {
// // //     try {
// // //       if (state is! LibraryLoaded) return;

// // //       final currentState = state as LibraryLoaded;
// // //       final updateBookingStatusParams = UpdateBookingStatusByIdParams(
// // //         bookingId: event.bookingId,
// // //         status: event.status,
// // //       );

// // //       final response = await _updateBookingStatusByIdUseCase(
// // //         updateBookingStatusParams,
// // //       );

// // //       // response.fold(
// // //       //   (failure) => emit(LibraryError(message: failure.message)),
// // //       //   (statusUpdatedData) => emit(
// // //       //     UpdateBookingStatusFromLibraryPageSuccess(
// // //       //       booking: statusUpdatedData,
// // //       //       successMessage: _getSuccessMessage(statusUpdatedData.status),
// // //       //     ),
// // //       //   ),
// // //       // );
// // //       response.fold(
// // //         (failure) {
// // //           emit(LibraryError(message: failure.message));
// // //         },
// // //         (updatedBooking) {
// // //           List<Booking> updateList(List<Booking> list) {
// // //             return list
// // //                 .map((b) => b.id == updatedBooking.id ? updatedBooking : b)
// // //                 .toList();
// // //           }

// // //           emit(
// // //             currentState.copyWith(
// // //               myBooking: updateList(currentState.myBooking),
// // //               upcomingBookings: updateList(currentState.upcomingBookings),
// // //               ongoingBookings: updateList(currentState.ongoingBookings),
// // //               pastBookings: updateList(currentState.pastBookings),
// // //               newBookings: updateList(currentState.newBookings),
// // //             ),
// // //           );
// // //         },
// // //       );
// // //     } catch (e) {
// // //       emit(LibraryError(message: e.toString()));
// // //     }
// // //   }
// // // }

// // // String? _getSuccessMessage(BookingStatus status) {
// // //   switch (status) {
// // //     case BookingStatus.pending:
// // //       return 'Booking request has been sent and is awaiting confirmation.';

// // //     case BookingStatus.confirmed:
// // //       return 'Your booking has been confirmed successfully.';

// // //     case BookingStatus.cancelled:
// // //       return 'Your booking has been cancelled successfully.';

// // //     case BookingStatus.rejected:
// // //       return 'The booking request has been rejected.';

// // //     case BookingStatus.completed:
// // //       return 'Your booking has been completed successfully.';
// // //   }
// // // }

// // import 'dart:async';

// // import 'package:app/core/errors/failures.dart';
// // import 'package:app/features/booking/domain/entities/booking.dart';
// // import 'package:app/features/library/domain/entities/library_filter_enum.dart';
// // import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
// // import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
// // import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
// // import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
// // import 'package:app/features/post/domain/entities/post.dart';
// // import 'package:equatable/equatable.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';

// // /// EVENTS
// // abstract class LibraryEvent extends Equatable {
// //   const LibraryEvent();

// //   @override
// //   List<Object?> get props => [];
// // }

// // class LoadUserLibrary extends LibraryEvent {
// //   final String userId;
// //   final String? organizationId;

// //   const LoadUserLibrary({required this.userId, this.organizationId});

// //   @override
// //   List<Object?> get props => [userId, organizationId];
// // }

// // class ChangeLibraryFilterTabRequested extends LibraryEvent {
// //   final LibraryFilter filter;

// //   const ChangeLibraryFilterTabRequested({required this.filter});

// //   @override
// //   List<Object> get props => [filter];
// // }

// // class RefreshUserLibrary extends LibraryEvent {
// //   final String userId;
// //   final String? organizationId;

// //   const RefreshUserLibrary({required this.userId, this.organizationId});

// //   @override
// //   List<Object?> get props => [userId, organizationId];
// // }

// // class UpdateBookingStatusFromLibraryPage extends LibraryEvent {
// //   final String bookingId;
// //   final String status;

// //   const UpdateBookingStatusFromLibraryPage({
// //     required this.bookingId,
// //     required this.status,
// //   });

// //   @override
// //   List<Object> get props => [bookingId, status];
// // }

// // /// STATES
// // abstract class LibraryState extends Equatable {
// //   const LibraryState();

// //   @override
// //   List<Object?> get props => [];
// // }

// // class LibraryInitial extends LibraryState {
// //   const LibraryInitial();
// // }

// // class LibraryLoading extends LibraryState {
// //   const LibraryLoading();
// // }

// // class LibraryRefreshing extends LibraryLoaded {
// //   const LibraryRefreshing({
// //     required super.activeFilter,
// //     required super.bookingsData,
// //     required super.savedPostsData,
// //   });

// //   @override
// //   LibraryRefreshing copyWith({
// //     LibraryFilter? activeFilter,
// //     BookingsData? bookingsData,
// //     SavedPostsData? savedPostsData,
// //   }) {
// //     return LibraryRefreshing(
// //       activeFilter: activeFilter ?? this.activeFilter,
// //       bookingsData: bookingsData ?? this.bookingsData,
// //       savedPostsData: savedPostsData ?? this.savedPostsData,
// //     );
// //   }
// // }

// // class LibraryLoaded extends LibraryState {
// //   final LibraryFilter activeFilter;
// //   final BookingsData bookingsData;
// //   final SavedPostsData savedPostsData;

// //   const LibraryLoaded({
// //     required this.activeFilter,
// //     required this.bookingsData,
// //     required this.savedPostsData,
// //   });

// //   bool get hasContent =>
// //       bookingsData.hasBookings || savedPostsData.hasSavedPosts;

// //   LibraryLoaded copyWith({
// //     LibraryFilter? activeFilter,
// //     BookingsData? bookingsData,
// //     SavedPostsData? savedPostsData,
// //   }) {
// //     return LibraryLoaded(
// //       activeFilter: activeFilter ?? this.activeFilter,
// //       bookingsData: bookingsData ?? this.bookingsData,
// //       savedPostsData: savedPostsData ?? this.savedPostsData,
// //     );
// //   }

// //   @override
// //   List<Object?> get props => [
// //         activeFilter,
// //         bookingsData,
// //         savedPostsData,
// //       ];
// // }

// // class LibraryError extends LibraryState {
// //   final String message;

// //   const LibraryError({required this.message});

// //   @override
// //   List<Object> get props => [message];
// // }

// // /// DATA MODELS
// // class BookingsData extends Equatable {
// //   final List<Booking> myBooking;
// //   final List<Booking> upcomingBookings;
// //   final List<Booking> ongoingBookings;
// //   final List<Booking> pastBookings;
// //   final List<Booking> newBookings;
// //   final List<Booking> cancelledBookings;
// //   final List<Booking> confirmedBookings;
// //   final List<Booking> rejectedBookings;
// //   final bool isLoading;

// //   const BookingsData({
// //     required this.myBooking,
// //     required this.upcomingBookings,
// //     required this.ongoingBookings,
// //     required this.pastBookings,
// //     required this.newBookings,
// //     required this.cancelledBookings,
// //     required this.confirmedBookings,
// //     required this.rejectedBookings,
// //     this.isLoading = false,
// //   });

// //   bool get hasBookings =>
// //       upcomingBookings.isNotEmpty ||
// //       ongoingBookings.isNotEmpty ||
// //       pastBookings.isNotEmpty ||
// //       newBookings.isNotEmpty ||
// //       myBooking.isNotEmpty;

// //   List<Booking> get allBookings => [
// //         ...ongoingBookings,
// //         ...upcomingBookings,
// //         ...pastBookings,
// //       ];

// //   factory BookingsData.empty() {
// //     return const BookingsData(
// //       myBooking: [],
// //       upcomingBookings: [],
// //       ongoingBookings: [],
// //       pastBookings: [],
// //       newBookings: [],
// //       cancelledBookings: [],
// //       confirmedBookings: [],
// //       rejectedBookings: [],
// //     );
// //   }

// //   BookingsData copyWith({
// //     List<Booking>? myBooking,
// //     List<Booking>? upcomingBookings,
// //     List<Booking>? ongoingBookings,
// //     List<Booking>? pastBookings,
// //     List<Booking>? newBookings,
// //     List<Booking>? cancelledBookings,
// //     List<Booking>? confirmedBookings,
// //     List<Booking>? rejectedBookings,
// //     bool? isLoading,
// //   }) {
// //     return BookingsData(
// //       myBooking: myBooking ?? this.myBooking,
// //       upcomingBookings: upcomingBookings ?? this.upcomingBookings,
// //       ongoingBookings: ongoingBookings ?? this.ongoingBookings,
// //       pastBookings: pastBookings ?? this.pastBookings,
// //       newBookings: newBookings ?? this.newBookings,
// //       cancelledBookings: cancelledBookings ?? this.cancelledBookings,
// //       confirmedBookings: confirmedBookings ?? this.confirmedBookings,
// //       rejectedBookings: rejectedBookings ?? this.rejectedBookings,
// //       isLoading: isLoading ?? this.isLoading,
// //     );
// //   }

// //   @override
// //   List<Object?> get props => [
// //         myBooking,
// //         upcomingBookings,
// //         ongoingBookings,
// //         pastBookings,
// //         newBookings,
// //         cancelledBookings,
// //         confirmedBookings,
// //         rejectedBookings,
// //         isLoading,
// //       ];
// // }

// // class SavedPostsData extends Equatable {
// //   final List<Post> savedPosts;
// //   final bool isLoading;

// //   const SavedPostsData({
// //     required this.savedPosts,
// //     this.isLoading = false,
// //   });

// //   bool get hasSavedPosts => savedPosts.isNotEmpty;

// //   factory SavedPostsData.empty() {
// //     return const SavedPostsData(savedPosts: []);
// //   }

// //   SavedPostsData copyWith({
// //     List<Post>? savedPosts,
// //     bool? isLoading,
// //   }) {
// //     return SavedPostsData(
// //       savedPosts: savedPosts ?? this.savedPosts,
// //       isLoading: isLoading ?? this.isLoading,
// //     );
// //   }

// //   @override
// //   List<Object?> get props => [savedPosts, isLoading];
// // }

// // /// BLOC
// // class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
// //   final GetAllBookingsByUserIdUseCase _getAllBookingsByUserIdUseCase;
// //   final GetAllBookingRelatedToOrganizationUseCase
// //       _getAllBookingRelatedToOrganizationUseCase;
// //   final UpdateBookingStatusByIdUseCase _updateBookingStatusByIdUseCase;
// //   final GetAllSavedPostsUseCase _getAllSavedPostsUseCase;

// //   LibraryBloc({
// //     required GetAllBookingsByUserIdUseCase getAllBookingsByUserIdUseCase,
// //     required GetAllBookingRelatedToOrganizationUseCase
// //         getAllBookingRelatedToOrganizationUseCase,
// //     required UpdateBookingStatusByIdUseCase updateBookingStatusByIdUseCase,
// //     required GetAllSavedPostsUseCase getAllSavedPostsUseCase,
// //   })  : _getAllBookingsByUserIdUseCase = getAllBookingsByUserIdUseCase,
// //         _getAllBookingRelatedToOrganizationUseCase =
// //             getAllBookingRelatedToOrganizationUseCase,
// //         _updateBookingStatusByIdUseCase = updateBookingStatusByIdUseCase,
// //         _getAllSavedPostsUseCase = getAllSavedPostsUseCase,
// //         super(const LibraryInitial()) {
// //     on<LoadUserLibrary>(_onLoadUserLibrary);
// //     on<RefreshUserLibrary>(_onRefreshUserLibrary);
// //     on<ChangeLibraryFilterTabRequested>(_onChangeFilter);
// //     on<UpdateBookingStatusFromLibraryPage>(
// //       _onUpdateBookingStatusFromLibraryPage,
// //     );
// //   }

// //   Future<void> _onLoadUserLibrary(
// //     LoadUserLibrary event,
// //     Emitter<LibraryState> emit,
// //   ) async {
// //     final previousFilter =
// //         state is LibraryLoaded ? (state as LibraryLoaded).activeFilter : null;
// //     emit(const LibraryLoading());

// //     // Load both bookings and saved posts in parallel
// //     final results = await Future.wait([
// //       _loadBookingsData(event.userId, event.organizationId),
// //       _loadSavedPostsData(event.userId),
// //     ]);

// //     final bookingsResult = results[0] as ({BookingsData? data, String? error});
// //     final savedPostsResult =
// //         results[1] as ({SavedPostsData? data, String? error});

// //     // Handle errors
// //     if (bookingsResult.error != null) {
// //       emit(LibraryError(message: bookingsResult.error!));
// //       return;
// //     }

// //     if (savedPostsResult.error != null) {
// //       emit(LibraryError(message: savedPostsResult.error!));
// //       return;
// //     }

// //     emit(
// //       LibraryLoaded(
// //         activeFilter: previousFilter ?? LibraryFilter.all,
// //         bookingsData: bookingsResult.data ?? BookingsData.empty(),
// //         savedPostsData: savedPostsResult.data ?? SavedPostsData.empty(),
// //       ),
// //     );
// //   }

// //   Future<void> _onRefreshUserLibrary(
// //     RefreshUserLibrary event,
// //     Emitter<LibraryState> emit,
// //   ) async {
// //     if (state is LibraryRefreshing) return;

// //     if (state is LibraryLoaded && state is! LibraryRefreshing) {
// //       final currentState = state as LibraryLoaded;
// //       emit(
// //         LibraryRefreshing(
// //           activeFilter: currentState.activeFilter,
// //           bookingsData: currentState.bookingsData,
// //           savedPostsData: currentState.savedPostsData,
// //         ),
// //       );
// //     }

// //     final previousFilter =
// //         state is LibraryLoaded ? (state as LibraryLoaded).activeFilter : null;

// //     // Load both bookings and saved posts in parallel
// //     final results = await Future.wait([
// //       _loadBookingsData(event.userId, event.organizationId),
// //       _loadSavedPostsData(event.userId),
// //     ]);

// //     final bookingsResult = results[0] as ({BookingsData? data, String? error});
// //     final savedPostsResult =
// //         results[1] as ({SavedPostsData? data, String? error});

// //     // Handle errors
// //     if (bookingsResult.error != null) {
// //       emit(LibraryError(message: bookingsResult.error!));
// //       return;
// //     }

// //     if (savedPostsResult.error != null) {
// //       emit(LibraryError(message: savedPostsResult.error!));
// //       return;
// //     }

// //     emit(
// //       LibraryLoaded(
// //         activeFilter: previousFilter ?? LibraryFilter.all,
// //         bookingsData: bookingsResult.data ?? BookingsData.empty(),
// //         savedPostsData: savedPostsResult.data ?? SavedPostsData.empty(),
// //       ),
// //     );
// //   }

// //   void _onChangeFilter(
// //     ChangeLibraryFilterTabRequested event,
// //     Emitter<LibraryState> emit,
// //   ) {
// //     if (state is! LibraryLoaded) return;

// //     final current = state as LibraryLoaded;
// //     emit(current.copyWith(activeFilter: event.filter));
// //   }

// //   Future<void> _onUpdateBookingStatusFromLibraryPage(
// //     UpdateBookingStatusFromLibraryPage event,
// //     Emitter<LibraryState> emit,
// //   ) async {
// //     try {
// //       if (state is! LibraryLoaded) return;

// //       final currentState = state as LibraryLoaded;

// //       // Set loading state for bookings
// //       emit(
// //         currentState.copyWith(
// //           bookingsData: currentState.bookingsData.copyWith(isLoading: true),
// //         ),
// //       );

// //       final updateBookingStatusParams = UpdateBookingStatusByIdParams(
// //         bookingId: event.bookingId,
// //         status: event.status,
// //       );

// //       final response = await _updateBookingStatusByIdUseCase(
// //         updateBookingStatusParams,
// //       );

// //       response.fold(
// //         (failure) {
// //           emit(
// //             currentState.copyWith(
// //               bookingsData: currentState.bookingsData.copyWith(
// //                 isLoading: false,
// //               ),
// //             ),
// //           );
// //           emit(LibraryError(message: failure.message));
// //         },
// //         (updatedBooking) {
// //           List<Booking> updateList(List<Booking> list) {
// //             return list
// //                 .map((b) => b.id == updatedBooking.id ? updatedBooking : b)
// //                 .toList();
// //           }

// //           final updatedBookingsData = currentState.bookingsData.copyWith(
// //             myBooking: updateList(currentState.bookingsData.myBooking),
// //             upcomingBookings:
// //                 updateList(currentState.bookingsData.upcomingBookings),
// //             ongoingBookings:
// //                 updateList(currentState.bookingsData.ongoingBookings),
// //             pastBookings: updateList(currentState.bookingsData.pastBookings),
// //             newBookings: updateList(currentState.bookingsData.newBookings),
// //             cancelledBookings:
// //                 updateList(currentState.bookingsData.cancelledBookings),
// //             confirmedBookings:
// //                 updateList(currentState.bookingsData.confirmedBookings),
// //             rejectedBookings:
// //                 updateList(currentState.bookingsData.rejectedBookings),
// //             isLoading: false,
// //           );

// //           emit(currentState.copyWith(bookingsData: updatedBookingsData));
// //         },
// //       );
// //     } catch (e) {
// //       if (state is LibraryLoaded) {
// //         final currentState = state as LibraryLoaded;
// //         emit(
// //           currentState.copyWith(
// //             bookingsData: currentState.bookingsData.copyWith(isLoading: false),
// //           ),
// //         );
// //       }
// //       emit(LibraryError(message: e.toString()));
// //     }
// //   }

// //   /// Helper method to load bookings data
// //   Future<({BookingsData? data, String? error})> _loadBookingsData(
// //     String userId,
// //     String? organizationId,
// //   ) async {
// //     final userBookingsResult = await _getAllBookingsByUserIdUseCase(
// //       GetAllBookingsByUserIdParams(userId: userId),
// //     );

// //     if (organizationId != null) {
// //       final organizationBookingsResult =
// //           await _getAllBookingRelatedToOrganizationUseCase(
// //         GetAllBookingRelatedToOrganizationParams(
// //           organizationId: organizationId,
// //         ),
// //       );

// //       return await userBookingsResult.fold(
// //         (failure) async {
// //           return (data: null, error: _mapFailureToMessage(failure));
// //         },
// //         (userBookings) async {
// //           return await organizationBookingsResult.fold(
// //             (failure) async {
// //               return (data: null, error: _mapFailureToMessage(failure));
// //             },
// //             (organizationBookings) async {
// //               final mergedBookings = _mergeUniqueBookings(
// //                 userBookings,
// //                 organizationBookings,
// //               );

// //               return (
// //                 data: _buildBookingsData(
// //                   mergedBookings,
// //                   userBookings,
// //                   organizationBookings,
// //                 ),
// //                 error: null
// //               );
// //             },
// //           );
// //         },
// //       );
// //     } else {
// //       return await userBookingsResult.fold(
// //         (failure) async {
// //           return (data: null, error: _mapFailureToMessage(failure));
// //         },
// //         (userBookings) async {
// //           return (
// //             data: _buildBookingsData(userBookings, userBookings, []),
// //             error: null
// //           );
// //         },
// //       );
// //     }
// //   }

// //   /// Helper method to load saved posts data
// //   Future<({SavedPostsData? data, String? error})> _loadSavedPostsData(
// //     String userId,
// //   ) async {
// //     final savedPostsResult = await _getAllSavedPostsUseCase(
// //       GetAllSavedPostsParams(userId: userId),
// //     );

// //     return savedPostsResult.fold(
// //       (failure) {
// //         return (data: null, error: _mapFailureToMessage(failure));
// //       },
// //       (savedPosts) {
// //         return (data: SavedPostsData(savedPosts: savedPosts), error: null);
// //       },
// //     );
// //   }

// //   BookingsData _buildBookingsData(
// //     List<Booking> bookings,
// //     List<Booking> myBooking,
// //     List<Booking> newBookings,
// //   ) {
// //     final now = DateTime.now();
// //     final today = DateTime(now.year, now.month, now.day);

// //     final upcoming = bookings
// //         .where(
// //           (b) =>
// //               b.checkInDate.isAfter(
// //                 today.subtract(const Duration(days: 1)),
// //               ) &&
// //               b.status != BookingStatus.cancelled,
// //         )
// //         .toList()
// //       ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

// //     final ongoing = bookings
// //         .where(
// //           (b) =>
// //               b.checkInDate.isBefore(now) &&
// //               b.checkOutDate.isAfter(now) &&
// //               b.status == BookingStatus.confirmed,
// //         )
// //         .toList();

// //     final past = bookings
// //         .where(
// //           (b) =>
// //               b.checkOutDate.isBefore(now) ||
// //               b.status == BookingStatus.cancelled,
// //         )
// //         .toList()
// //       ..sort((a, b) => b.checkOutDate.compareTo(a.checkOutDate));

// //     final cancelledBooking =
// //         bookings.where((b) => b.status == BookingStatus.cancelled).toList();
// //     final confirmedBooking =
// //         bookings.where((b) => b.status == BookingStatus.confirmed).toList();
// //     final rejectedBooking =
// //         bookings.where((b) => b.status == BookingStatus.rejected).toList();

// //     return BookingsData(
// //       upcomingBookings: upcoming,
// //       myBooking: myBooking,
// //       ongoingBookings: ongoing,
// //       pastBookings: past,
// //       newBookings: newBookings,
// //       rejectedBookings: rejectedBooking,
// //       confirmedBookings: confirmedBooking,
// //       cancelledBookings: cancelledBooking,
// //     );
// //   }

// //   String _mapFailureToMessage(Failure failure) {
// //     if (failure is ServerFailure) {
// //       return failure.message;
// //     }
// //     if (failure is NetworkFailure) {
// //       return 'No internet connection';
// //     }
// //     if (failure is CacheFailure) {
// //       return 'Failed to load from cache';
// //     }
// //     return 'Failed to load data. Please try again.';
// //   }

// //   List<Booking> _mergeUniqueBookings(
// //     List<Booking> userBookings,
// //     List<Booking> organizationBookings,
// //   ) {
// //     final map = <String, Booking>{};

// //     for (final booking in userBookings) {
// //       map[booking.id] = booking;
// //     }

// //     for (final booking in organizationBookings) {
// //       map[booking.id] = booking;
// //     }

// //     return map.values.toList();
// //   }
// // }

// import 'dart:async';

// import 'package:app/core/errors/failures.dart';
// import 'package:app/features/booking/domain/entities/booking.dart';
// import 'package:app/features/library/domain/entities/library_filter_enum.dart';
// import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
// import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
// import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
// import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
// import 'package:app/features/post/domain/entities/post.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// /// EVENTS
// abstract class LibraryEvent extends Equatable {
//   const LibraryEvent();

//   @override
//   List<Object?> get props => [];
// }

// class LoadUserLibrary extends LibraryEvent {
//   final String userId;
//   final String? organizationId;

//   const LoadUserLibrary({required this.userId, this.organizationId});

//   @override
//   List<Object?> get props => [userId, organizationId];
// }

// class ChangeLibraryFilterTabRequested extends LibraryEvent {
//   final LibraryFilter filter;

//   const ChangeLibraryFilterTabRequested({required this.filter});

//   @override
//   List<Object> get props => [filter];
// }

// class RefreshUserLibrary extends LibraryEvent {
//   final String userId;
//   final String? organizationId;

//   const RefreshUserLibrary({required this.userId, this.organizationId});

//   @override
//   List<Object?> get props => [userId, organizationId];
// }

// class UpdateBookingStatusFromLibraryPage extends LibraryEvent {
//   final String bookingId;
//   final String status;

//   const UpdateBookingStatusFromLibraryPage({
//     required this.bookingId,
//     required this.status,
//   });

//   @override
//   List<Object> get props => [bookingId, status];
// }

// /// STATES
// abstract class LibraryState extends Equatable {
//   const LibraryState();

//   @override
//   List<Object?> get props => [];
// }

// class LibraryInitial extends LibraryState {
//   const LibraryInitial();
// }

// class LibraryLoading extends LibraryState {
//   const LibraryLoading();
// }

// class LibraryRefreshing extends LibraryLoaded {
//   const LibraryRefreshing({
//     required super.activeFilter,
//     required super.bookingsData,
//     required super.savedPostsData,
//   });

//   @override
//   LibraryRefreshing copyWith({
//     LibraryFilter? activeFilter,
//     BookingsData? bookingsData,
//     SavedPostsData? savedPostsData,
//   }) {
//     return LibraryRefreshing(
//       activeFilter: activeFilter ?? this.activeFilter,
//       bookingsData: bookingsData ?? this.bookingsData,
//       savedPostsData: savedPostsData ?? this.savedPostsData,
//     );
//   }
// }

// class LibraryLoaded extends LibraryState {
//   final LibraryFilter activeFilter;
//   final BookingsData bookingsData;
//   final SavedPostsData savedPostsData;

//   const LibraryLoaded({
//     required this.activeFilter,
//     required this.bookingsData,
//     required this.savedPostsData,
//   });

//   bool get hasContent =>
//       bookingsData.hasBookings || savedPostsData.hasSavedPosts;

//   LibraryLoaded copyWith({
//     LibraryFilter? activeFilter,
//     BookingsData? bookingsData,
//     SavedPostsData? savedPostsData,
//   }) {
//     return LibraryLoaded(
//       activeFilter: activeFilter ?? this.activeFilter,
//       bookingsData: bookingsData ?? this.bookingsData,
//       savedPostsData: savedPostsData ?? this.savedPostsData,
//     );
//   }

//   @override
//   List<Object?> get props => [activeFilter, bookingsData, savedPostsData];
// }

// class LibraryError extends LibraryState {
//   final String message;

//   const LibraryError({required this.message});

//   @override
//   List<Object> get props => [message];
// }

// /// DATA MODELS
// class BookingsData extends Equatable {
//   final List<Booking> myBooking;
//   final List<Booking> upcomingBookings;
//   final List<Booking> ongoingBookings;
//   final List<Booking> pastBookings;
//   final List<Booking> newBookings;
//   final List<Booking> cancelledBookings;
//   final List<Booking> confirmedBookings;
//   final List<Booking> rejectedBookings;
//   final bool isLoading;

//   const BookingsData({
//     required this.myBooking,
//     required this.upcomingBookings,
//     required this.ongoingBookings,
//     required this.pastBookings,
//     required this.newBookings,
//     required this.cancelledBookings,
//     required this.confirmedBookings,
//     required this.rejectedBookings,
//     this.isLoading = false,
//   });

//   bool get hasBookings =>
//       upcomingBookings.isNotEmpty ||
//       ongoingBookings.isNotEmpty ||
//       pastBookings.isNotEmpty ||
//       newBookings.isNotEmpty ||
//       myBooking.isNotEmpty;

//   List<Booking> get allBookings => [
//     ...ongoingBookings,
//     ...upcomingBookings,
//     ...pastBookings,
//   ];

//   factory BookingsData.empty() {
//     return const BookingsData(
//       myBooking: [],
//       upcomingBookings: [],
//       ongoingBookings: [],
//       pastBookings: [],
//       newBookings: [],
//       cancelledBookings: [],
//       confirmedBookings: [],
//       rejectedBookings: [],
//     );
//   }

//   BookingsData copyWith({
//     List<Booking>? myBooking,
//     List<Booking>? upcomingBookings,
//     List<Booking>? ongoingBookings,
//     List<Booking>? pastBookings,
//     List<Booking>? newBookings,
//     List<Booking>? cancelledBookings,
//     List<Booking>? confirmedBookings,
//     List<Booking>? rejectedBookings,
//     bool? isLoading,
//   }) {
//     return BookingsData(
//       myBooking: myBooking ?? this.myBooking,
//       upcomingBookings: upcomingBookings ?? this.upcomingBookings,
//       ongoingBookings: ongoingBookings ?? this.ongoingBookings,
//       pastBookings: pastBookings ?? this.pastBookings,
//       newBookings: newBookings ?? this.newBookings,
//       cancelledBookings: cancelledBookings ?? this.cancelledBookings,
//       confirmedBookings: confirmedBookings ?? this.confirmedBookings,
//       rejectedBookings: rejectedBookings ?? this.rejectedBookings,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     myBooking,
//     upcomingBookings,
//     ongoingBookings,
//     pastBookings,
//     newBookings,
//     cancelledBookings,
//     confirmedBookings,
//     rejectedBookings,
//     isLoading,
//   ];
// }

// class SavedPostsData extends Equatable {
//   final List<Post> savedPosts;
//   final bool isLoading;

//   const SavedPostsData({required this.savedPosts, this.isLoading = false});

//   bool get hasSavedPosts => savedPosts.isNotEmpty;

//   factory SavedPostsData.empty() {
//     return const SavedPostsData(savedPosts: []);
//   }

//   SavedPostsData copyWith({List<Post>? savedPosts, bool? isLoading}) {
//     return SavedPostsData(
//       savedPosts: savedPosts ?? this.savedPosts,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }

//   @override
//   List<Object?> get props => [savedPosts, isLoading];
// }

// /// BLOC
// class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
//   final GetAllBookingsByUserIdUseCase _getAllBookingsByUserIdUseCase;
//   final GetAllBookingRelatedToOrganizationUseCase
//   _getAllBookingRelatedToOrganizationUseCase;
//   final UpdateBookingStatusByIdUseCase _updateBookingStatusByIdUseCase;
//   final GetAllSavedPostsUseCase _getAllSavedPostsUseCase;

//   LibraryBloc({
//     required GetAllBookingsByUserIdUseCase getAllBookingsByUserIdUseCase,
//     required GetAllBookingRelatedToOrganizationUseCase
//     getAllBookingRelatedToOrganizationUseCase,
//     required UpdateBookingStatusByIdUseCase updateBookingStatusByIdUseCase,
//     required GetAllSavedPostsUseCase getAllSavedPostsUseCase,
//   }) : _getAllBookingsByUserIdUseCase = getAllBookingsByUserIdUseCase,
//        _getAllBookingRelatedToOrganizationUseCase =
//            getAllBookingRelatedToOrganizationUseCase,
//        _updateBookingStatusByIdUseCase = updateBookingStatusByIdUseCase,
//        _getAllSavedPostsUseCase = getAllSavedPostsUseCase,
//        super(const LibraryInitial()) {
//     on<LoadUserLibrary>(_onLoadUserLibrary);
//     on<RefreshUserLibrary>(_onRefreshUserLibrary);
//     on<ChangeLibraryFilterTabRequested>(_onChangeFilter);
//     on<UpdateBookingStatusFromLibraryPage>(
//       _onUpdateBookingStatusFromLibraryPage,
//     );
//   }

//   Future<void> _onLoadUserLibrary(
//     LoadUserLibrary event,
//     Emitter<LibraryState> emit,
//   ) async {
//     final previousFilter = state is LibraryLoaded
//         ? (state as LibraryLoaded).activeFilter
//         : null;
//     emit(const LibraryLoading());

//     // Load both bookings and saved posts in parallel
//     final results = await Future.wait([
//       _loadBookingsData(event.userId, event.organizationId),
//       _loadSavedPostsData(event.userId),
//     ]);

//     final bookingsResult = results[0] as ({BookingsData? data, String? error});
//     final savedPostsResult =
//         results[1] as ({SavedPostsData? data, String? error});

//     // Handle errors
//     if (bookingsResult.error != null) {
//       emit(LibraryError(message: bookingsResult.error!));
//       return;
//     }

//     if (savedPostsResult.error != null) {
//       emit(LibraryError(message: savedPostsResult.error!));
//       return;
//     }

//     emit(
//       LibraryLoaded(
//         activeFilter: previousFilter ?? LibraryFilter.all,
//         bookingsData: bookingsResult.data ?? BookingsData.empty(),
//         savedPostsData: savedPostsResult.data ?? SavedPostsData.empty(),
//       ),
//     );
//   }

//   Future<void> _onRefreshUserLibrary(
//     RefreshUserLibrary event,
//     Emitter<LibraryState> emit,
//   ) async {
//     if (state is LibraryRefreshing) return;

//     if (state is LibraryLoaded && state is! LibraryRefreshing) {
//       final currentState = state as LibraryLoaded;
//       emit(
//         LibraryRefreshing(
//           activeFilter: currentState.activeFilter,
//           bookingsData: currentState.bookingsData,
//           savedPostsData: currentState.savedPostsData,
//         ),
//       );
//     }

//     final previousFilter = state is LibraryLoaded
//         ? (state as LibraryLoaded).activeFilter
//         : null;

//     // Load both bookings and saved posts in parallel
//     final results = await Future.wait([
//       _loadBookingsData(event.userId, event.organizationId),
//       _loadSavedPostsData(event.userId),
//     ]);

//     final bookingsResult = results[0] as ({BookingsData? data, String? error});
//     final savedPostsResult =
//         results[1] as ({SavedPostsData? data, String? error});

//     // Handle errors
//     if (bookingsResult.error != null) {
//       emit(LibraryError(message: bookingsResult.error!));
//       return;
//     }

//     if (savedPostsResult.error != null) {
//       emit(LibraryError(message: savedPostsResult.error!));
//       return;
//     }

//     emit(
//       LibraryLoaded(
//         activeFilter: previousFilter ?? LibraryFilter.all,
//         bookingsData: bookingsResult.data ?? BookingsData.empty(),
//         savedPostsData: savedPostsResult.data ?? SavedPostsData.empty(),
//       ),
//     );
//   }

//   void _onChangeFilter(
//     ChangeLibraryFilterTabRequested event,
//     Emitter<LibraryState> emit,
//   ) {
//     if (state is! LibraryLoaded) return;

//     final current = state as LibraryLoaded;
//     emit(current.copyWith(activeFilter: event.filter));
//   }

//   Future<void> _onUpdateBookingStatusFromLibraryPage(
//     UpdateBookingStatusFromLibraryPage event,
//     Emitter<LibraryState> emit,
//   ) async {
//     try {
//       if (state is! LibraryLoaded) return;

//       final currentState = state as LibraryLoaded;

//       // Set loading state for bookings
//       emit(
//         currentState.copyWith(
//           bookingsData: currentState.bookingsData.copyWith(isLoading: true),
//         ),
//       );

//       final updateBookingStatusParams = UpdateBookingStatusByIdParams(
//         bookingId: event.bookingId,
//         status: event.status,
//       );

//       final response = await _updateBookingStatusByIdUseCase(
//         updateBookingStatusParams,
//       );

//       response.fold(
//         (failure) {
//           emit(
//             currentState.copyWith(
//               bookingsData: currentState.bookingsData.copyWith(
//                 isLoading: false,
//               ),
//             ),
//           );
//           emit(LibraryError(message: failure.message));
//         },
//         (updatedBooking) {
//           // Update the booking in all lists
//           List<Booking> updateList(List<Booking> list) {
//             return list
//                 .map((b) => b.id == updatedBooking.id ? updatedBooking : b)
//                 .toList();
//           }

//           // Get all updated lists
//           final updatedMyBooking = updateList(
//             currentState.bookingsData.myBooking,
//           );
//           final updatedUpcoming = updateList(
//             currentState.bookingsData.upcomingBookings,
//           );
//           final updatedOngoing = updateList(
//             currentState.bookingsData.ongoingBookings,
//           );
//           final updatedPast = updateList(
//             currentState.bookingsData.pastBookings,
//           );
//           final updatedNew = updateList(currentState.bookingsData.newBookings);

//           // Merge all bookings to recalculate filtered lists
//           final allBookings = <String, Booking>{};

//           for (final booking in [
//             ...updatedMyBooking,
//             ...updatedUpcoming,
//             ...updatedOngoing,
//             ...updatedPast,
//             ...updatedNew,
//           ]) {
//             allBookings[booking.id] = booking;
//           }

//           final allBookingsList = allBookings.values.toList();

//           // Recalculate status-based filtered lists
//           final cancelledBookings = allBookingsList
//               .where((b) => b.status == BookingStatus.cancelled)
//               .toList();
//           final confirmedBookings = allBookingsList
//               .where((b) => b.status == BookingStatus.confirmed)
//               .toList();
//           final rejectedBookings = allBookingsList
//               .where((b) => b.status == BookingStatus.rejected)
//               .toList();

//           // Recalculate time-based lists to ensure booking moves between categories
//           final now = DateTime.now();
//           final today = DateTime(now.year, now.month, now.day);

//           final recalculatedUpcoming =
//               allBookingsList
//                   .where(
//                     (b) =>
//                         b.checkInDate.isAfter(
//                           today.subtract(const Duration(days: 1)),
//                         ) &&
//                         b.status != BookingStatus.cancelled,
//                   )
//                   .toList()
//                 ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

//           final recalculatedOngoing = allBookingsList
//               .where(
//                 (b) =>
//                     b.checkInDate.isBefore(now) &&
//                     b.checkOutDate.isAfter(now) &&
//                     b.status == BookingStatus.confirmed,
//               )
//               .toList();

//           final recalculatedPast =
//               allBookingsList
//                   .where(
//                     (b) =>
//                         b.checkOutDate.isBefore(now) ||
//                         b.status == BookingStatus.cancelled,
//                   )
//                   .toList()
//                 ..sort((a, b) => b.checkOutDate.compareTo(a.checkOutDate));

//           final updatedBookingsData = currentState.bookingsData.copyWith(
//             myBooking: updatedMyBooking,
//             upcomingBookings: recalculatedUpcoming,
//             ongoingBookings: recalculatedOngoing,
//             pastBookings: recalculatedPast,
//             newBookings: updatedNew,
//             cancelledBookings: cancelledBookings,
//             confirmedBookings: confirmedBookings,
//             rejectedBookings: rejectedBookings,
//             isLoading: false,
//           );

//           emit(currentState.copyWith(bookingsData: updatedBookingsData));
//         },
//       );
//     } catch (e) {
//       if (state is LibraryLoaded) {
//         final currentState = state as LibraryLoaded;
//         emit(
//           currentState.copyWith(
//             bookingsData: currentState.bookingsData.copyWith(isLoading: false),
//           ),
//         );
//       }
//       emit(LibraryError(message: e.toString()));
//     }
//   }

//   /// Helper method to load bookings data
//   Future<({BookingsData? data, String? error})> _loadBookingsData(
//     String userId,
//     String? organizationId,
//   ) async {
//     final userBookingsResult = await _getAllBookingsByUserIdUseCase(
//       GetAllBookingsByUserIdParams(userId: userId),
//     );

//     if (organizationId != null) {
//       final organizationBookingsResult =
//           await _getAllBookingRelatedToOrganizationUseCase(
//             GetAllBookingRelatedToOrganizationParams(
//               organizationId: organizationId,
//             ),
//           );

//       return await userBookingsResult.fold(
//         (failure) async {
//           return (data: null, error: _mapFailureToMessage(failure));
//         },
//         (userBookings) async {
//           return await organizationBookingsResult.fold(
//             (failure) async {
//               return (data: null, error: _mapFailureToMessage(failure));
//             },
//             (organizationBookings) async {
//               final mergedBookings = _mergeUniqueBookings(
//                 userBookings,
//                 organizationBookings,
//               );

//               return (
//                 data: _buildBookingsData(
//                   mergedBookings,
//                   userBookings,
//                   organizationBookings,
//                 ),
//                 error: null,
//               );
//             },
//           );
//         },
//       );
//     } else {
//       return await userBookingsResult.fold(
//         (failure) async {
//           return (data: null, error: _mapFailureToMessage(failure));
//         },
//         (userBookings) async {
//           return (
//             data: _buildBookingsData(userBookings, userBookings, []),
//             error: null,
//           );
//         },
//       );
//     }
//   }

//   /// Helper method to load saved posts data
//   Future<({SavedPostsData? data, String? error})> _loadSavedPostsData(
//     String userId,
//   ) async {
//     final savedPostsResult = await _getAllSavedPostsUseCase(
//       GetAllSavedPostsParams(userId: userId),
//     );

//     return savedPostsResult.fold(
//       (failure) {
//         return (data: null, error: _mapFailureToMessage(failure));
//       },
//       (savedPosts) {
//         return (data: SavedPostsData(savedPosts: savedPosts), error: null);
//       },
//     );
//   }

//   BookingsData _buildBookingsData(
//     List<Booking> bookings,
//     List<Booking> myBooking,
//     List<Booking> newBookings,
//   ) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);

//     final upcoming =
//         bookings
//             .where(
//               (b) =>
//                   b.checkInDate.isAfter(
//                     today.subtract(const Duration(days: 1)),
//                   ) &&
//                   b.status != BookingStatus.cancelled,
//             )
//             .toList()
//           ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

//     final ongoing = bookings
//         .where(
//           (b) =>
//               b.checkInDate.isBefore(now) &&
//               b.checkOutDate.isAfter(now) &&
//               b.status == BookingStatus.confirmed,
//         )
//         .toList();

//     final past =
//         bookings
//             .where(
//               (b) =>
//                   b.checkOutDate.isBefore(now) ||
//                   b.status == BookingStatus.cancelled,
//             )
//             .toList()
//           ..sort((a, b) => b.checkOutDate.compareTo(a.checkOutDate));

//     final cancelledBooking = bookings
//         .where((b) => b.status == BookingStatus.cancelled)
//         .toList();
//     final confirmedBooking = bookings
//         .where((b) => b.status == BookingStatus.confirmed)
//         .toList();
//     final rejectedBooking = bookings
//         .where((b) => b.status == BookingStatus.rejected)
//         .toList();

//     return BookingsData(
//       upcomingBookings: upcoming,
//       myBooking: myBooking,
//       ongoingBookings: ongoing,
//       pastBookings: past,
//       newBookings: newBookings,
//       rejectedBookings: rejectedBooking,
//       confirmedBookings: confirmedBooking,
//       cancelledBookings: cancelledBooking,
//     );
//   }

//   String _mapFailureToMessage(Failure failure) {
//     if (failure is ServerFailure) {
//       return failure.message;
//     }
//     if (failure is NetworkFailure) {
//       return 'No internet connection';
//     }
//     if (failure is CacheFailure) {
//       return 'Failed to load from cache';
//     }
//     return 'Failed to load data. Please try again.';
//   }

//   List<Booking> _mergeUniqueBookings(
//     List<Booking> userBookings,
//     List<Booking> organizationBookings,
//   ) {
//     final map = <String, Booking>{};

//     for (final booking in userBookings) {
//       map[booking.id] = booking;
//     }

//     for (final booking in organizationBookings) {
//       map[booking.id] = booking;
//     }

//     return map.values.toList();
//   }
// }

import 'dart:async';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/entities/library_filter_enum.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
import 'package:app/features/post/domain/entities/post.dart';
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

class UpdateBookingStatusFromLibraryPage extends LibraryEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatusFromLibraryPage({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object> get props => [bookingId, status];
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

class LibraryRefreshing extends LibraryLoaded {
  const LibraryRefreshing({
    required super.activeFilter,
    required super.bookingsData,
    required super.savedPostsData,
  });

  @override
  LibraryRefreshing copyWith({
    LibraryFilter? activeFilter,
    BookingsData? bookingsData,
    SavedPostsData? savedPostsData,
  }) {
    return LibraryRefreshing(
      activeFilter: activeFilter ?? this.activeFilter,
      bookingsData: bookingsData ?? this.bookingsData,
      savedPostsData: savedPostsData ?? this.savedPostsData,
    );
  }
}

class LibraryLoaded extends LibraryState {
  final LibraryFilter activeFilter;
  final BookingsData bookingsData;
  final SavedPostsData savedPostsData;

  const LibraryLoaded({
    required this.activeFilter,
    required this.bookingsData,
    required this.savedPostsData,
  });

  bool get hasContent =>
      bookingsData.hasBookings || savedPostsData.hasSavedPosts;

  LibraryLoaded copyWith({
    LibraryFilter? activeFilter,
    BookingsData? bookingsData,
    SavedPostsData? savedPostsData,
  }) {
    return LibraryLoaded(
      activeFilter: activeFilter ?? this.activeFilter,
      bookingsData: bookingsData ?? this.bookingsData,
      savedPostsData: savedPostsData ?? this.savedPostsData,
    );
  }

  @override
  List<Object?> get props => [activeFilter, bookingsData, savedPostsData];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError({required this.message});

  @override
  List<Object> get props => [message];
}

/// DATA MODELS
class BookingsData extends Equatable {
  final List<Booking> myBooking;
  final List<Booking> upcomingBookings;
  final List<Booking> ongoingBookings;
  final List<Booking> pastBookings;
  final List<Booking> newBookings;
  final List<Booking> cancelledBookings;
  final List<Booking> confirmedBookings;
  final List<Booking> rejectedBookings;
  final String? updatingBookingId;

  const BookingsData({
    required this.myBooking,
    required this.upcomingBookings,
    required this.ongoingBookings,
    required this.pastBookings,
    required this.newBookings,
    required this.cancelledBookings,
    required this.confirmedBookings,
    required this.rejectedBookings,
    this.updatingBookingId,
  });

  bool get hasBookings =>
      upcomingBookings.isNotEmpty ||
      ongoingBookings.isNotEmpty ||
      pastBookings.isNotEmpty ||
      newBookings.isNotEmpty ||
      myBooking.isNotEmpty;

  List<Booking> get allBookings => [
    ...ongoingBookings,
    ...upcomingBookings,
    ...pastBookings,
  ];

  bool isBookingUpdating(String bookingId) => updatingBookingId == bookingId;

  factory BookingsData.empty() {
    return const BookingsData(
      myBooking: [],
      upcomingBookings: [],
      ongoingBookings: [],
      pastBookings: [],
      newBookings: [],
      cancelledBookings: [],
      confirmedBookings: [],
      rejectedBookings: [],
    );
  }

  BookingsData copyWith({
    List<Booking>? myBooking,
    List<Booking>? upcomingBookings,
    List<Booking>? ongoingBookings,
    List<Booking>? pastBookings,
    List<Booking>? newBookings,
    List<Booking>? cancelledBookings,
    List<Booking>? confirmedBookings,
    List<Booking>? rejectedBookings,
    String? updatingBookingId,
    bool clearUpdatingBookingId = false,
  }) {
    return BookingsData(
      myBooking: myBooking ?? this.myBooking,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      ongoingBookings: ongoingBookings ?? this.ongoingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      newBookings: newBookings ?? this.newBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      confirmedBookings: confirmedBookings ?? this.confirmedBookings,
      rejectedBookings: rejectedBookings ?? this.rejectedBookings,
      updatingBookingId: clearUpdatingBookingId
          ? null
          : (updatingBookingId ?? this.updatingBookingId),
    );
  }

  @override
  List<Object?> get props => [
    myBooking,
    upcomingBookings,
    ongoingBookings,
    pastBookings,
    newBookings,
    cancelledBookings,
    confirmedBookings,
    rejectedBookings,
    updatingBookingId,
  ];
}

class SavedPostsData extends Equatable {
  final List<Post> savedPosts;
  final String? updatingPostId;

  const SavedPostsData({required this.savedPosts, this.updatingPostId});

  bool get hasSavedPosts => savedPosts.isNotEmpty;

  bool isPostUpdating(String postId) => updatingPostId == postId;

  factory SavedPostsData.empty() {
    return const SavedPostsData(savedPosts: []);
  }

  SavedPostsData copyWith({
    List<Post>? savedPosts,
    String? updatingPostId,
    bool clearUpdatingPostId = false,
  }) {
    return SavedPostsData(
      savedPosts: savedPosts ?? this.savedPosts,
      updatingPostId: clearUpdatingPostId
          ? null
          : (updatingPostId ?? this.updatingPostId),
    );
  }

  @override
  List<Object?> get props => [savedPosts, updatingPostId];
}

/// BLOC
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetAllBookingsByUserIdUseCase _getAllBookingsByUserIdUseCase;
  final GetAllBookingRelatedToOrganizationUseCase
  _getAllBookingRelatedToOrganizationUseCase;
  final UpdateBookingStatusByIdUseCase _updateBookingStatusByIdUseCase;
  final GetAllSavedPostsUseCase _getAllSavedPostsUseCase;

  LibraryBloc({
    required GetAllBookingsByUserIdUseCase getAllBookingsByUserIdUseCase,
    required GetAllBookingRelatedToOrganizationUseCase
    getAllBookingRelatedToOrganizationUseCase,
    required UpdateBookingStatusByIdUseCase updateBookingStatusByIdUseCase,
    required GetAllSavedPostsUseCase getAllSavedPostsUseCase,
  }) : _getAllBookingsByUserIdUseCase = getAllBookingsByUserIdUseCase,
       _getAllBookingRelatedToOrganizationUseCase =
           getAllBookingRelatedToOrganizationUseCase,
       _updateBookingStatusByIdUseCase = updateBookingStatusByIdUseCase,
       _getAllSavedPostsUseCase = getAllSavedPostsUseCase,
       super(const LibraryInitial()) {
    on<LoadUserLibrary>(_onLoadUserLibrary);
    on<RefreshUserLibrary>(_onRefreshUserLibrary);
    on<ChangeLibraryFilterTabRequested>(_onChangeFilter);
    on<UpdateBookingStatusFromLibraryPage>(
      _onUpdateBookingStatusFromLibraryPage,
    );
  }

  Future<void> _onLoadUserLibrary(
    LoadUserLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    final previousFilter = state is LibraryLoaded
        ? (state as LibraryLoaded).activeFilter
        : null;
    emit(const LibraryLoading());

    // Load both bookings and saved posts in parallel
    final results = await Future.wait([
      _loadBookingsData(event.userId, event.organizationId),
      _loadSavedPostsData(event.userId),
    ]);

    final bookingsResult = results[0] as ({BookingsData? data, String? error});
    final savedPostsResult =
        results[1] as ({SavedPostsData? data, String? error});

    // Handle errors
    if (bookingsResult.error != null) {
      emit(LibraryError(message: bookingsResult.error!));
      return;
    }

    if (savedPostsResult.error != null) {
      emit(LibraryError(message: savedPostsResult.error!));
      return;
    }

    emit(
      LibraryLoaded(
        activeFilter: previousFilter ?? LibraryFilter.all,
        bookingsData: bookingsResult.data ?? BookingsData.empty(),
        savedPostsData: savedPostsResult.data ?? SavedPostsData.empty(),
      ),
    );
  }

  Future<void> _onRefreshUserLibrary(
    RefreshUserLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryRefreshing) return;

    if (state is LibraryLoaded && state is! LibraryRefreshing) {
      final currentState = state as LibraryLoaded;
      emit(
        LibraryRefreshing(
          activeFilter: currentState.activeFilter,
          bookingsData: currentState.bookingsData,
          savedPostsData: currentState.savedPostsData,
        ),
      );
    }

    final previousFilter = state is LibraryLoaded
        ? (state as LibraryLoaded).activeFilter
        : null;

    // Load both bookings and saved posts in parallel
    final results = await Future.wait([
      _loadBookingsData(event.userId, event.organizationId),
      _loadSavedPostsData(event.userId),
    ]);

    final bookingsResult = results[0] as ({BookingsData? data, String? error});
    final savedPostsResult =
        results[1] as ({SavedPostsData? data, String? error});

    // Handle errors
    if (bookingsResult.error != null) {
      emit(LibraryError(message: bookingsResult.error!));
      return;
    }

    if (savedPostsResult.error != null) {
      emit(LibraryError(message: savedPostsResult.error!));
      return;
    }

    emit(
      LibraryLoaded(
        activeFilter: previousFilter ?? LibraryFilter.all,
        bookingsData: bookingsResult.data ?? BookingsData.empty(),
        savedPostsData: savedPostsResult.data ?? SavedPostsData.empty(),
      ),
    );
  }

  void _onChangeFilter(
    ChangeLibraryFilterTabRequested event,
    Emitter<LibraryState> emit,
  ) {
    if (state is! LibraryLoaded) return;

    final current = state as LibraryLoaded;
    emit(current.copyWith(activeFilter: event.filter));
  }

  Future<void> _onUpdateBookingStatusFromLibraryPage(
    UpdateBookingStatusFromLibraryPage event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      if (state is! LibraryLoaded) return;

      final currentState = state as LibraryLoaded;

      // Set loading state for specific booking
      emit(
        currentState.copyWith(
          bookingsData: currentState.bookingsData.copyWith(
            updatingBookingId: event.bookingId,
          ),
        ),
      );

      final updateBookingStatusParams = UpdateBookingStatusByIdParams(
        bookingId: event.bookingId,
        status: event.status,
      );

      final response = await _updateBookingStatusByIdUseCase(
        updateBookingStatusParams,
      );

      response.fold(
        (failure) {
          emit(
            currentState.copyWith(
              bookingsData: currentState.bookingsData.copyWith(
                clearUpdatingBookingId: true,
              ),
            ),
          );
          emit(LibraryError(message: failure.message));
        },
        (updatedBooking) {
          // Update the booking in all lists
          List<Booking> updateList(List<Booking> list) {
            return list
                .map((b) => b.id == updatedBooking.id ? updatedBooking : b)
                .toList();
          }

          // Get all updated lists
          final updatedMyBooking = updateList(
            currentState.bookingsData.myBooking,
          );
          final updatedUpcoming = updateList(
            currentState.bookingsData.upcomingBookings,
          );
          final updatedOngoing = updateList(
            currentState.bookingsData.ongoingBookings,
          );
          final updatedPast = updateList(
            currentState.bookingsData.pastBookings,
          );
          final updatedNew = updateList(currentState.bookingsData.newBookings);

          // Merge all bookings to recalculate filtered lists
          final allBookings = <String, Booking>{};

          for (final booking in [
            ...updatedMyBooking,
            ...updatedUpcoming,
            ...updatedOngoing,
            ...updatedPast,
            ...updatedNew,
          ]) {
            allBookings[booking.id] = booking;
          }

          final allBookingsList = allBookings.values.toList();

          // Recalculate status-based filtered lists
          final cancelledBookings = allBookingsList
              .where((b) => b.status == BookingStatus.cancelled)
              .toList();
          final confirmedBookings = allBookingsList
              .where((b) => b.status == BookingStatus.confirmed)
              .toList();
          final rejectedBookings = allBookingsList
              .where((b) => b.status == BookingStatus.rejected)
              .toList();

          // Recalculate time-based lists to ensure booking moves between categories
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final recalculatedUpcoming =
              allBookingsList
                  .where(
                    (b) =>
                        b.checkInDate.isAfter(
                          today.subtract(const Duration(days: 1)),
                        ) &&
                        b.status != BookingStatus.cancelled,
                  )
                  .toList()
                ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

          final recalculatedOngoing = allBookingsList
              .where(
                (b) =>
                    b.checkInDate.isBefore(now) &&
                    b.checkOutDate.isAfter(now) &&
                    b.status == BookingStatus.confirmed,
              )
              .toList();

          final recalculatedPast =
              allBookingsList
                  .where(
                    (b) =>
                        b.checkOutDate.isBefore(now) ||
                        b.status == BookingStatus.cancelled,
                  )
                  .toList()
                ..sort((a, b) => b.checkOutDate.compareTo(a.checkOutDate));

          final updatedBookingsData = currentState.bookingsData.copyWith(
            myBooking: updatedMyBooking,
            upcomingBookings: recalculatedUpcoming,
            ongoingBookings: recalculatedOngoing,
            pastBookings: recalculatedPast,
            newBookings: updatedNew,
            cancelledBookings: cancelledBookings,
            confirmedBookings: confirmedBookings,
            rejectedBookings: rejectedBookings,
            clearUpdatingBookingId: true,
          );

          emit(currentState.copyWith(bookingsData: updatedBookingsData));
        },
      );
    } catch (e) {
      if (state is LibraryLoaded) {
        final currentState = state as LibraryLoaded;
        emit(
          currentState.copyWith(
            bookingsData: currentState.bookingsData.copyWith(
              clearUpdatingBookingId: true,
            ),
          ),
        );
      }
      emit(LibraryError(message: e.toString()));
    }
  }

  /// Helper method to load bookings data
  Future<({BookingsData? data, String? error})> _loadBookingsData(
    String userId,
    String? organizationId,
  ) async {
    final userBookingsResult = await _getAllBookingsByUserIdUseCase(
      GetAllBookingsByUserIdParams(userId: userId),
    );

    if (organizationId != null) {
      final organizationBookingsResult =
          await _getAllBookingRelatedToOrganizationUseCase(
            GetAllBookingRelatedToOrganizationParams(
              organizationId: organizationId,
            ),
          );

      return await userBookingsResult.fold(
        (failure) async {
          return (data: null, error: _mapFailureToMessage(failure));
        },
        (userBookings) async {
          return await organizationBookingsResult.fold(
            (failure) async {
              return (data: null, error: _mapFailureToMessage(failure));
            },
            (organizationBookings) async {
              final mergedBookings = _mergeUniqueBookings(
                userBookings,
                organizationBookings,
              );

              return (
                data: _buildBookingsData(
                  mergedBookings,
                  userBookings,
                  organizationBookings,
                ),
                error: null,
              );
            },
          );
        },
      );
    } else {
      return await userBookingsResult.fold(
        (failure) async {
          return (data: null, error: _mapFailureToMessage(failure));
        },
        (userBookings) async {
          return (
            data: _buildBookingsData(userBookings, userBookings, []),
            error: null,
          );
        },
      );
    }
  }

  /// Helper method to load saved posts data
  Future<({SavedPostsData? data, String? error})> _loadSavedPostsData(
    String userId,
  ) async {
    final savedPostsResult = await _getAllSavedPostsUseCase(
      GetAllSavedPostsParams(userId: userId),
    );

    return savedPostsResult.fold(
      (failure) {
        return (data: null, error: _mapFailureToMessage(failure));
      },
      (savedPosts) {
        return (data: SavedPostsData(savedPosts: savedPosts), error: null);
      },
    );
  }

  BookingsData _buildBookingsData(
    List<Booking> bookings,
    List<Booking> myBooking,
    List<Booking> newBookings,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming =
        bookings
            .where(
              (b) =>
                  b.checkInDate.isAfter(
                    today.subtract(const Duration(days: 1)),
                  ) &&
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

    final cancelledBooking = bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList();
    final confirmedBooking = bookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList();
    final rejectedBooking = bookings
        .where((b) => b.status == BookingStatus.rejected)
        .toList();

    return BookingsData(
      upcomingBookings: upcoming,
      myBooking: myBooking,
      ongoingBookings: ongoing,
      pastBookings: past,
      newBookings: newBookings,
      rejectedBookings: rejectedBooking,
      confirmedBookings: confirmedBooking,
      cancelledBookings: cancelledBooking,
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
    return 'Failed to load data. Please try again.';
  }

  List<Booking> _mergeUniqueBookings(
    List<Booking> userBookings,
    List<Booking> organizationBookings,
  ) {
    final map = <String, Booking>{};

    for (final booking in userBookings) {
      map[booking.id] = booking;
    }

    for (final booking in organizationBookings) {
      map[booking.id] = booking;
    }

    return map.values.toList();
  }
}
