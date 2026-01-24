import 'package:app/app/dependency_injection.dart';
import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/customer_review/data/models/rating_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CustomerReviewRemoteDataSource {
  // Get teh user rating list realated to the specific post
  Future<List<RatingModel>> getUserRatingRelatedToThePost(String postId);

  // Create the rating or save the rating data provided by the user
  Future<RatingModel> createRating(
    String userId,
    String postId,
    RatingModel rating,
  );

  // Update rating data by the user
  Future<RatingModel> updateRating(
    String ratingId,
    String userId,
    RatingModel existingRating,
  );

  // Check whether the logged in user have already rated the post
  Future<bool> isRatingOwnerLoggedIn(String userId);

  // Get the paginated rating list
  // TODO

  // We can add more logic according to our need later on
}

class CustomerReviewRemoteDataSourceImpl
    implements CustomerReviewRemoteDataSource {
  final SupabaseClient supabaseClient;

  const CustomerReviewRemoteDataSourceImpl({required this.supabaseClient});
  @override
  Future<RatingModel> createRating(
    String userId,
    String postId,
    RatingModel rating,
  ) async {
    try {
      final response = await supabaseClient
          .from('ratings')
          .insert(rating.toCreateJson())
          .select()
          .single();

      return RatingModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // You can be more precise by checking the constraint name
        if (e.message.contains('unique_user_post_rating') ||
            e.message.contains('unique') &&
                e.message.contains('user_id') &&
                e.message.contains('post_id')) {
          throw const core_exceptions.ServerException(
            'You have already rated this post.',
          );
        } else {
          throw const core_exceptions.ServerException(
            'This action is not allowed (duplicate entry detected).',
          );
        }
      } else if (e.code == '23503') {
        throw const core_exceptions.ServerException(
          'Invalid reference (user or post not found).',
        );
      }
      throw const core_exceptions.ServerException(
        'Something went wrong. Please try again.',
      );
    } catch (e) {
      throw core_exceptions.ServerException(
        'Failed to create/save user rating data: $e',
      );
    }
  }

  @override
  Future<List<RatingModel>> getUserRatingRelatedToThePost(String postId) async {
    try {
      final response = await supabaseClient
          .from('ratings')
          .select()
          .eq('post_id', postId)
          .order('updated_at', ascending: true);

      final List<dynamic> data = response;
      print(response.first);
      return data
          .map((json) => RatingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw core_exceptions.ServerException(
        'Failed to get all user ratings ralated to the post user rating data: $e',
      );
    }
  }

  @override
  Future<bool> isRatingOwnerLoggedIn(String userId) async {
    try {
      final authService = DependencyInjection.get<AuthService>();
      final currentUser = authService.getCurrentUserId();

      if (currentUser == null) {
        return false;
      }
      return currentUser == userId;
    } catch (e) {
      throw core_exceptions.ServerException('Failed get the current user: $e');
    }
  }

  @override
  Future<RatingModel> updateRating(
    String ratingId,
    String userId,
    RatingModel existingRating,
  ) async {
    try {
      final response = await supabaseClient
          .from('ratings')
          .update(existingRating.toUpdateJson())
          .eq('id', ratingId)
          .select()
          .single();

      return RatingModel.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Failed to update booking: $e');
    }
  }
}
