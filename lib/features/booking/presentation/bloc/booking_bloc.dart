import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/usecases/create_booking_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BookingFormEvent extends Equatable {
  const BookingFormEvent();
  @override
  List<Object?> get props => [];
}

class BookingFormInitialized extends BookingFormEvent {
  final String userId;
  final String postId;
  final Booking? existingBooking; // null = create mode, not null = edit mode

  const BookingFormInitialized({
    required this.userId,
    required this.postId,
    this.existingBooking,
  });

  @override
  List<Object?> get props => [userId, postId, existingBooking];
}

class BookingFormCheckInChanged extends BookingFormEvent {
  final DateTime checkInDate;
  const BookingFormCheckInChanged(this.checkInDate);
  @override
  List<Object> get props => [checkInDate];
}

class BookingFormCheckOutChanged extends BookingFormEvent {
  final DateTime checkOutDate;
  const BookingFormCheckOutChanged(this.checkOutDate);
  @override
  List<Object> get props => [checkOutDate];
}

class BookingFormNotesChanged extends BookingFormEvent {
  final String notes;
  const BookingFormNotesChanged(this.notes);
  @override
  List<Object> get props => [notes];
}

class BookingFormStatusChanged extends BookingFormEvent {
  final BookingStatus status;
  const BookingFormStatusChanged(this.status);
  @override
  List<Object> get props => [status];
}

class BookingFormPaymentStatusChanged extends BookingFormEvent {
  final PaymentStatus paymentStatus;
  const BookingFormPaymentStatusChanged(this.paymentStatus);
  @override
  List<Object> get props => [paymentStatus];
}

class BookingFormAdminNotesChanged extends BookingFormEvent {
  final String adminNotes;
  const BookingFormAdminNotesChanged(this.adminNotes);
  @override
  List<Object> get props => [adminNotes];
}

class BookingFormSubmitted extends BookingFormEvent {
  const BookingFormSubmitted();
}

class BookingFormReset extends BookingFormEvent {
  const BookingFormReset();
}

abstract class BookingFormState extends Equatable {
  const BookingFormState();
  @override
  List<Object?> get props => [];
}

class BookingFormInitial extends BookingFormState {
  const BookingFormInitial();
}

class BookingFormLoading extends BookingFormState {
  const BookingFormLoading();
}

class BookingFormReady extends BookingFormState {
  final String userId;
  final String postId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String notes;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? adminNotes;
  final Map<String, String> validationErrors;
  final bool isValid;
  final bool isEditMode;
  final Booking? originalBooking;

  const BookingFormReady({
    required this.userId,
    required this.postId,
    required this.checkInDate,
    required this.checkOutDate,
    this.notes = '',
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.adminNotes,
    this.validationErrors = const {},
    this.isValid = false,
    this.isEditMode = false,
    this.originalBooking,
  });

  int get nights => checkOutDate.difference(checkInDate).inDays;

  BookingFormReady copyWith({
    String? userId,
    String? postId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? notes,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? adminNotes,
    Map<String, String>? validationErrors,
    bool? isValid,
    bool? isEditMode,
    Booking? originalBooking,
  }) {
    return BookingFormReady(
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      adminNotes: adminNotes ?? this.adminNotes,
      validationErrors: validationErrors ?? this.validationErrors,
      isValid: isValid ?? this.isValid,
      isEditMode: isEditMode ?? this.isEditMode,
      originalBooking: originalBooking ?? this.originalBooking,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    postId,
    checkInDate,
    checkOutDate,
    notes,
    status,
    paymentStatus,
    adminNotes,
    validationErrors,
    isValid,
    isEditMode,
    originalBooking,
  ];
}

class BookingFormSubmitting extends BookingFormState {
  const BookingFormSubmitting();
}

class BookingFormSuccess extends BookingFormState {
  final Booking booking;
  final String message;
  final bool wasEdit;

  const BookingFormSuccess({
    required this.booking,
    required this.message,
    this.wasEdit = false,
  });

  @override
  List<Object> get props => [booking, message, wasEdit];
}

class BookingFormError extends BookingFormState {
  final String message;
  final BookingFormReady? previousState;

  const BookingFormError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

class BookingFormBloc extends Bloc<BookingFormEvent, BookingFormState> {
  final CreateBookingUseCase _createBookingUseCase;
  // final UpdateBookingUseCase _updateBookingUseCase; // Add this use case

  BookingFormBloc({
    required CreateBookingUseCase createBookingUseCase,
    // required UpdateBookingUseCase updateBookingUseCase,
  }) : _createBookingUseCase = createBookingUseCase,
       // _updateBookingUseCase = updateBookingUseCase,
       super(const BookingFormInitial()) {
    on<BookingFormInitialized>(_onInitialized);
    on<BookingFormCheckInChanged>(_onCheckInChanged);
    on<BookingFormCheckOutChanged>(_onCheckOutChanged);
    on<BookingFormNotesChanged>(_onNotesChanged);
    on<BookingFormStatusChanged>(_onStatusChanged);
    on<BookingFormPaymentStatusChanged>(_onPaymentStatusChanged);
    on<BookingFormAdminNotesChanged>(_onAdminNotesChanged);
    on<BookingFormSubmitted>(_onSubmitted);
    on<BookingFormReset>(_onReset);
  }

