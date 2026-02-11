import 'package:app/app/dependency_injection.dart';
import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/customer_review/data/models/rating_model.dart';
import 'package:app/features/customer_review/data/models/review_reaction_model.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
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

  // TODO
  // Get the paginated rating list

  Future<void> toggleReaction({
    required String ratingId,
    required String userId,
    required ReviewReactionType reaction,
  });

  Stream<List<ReviewReactionModel>> streamReactions(String ratingId);

  Future<Map<String, int>> getReactionCounts(String ratingId);

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
      // First fetch the post, to get the organization id
      final post = await supabaseClient
          .from('posts')
          .select()
          .eq('id', postId)
          .single();

      final response = await supabaseClient
          .from('ratings')
          .insert(rating.toCreateJson())
          .select()
          .single();

      print(
        'calling througn the $userId, ${post['organization_id']}, and the rating value ${rating.ratingValue}',
      );

      final trigger = await supabaseClient.rpc(
        'rpc_update_rating_score',
        params: {
          'p_user_id': userId,
          'p_org_id': post['organization_id'],
          'p_rating': rating.ratingValue,
        },
      );

      print(trigger);

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
        print('Invalid reference (user or post not found). $e');
        throw core_exceptions.ServerException(
          'Invalid reference (user or post not found). $e',
        );
      }
      // print('the error i am encountering is ::: $e');
      throw core_exceptions.ServerException(
        'Something went wrong. Please try again. $e',
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

  @override
  Future<Map<String, int>> getReactionCounts(String ratingId) async {
    try {
      final data = await supabaseClient
          .from('review_reactions')
          .select('reaction')
          .eq('rating_id', ratingId);

      int likes = 0;
      int dislikes = 0;

      for (final r in data) {
        if (r['reaction'] == 'like') likes++;
        if (r['reaction'] == 'dislike') dislikes++;
      }

      return {'likes': likes, 'dislikes': dislikes};
    } catch (e) {
      throw core_exceptions.ServerException(
        'Failed to get the review reaction count: $e',
      );
    }
  }

  @override
  Stream<List<ReviewReactionModel>> streamReactions(String ratingId) {
    return supabaseClient
        .from('review_reactions')
        .stream(primaryKey: ['id'])
        .eq('rating_id', ratingId)
        .map(
          (data) => data.map((e) => ReviewReactionModel.fromJson(e)).toList(),
        );
  }

  @override
  Future<void> toggleReaction({
    required String ratingId,
    required String userId,
    required ReviewReactionType reaction,
  }) async {
    try {
      // First check if it existing or not
      final existing = await supabaseClient
          .from('review_reactions')
          .select()
          .eq('rating_id', ratingId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // Insert in the table
        await supabaseClient.from('review_reactions').insert({
          'rating_id': ratingId,
          'user_id': userId,
          'reaction': reaction.name,
        });
      } else {
        final existingReaction = existing['reaction'];
        if (existingReaction == reaction.name) {
          // Delete the reaction
          await supabaseClient
              .from('review_reactions')
              .delete()
              .eq('id', existing['id']);
        } else {
          // Update the reaction
          await supabaseClient
              .from('review_reactions')
              .update({
                'reaction': reaction.name,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existing['id']);
        }
      }
    } catch (e) {
      throw core_exceptions.ServerException(
        'Failed to toggle review reaction: $e',
      );
    }
  }
}
