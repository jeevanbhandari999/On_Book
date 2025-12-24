import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/booking/data/models/booking_model.dart'; // reuse if exists
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LibraryRemoteDataSource {
  Future<List<BookingModel>> getUserBookings(String userId);

  Future<List<BookingModel>> getAllBookingsRelatedToOrganization(
    String organizationId,
  );
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
}
