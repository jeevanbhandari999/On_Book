import 'package:app/app/dependency_injection.dart';
import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingRemoteDataSource {
  /// Create a new booking
  Future<BookingModel> createBooking(BookingModel booking, String postId);

  /// Get a specific booking by Id
  Future<BookingModel> getBookingById(String bookingId);

  /// Update an existing booking
  Future<BookingModel> updateBooking(String bookingId, BookingModel booking);
  Future<bool> isOwnerLogin(String userId, String organizationId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final SupabaseClient supabaseClient;

  const BookingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<BookingModel> createBooking(
    BookingModel booking,
    String postId,
  ) async {
    try {
      final response = await supabaseClient
          .from('bookings')
          .insert(booking.toCreateJson())
          .select()
          .single();

      // After booking created then update the post (hotel rooms), for now let's just make availabel to booked later we will handle the number of available rooms
      final postDependency = DependencyInjection.get<PostRepository>();
      await postDependency.updatePostStatus(
        postId: postId,
        status: PostStatus.booked.name,
      );
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

  @override
  Future<bool> isOwnerLogin(String userId, String bookingId) async {
    try {
      final user = await supabaseClient
          .from('users')
          .select('role, organization_id')
          .eq('user_id', userId)
          .single();

      final role = user['role'] as String?;
      final userOrgId = user['organization_id'] as String?;

      // Admin can manage all bookings
      if (role == 'admin') return true;

      final booking = await supabaseClient
          .from('bookings')
          .select('organization_id')
          .eq('id', bookingId)
          .single();

      final bookingOrgId = booking['organization_id'] as String?;

      // Owner / Manager can manage bookings in their org
      return bookingOrgId == userOrgId;
    } catch (e) {
      throw core_exceptions.ServerException(
        'Failed to check booking permissions: $e',
      );
    }
  }
}
