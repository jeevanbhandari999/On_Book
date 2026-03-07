// import 'package:app/core/errors/failures.dart';
// import 'package:app/features/booking/domain/entities/booking.dart';
// import 'package:app/features/booking/domain/entities/payment_enums.dart';
// import 'package:app/features/booking/domain/repositories/booking_repository.dart';
// import 'package:app/features/post/domain/repositories/post_repository.dart';
// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';

// class CreateBookingUseCase {
//   final BookingRepository bookingRepository;
//   final PostRepository postRepository;

//   CreateBookingUseCase(this.bookingRepository, this.postRepository);

//   Future<Either<Failure, Booking>> call(CreateBookingParams params) async {
//     final errors = params.validate();
//     if (errors.isNotEmpty) {
//       return Left(ValidationFailure(errors.first));
//     }

//     final postResult = await postRepository.getPostById(params.postId);
//     if (postResult.isLeft()) {
//       return postResult.fold((f) => Left(f), (_) => throw Exception());
//     }

//     final post = postResult.getOrElse(() => throw Exception());

//     final imagesResult = await postRepository.getAllSpecificPostImagesByPostId(
//       post.id,
//     );

//     final additionalImageUrls = imagesResult.fold(
//       (failure) => <String>[],
//       (imgs) => imgs.map((e) => e.imageUrl).toList(),
//     );

//     final nights = params.checkOutDate.difference(params.checkInDate).inDays;

//     final totalAmount = post.price! * nights;
//     final now = DateTime.now();

//     final booking = Booking(
//       id: '',
//       postId: post.id,
//       userId: params.userId,
//       ownerId: post.createdBy,
//       organizationId: post.organizationId,

//       /// post snapshot
//       title: post.title,
//       description: post.description,
//       primaryImageUrl: post.primaryImageUrl,
//       additionalImageUrls: additionalImageUrls,
//       youtubeUrl: post.youtubeUrl,
//       price: post.price!,
//       area: post.area,
//       capacity: post.capacity,
//       roomType: post.roomType?.name,
//       amenities: post.amenities?.map((e) => e.name).toList(),
//       tags: post.tags?.map((e) => e.name).toList(),
//       longitude: post.longitude,
//       latitude: post.latitude,

//       /// booking fields
//       checkInDate: params.checkInDate,
//       checkOutDate: params.checkOutDate,
//       nights: nights,
//       totalAmount: totalAmount,
//       status: BookingStatus.pending,
//       paymentStatus: PaymentStatus.pending,
//       paymentMethod: params.paymentMethod ?? PaymentMethod.cash,
//       notes: params.notes,

//       createdAt: now,
//       updatedAt: now,
//     );

//     return bookingRepository.createBooking(booking, params.postId);
//   }
// }

// class CreateBookingParams extends Equatable {
//   final String userId;
//   final String postId;
//   final DateTime checkInDate;
//   final DateTime checkOutDate;
//   final String? notes;
//   final PaymentMethod? paymentMethod;

//   const CreateBookingParams({
//     required this.userId,
//     required this.postId,
//     required this.checkInDate,
//     required this.checkOutDate,
//     this.notes,
//     this.paymentMethod,
//   });

//   @override
//   List<Object?> get props => [
//     userId,
//     postId,
//     checkInDate,
//     checkOutDate,
//     notes,
//     paymentMethod,
//   ];

//   CreateBookingParams copyWith({
//     String? userId,
//     String? postId,
//     DateTime? checkInDate,
//     DateTime? checkOutDate,
//     String? notes,
//     PaymentMethod? paymentMethod,
//   }) {
//     return CreateBookingParams(
//       userId: userId ?? this.userId,
//       postId: postId ?? this.postId,
//       checkInDate: checkInDate ?? this.checkInDate,
//       checkOutDate: checkOutDate ?? this.checkOutDate,
//       notes: notes ?? this.notes,
//       paymentMethod: paymentMethod ?? this.paymentMethod,
//     );
//   }

//   List<String> validate() {
//     final errors = <String>[];

//     if (userId.trim().isEmpty) errors.add('User ID is required');
//     if (postId.trim().isEmpty) errors.add('Post ID is required');

//     if (!checkOutDate.isAfter(checkInDate)) {
//       errors.add('Check-out date must be after check-in date');
//     }

//     return errors;
//   }

//   bool get isValid => validate().isEmpty;
// }