  Future<void> _onInitialized(
    BookingFormInitialized event,
    Emitter<BookingFormState> emit,
  ) async {
    if (event.existingBooking == null) {
      // Create mode
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dayAfter = tomorrow.add(const Duration(days: 2));

      emit(
        BookingFormReady(
          userId: event.userId,
          postId: event.postId,
          checkInDate: tomorrow,
          checkOutDate: dayAfter,
          isEditMode: false,
        ),
      );
    } else {
      // Edit mode
      final booking = event.existingBooking!;
      emit(
        BookingFormReady(
          userId: event.userId,
          postId: event.postId,
          checkInDate: booking.checkInDate,
          checkOutDate: booking.checkOutDate,
          notes: booking.notes ?? '',
          status: booking.status,
          paymentStatus: booking.paymentStatus,
          // adminNotes: booking.adminNotes, // assuming you have this field
          isEditMode: true,
          originalBooking: booking,
        ),
      );
    }
  }

  void _onCheckInChanged(BookingFormCheckInChanged e, Emitter emit) {
    if (state is BookingFormReady) {
      final s = state as BookingFormReady;
      emit(_validate(s.copyWith(checkInDate: e.checkInDate)));
    }
  }

  void _onCheckOutChanged(BookingFormCheckOutChanged e, Emitter emit) {
    if (state is BookingFormReady) {
      final s = state as BookingFormReady;
      emit(_validate(s.copyWith(checkOutDate: e.checkOutDate)));
    }
  }

  void _onNotesChanged(BookingFormNotesChanged e, Emitter emit) {
    if (state is BookingFormReady) {
      final s = state as BookingFormReady;
      emit(_validate(s.copyWith(notes: e.notes)));
    }
  }

  void _onStatusChanged(BookingFormStatusChanged e, Emitter emit) {
    if (state is BookingFormReady) {
      final s = state as BookingFormReady;
      emit(_validate(s.copyWith(status: e.status)));
    }
  }

  void _onPaymentStatusChanged(
    BookingFormPaymentStatusChanged e,
    Emitter emit,
  ) {
    if (state is BookingFormReady) {
      final s = state as BookingFormReady;
      emit(_validate(s.copyWith(paymentStatus: e.paymentStatus)));
    }
  }

  void _onAdminNotesChanged(BookingFormAdminNotesChanged e, Emitter emit) {
    if (state is BookingFormReady) {
      final s = state as BookingFormReady;
      emit(_validate(s.copyWith(adminNotes: e.adminNotes)));
    }
  }

  Future<void> _onSubmitted(
    BookingFormSubmitted event,
    Emitter<BookingFormState> emit,
  ) async {
    final current = state;
    if (current is! BookingFormReady || !current.isValid) return;

    emit(const BookingFormSubmitting());

    try {
      // if (current.isEditMode) {
      //   final original = current.originalBooking!;

      //   final params = UpdateBookingParams(
      //     bookingId: original.id,
      //     status: current.status,
      //     paymentStatus: current.paymentStatus,
      //     adminNotes: current.adminNotes?.trim().isEmpty == true
      //         ? null
      //         : current.adminNotes?.trim(),
      //     updatedBy: current.userId,
      //   );

      //   final result = await _updateBookingUseCase(params);

      //   result.fold(
      //     (failure) => emit(
      //       BookingFormError(message: failure.message ?? 'Update failed'),
      //     ),
      //     (updatedBooking) => emit(
      //       BookingFormSuccess(
      //         booking: updatedBooking,
      //         message: 'Booking updated successfully',
      //         wasEdit: true,
      //       ),
      //     ),
      //   );
      // } else {
      final params = CreateBookingParams(
        userId: current.userId,
        postId: current.postId,
        checkInDate: current.checkInDate,
        checkOutDate: current.checkOutDate,
        notes: current.notes.trim().isEmpty ? null : current.notes.trim(),
      );

      final result = await _createBookingUseCase(params);

      result.fold(
        (failure) => emit(
          BookingFormError(
            message: failure is ValidationFailure
                ? failure.message
                : 'Failed to create booking',
          ),
        ),
        (newBooking) => emit(
          BookingFormSuccess(
            booking: newBooking,
            message: 'Booking created successfully!',
          ),
        ),
      );
      // }
    } catch (e) {
      emit(BookingFormError(message: 'Unexpected error: $e'));
    }
  }

  void _onReset(BookingFormReset e, Emitter emit) {
    emit(const BookingFormInitial());
  }

  BookingFormReady _validate(BookingFormReady state) {
    final errors = <String, String>{};

    if (!state.isEditMode) {
      // Only validate dates/notes on create
      if (!state.checkOutDate.isAfter(state.checkInDate)) {
        errors['dates'] = 'Check-out must be after check-in';
      }

      if (state.checkInDate.isBefore(
        DateTime.now().add(const Duration(days: 1)),
      )) {
        errors['checkIn'] = 'Check-in must be at least tomorrow';
      }
    }

    return state.copyWith(validationErrors: errors, isValid: errors.isEmpty);
  }
}
