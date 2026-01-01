import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/usecases/get_booking_by_id_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BookingDetailsEvent extends Equatable {
  const BookingDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookingDetails extends BookingDetailsEvent {
  final String bookingId;
  final String userId;

  const LoadBookingDetails({required this.bookingId, required this.userId});

  @override
  List<Object?> get props => [bookingId, userId];
}

class BookingImageViewRequested extends BookingDetailsEvent {
  final int index;
  const BookingImageViewRequested(this.index);
}

class BookingFullImageViewRequested extends BookingDetailsEvent {
  final int index;
  const BookingFullImageViewRequested(this.index);
}

class BookingImageViewClosed extends BookingDetailsEvent {
  const BookingImageViewClosed();
}


abstract class BookingDetailsState extends Equatable {
  const BookingDetailsState();

  @override
  List<Object?> get props => [];
}

class BookingDetailsInitial extends BookingDetailsState {}

class BookingDetailsLoading extends BookingDetailsState {}

class BookingDetailsLoaded extends BookingDetailsState {
  final Booking booking;
  final bool canManage;
  final int? viewingImageIndex;
  final bool isViewingImage;

  const BookingDetailsLoaded({
    required this.booking,
    required this.canManage,
    this.viewingImageIndex,
    this.isViewingImage = false,
  });

  List<String> get allImages =>
      [booking.primaryImageUrl, ...booking.additionalImageUrls];

  BookingDetailsLoaded copyWith({
    int? viewingImageIndex,
    bool? isViewingImage,
  }) {
    return BookingDetailsLoaded(
      booking: booking,
      canManage: canManage,
      viewingImageIndex: viewingImageIndex ?? this.viewingImageIndex,
      isViewingImage: isViewingImage ?? this.isViewingImage,
    );
  }

  @override
  List<Object?> get props =>
      [booking, canManage, viewingImageIndex, isViewingImage];
}


class BookingDetailsError extends BookingDetailsState {
  final String message;

  const BookingDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookingDetailsBloc
    extends Bloc<BookingDetailsEvent, BookingDetailsState> {
  final GetBookingByIdUseCase _getBookingByIdUseCase;

  BookingDetailsBloc({required GetBookingByIdUseCase getBookingByIdUseCase})
    : _getBookingByIdUseCase = getBookingByIdUseCase,
      super(BookingDetailsInitial()) {
    on<LoadBookingDetails>(_onLoadBookingDetails);
    on<BookingImageViewRequested>((e, emit) {
  final s = state as BookingDetailsLoaded;
  emit(s.copyWith(viewingImageIndex: e.index));
});

on<BookingFullImageViewRequested>((e, emit) {
  final s = state as BookingDetailsLoaded;
  emit(s.copyWith(
    viewingImageIndex: e.index,
    isViewingImage: true,
  ));
});

on<BookingImageViewClosed>((e, emit) {
  final s = state as BookingDetailsLoaded;
  emit(s.copyWith(isViewingImage: false));
});

  }

  Future<void> _onLoadBookingDetails(
    LoadBookingDetails event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(BookingDetailsLoading());

    final result = await _getBookingByIdUseCase(
      GetBookingByIdParams(bookingId: event.bookingId, userId: event.userId),
    );

    await result.fold(
      (failure) async {
        emit(BookingDetailsError(message: failure.message));
      },
      (booking) async {
        // Permission check (non-blocking, as per your design)
        final permissionResult = await _getBookingByIdUseCase.repository
            .isOwnerLogin(event.userId, booking.id);

        final canManage = permissionResult.fold((_) => false, (value) => value);

        emit(BookingDetailsLoaded(booking: booking, canManage: canManage));
      },
    );
  }
}
