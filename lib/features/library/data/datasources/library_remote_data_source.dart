import 'package:app/app/dependency_injection.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/booking/data/models/booking_model.dart'; // reuse if exists
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/home/data/models/saved_post_model.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LibraryRemoteDataSource {
  // Get user booking lists
  Future<List<BookingModel>> getUserBookings(String userId);

  // Get all booking related to the organization(All bookings),
  Future<List<BookingModel>> getAllBookingsRelatedToOrganization(
    String organizationId,
  );

  // Update the booking status
  Future<BookingModel> updateBookingStatus(String bookingId, String status);

  // GEt all saved posts
  Future<List<PostModel>> getAllSavedPosts(String userId);
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

      final bookingModel = BookingModel.fromJson(response);

      if ((enumFromString(BookingStatus.values, status) ==
              BookingStatus.cancelled) ||
          (enumFromString(BookingStatus.values, status) ==
              BookingStatus.rejected)) {
        // Update the post status , back to the available
        final postDependency = DependencyInjection.get<PostRepository>();
        await postDependency.updatePostStatus(
          postId: bookingModel.postId!,
          status: PostStatus.available.name,
        );
      }
      // print('the response is : $response');
      return BookingModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Failed to update user bookings: $e');
    }
  }

  @override
  Future<List<PostModel>> getAllSavedPosts(String userId) async {
    try {
      //get saved post records
      final savedResponse = await supabaseClient
          .from('user_saved_posts')
          .select()
          .eq('user_id', userId);

      final savedList = (savedResponse as List)
          .map((e) => SavedPostModel.fromJson(e))
          .toList();

      if (savedList.isEmpty) return [];

      // extract post ids
      final postIds = savedList.map((e) => e.postId).toList();

      // fetch posts using IN query
      final postResponse = await supabaseClient
          .from('posts')
          .select()
          .inFilter('id', postIds); // supabase in query

      final posts = (postResponse as List)
          .map((e) => PostModel.fromJson(e))
          .toList();

      return posts;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Failed to fetch saved posts: $e');
    }
  }
}
