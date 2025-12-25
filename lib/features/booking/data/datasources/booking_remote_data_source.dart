import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingRemoteDataSource {
  /// Create a new booking
  Future<BookingModel> createBooking(BookingModel booking);

  /// Get a specific booking by Id
  Future<BookingModel> getBookingById(String bookingId);

  /// Update an existing booking
  Future<BookingModel> updateBooking(String bookingId, BookingModel booking);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final SupabaseClient supabaseClient;

  const BookingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await supabaseClient
          .from('bookings')
          .insert(booking.toCreateJson())
          .select()
          .single();

      // After booking created then update the post (hotel rooms), for now let's just make availabel to booked later we will handle the number of available rooms
      
      return BookingModel.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Failed to create booking: $e');
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final response = await supabaseClient
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Failed to fetch booking: $e');
    }
  }

  @override
  Future<BookingModel> updateBooking(
    String bookingId,
    BookingModel booking,
  ) async {
    try {
      final response = await supabaseClient
          .from('bookings')
          .update(booking.toUpdateJson())
          .eq('id', bookingId)
          .select()
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Failed to update booking: $e');
    }
  }
}