import 'package:app/core/errors/failures.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/entities/payment_enums.dart';
import 'package:app/features/booking/domain/repositories/booking_repository.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CreateBookingUseCase {
  final BookingRepository bookingRepository;
  final PostRepository postRepository;

  CreateBookingUseCase(this.bookingRepository, this.postRepository);

  Future<Either<Failure, Booking>> call(CreateBookingParams params) async {
    final errors = params.validate();
    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors.first));
    }

    final postResult = await postRepository.getPostById(params.postId);
    if (postResult.isLeft()) {
      return postResult.fold((f) => Left(f), (_) => throw Exception());
    }

    final post = postResult.getOrElse(() => throw Exception());

    final imagesResult = await postRepository.getAllSpecificPostImagesByPostId(
      post.id,
    );

    final additionalImageUrls = imagesResult.fold(
      (failure) => <String>[],
      (imgs) => imgs.map((e) => e.imageUrl).toList(),
    );

    final duration = params.checkOutDate.difference(params.checkInDate);
    final isHourly = duration.inHours < 24;

    // For hourly: bill by hours. For nightly: bill by days.
    // Minimum 1 unit in both cases to avoid zero totalAmount.
    final int nights;
    final double totalAmount;

    if (isHourly) {
      // Hourly booking — bill per hour, minimum 1 hour
      final hours = duration.inMinutes < 60
          ? 1
          : (duration.inMinutes / 60).ceil();
      nights = hours; // reuse `nights` field as "hours" for hourly bookings
      // Hourly rate = daily price / 24  (adjust this formula to your business logic)
      final hourlyRate = post.price! / 24;
      totalAmount = hourlyRate * hours;
    } else {
      // Nightly booking — bill per day, minimum 1 night
      final days = duration.inDays < 1 ? 1 : duration.inDays;
      nights = days;
      totalAmount = post.price! * days;
    }

    final now = DateTime.now();

    // For hourly bookings on the same calendar day, push checkOutDate 1 second
    // forward in time so it is still strictly after checkInDate at the DB level.
    // The real fix is to ensure your Supabase constraint compares timestamps,
    // not date-only values — but this guarantees safety either way.
    final safeCheckOut = params.checkOutDate.isAfter(params.checkInDate)
        ? params.checkOutDate
        : params.checkInDate.add(const Duration(seconds: 1));

    final booking = Booking(
      id: '',
      postId: post.id,
      userId: params.userId,
      ownerId: post.createdBy,
      organizationId: post.organizationId,

      /// post snapshot
      title: post.title,
      description: post.description,
      primaryImageUrl: post.primaryImageUrl,
      additionalImageUrls: additionalImageUrls,
      youtubeUrl: post.youtubeUrl,
      price: post.price!,
      area: post.area,
      capacity: post.capacity,
      roomType: post.roomType?.name,
      amenities: post.amenities?.map((e) => e.name).toList(),
      tags: post.tags?.map((e) => e.name).toList(),
      longitude: post.longitude,
      latitude: post.latitude,

      /// booking fields
      checkInDate: params.checkInDate,
      checkOutDate: safeCheckOut,
      nights: nights,
      totalAmount: totalAmount,
      status: BookingStatus.pending,
      paymentStatus: params.paymentStatus,
      paymentMethod: params.paymentMethod ?? PaymentMethod.cash,
      notes: params.notes,
      paymentId: params.paymentId,

      // isHourly: isHourly, // pass this flag so the model/DB knows the type
      createdAt: now,
      updatedAt: now,
    );

    return bookingRepository.createBooking(booking, params.postId);
  }
}

class CreateBookingParams extends Equatable {
  final String userId;
  final String postId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String? notes;
  final PaymentMethod? paymentMethod;
  final String? paymentId;
  final PaymentStatus paymentStatus;

  const CreateBookingParams({
    required this.userId,
    required this.postId,
    required this.checkInDate,
    required this.checkOutDate,
    this.notes,
    this.paymentMethod,
    this.paymentId,
    this.paymentStatus = PaymentStatus.pending,
  });

  @override
  List<Object?> get props => [
    userId,
    postId,
    checkInDate,
    checkOutDate,
    notes,
    paymentMethod,
    paymentStatus,
    paymentId,
  ];

  CreateBookingParams copyWith({
    String? userId,
    String? postId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? notes,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? paymentId,
  }) {
    return CreateBookingParams(
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
    );
  }

  List<String> validate() {
    final errors = <String>[];

    if (userId.trim().isEmpty) errors.add('User ID is required');
    if (postId.trim().isEmpty) errors.add('Post ID is required');

    // Use isAfter — works correctly for both same-day (hourly) and multi-day
    if (!checkOutDate.isAfter(checkInDate)) {
      errors.add('Check-out must be after check-in');
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;
}
