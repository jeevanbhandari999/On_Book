import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/booking/data/models/booking_model.dart'; // reuse if exists
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LibraryRemoteDataSource {
  // Get user booking lists
  Future<List<BookingModel>> getUserBookings(String userId);

  // Get all booking related to the organization
  Future<List<BookingModel>> getAllBookingsRelatedToOrganization(
    String organizationId,
  );

  // Update the booking status
  Future<BookingModel> updateBookingStatus(String bookingId, String status);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final SupabaseClient supabaseClient;

  LibraryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await supabaseClient
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;

      // print('The user response is : ${response.length}');

      return data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Failed to fetch user bookings: $e');
    }
  }

  @override
  Future<List<BookingModel>> getAllBookingsRelatedToOrganization(
    String organizationId,
  ) async {
    try {
      final response = await supabaseClient
          .from('bookings')
          .select()
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      // print('The organization response is : ${response.length}');

      return data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Failed to fetch organization bookings: $e');
    }
  }

  @override
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final response = await supabaseClient
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId)
          .select()
          .single();
      // print('the response is : $response');
      return BookingModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Failed to update user bookings: $e');
    }
  }
}
