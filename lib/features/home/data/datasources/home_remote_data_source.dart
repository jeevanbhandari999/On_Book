import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/home/data/models/saved_post_model.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDataSource {
  // Get all posts near user
  Future<Either<Failure, ({List<PostModel> posts, String? nextCursor})>>
  getNearByPosts({
    required String userId,
    double? latitude,
    double? longitude,
    int limit = 15,
    String? cursor,
  });

  // Get the recommendation (content based or AI whatever)
  // TODO
  Future<Either<Failure, List<PostModel>>> getRecommendedPosts({
    required String userId,
    int limit = 15,
  });

  // Get the organization detail by post id
  Future<Either<Failure, OrganizationModel>>
  getOrganizationDetailByPostOrganizationId(String organizationId);

  // Get the most rated organizations according to the user ratings and the others
  Future<Either<Failure, List<OrganizationModel>>>
  getOrganizationsBasedOnUserAndOthersPreferences({String? userId});

  // Save the post by users
  Future<void> togglePostSaveOrUnsave(
    String userId,
    String postId,
    String organizationId,
  );

  // For real time updates
  Stream<List<SavedPostModel>> streamSavedPosts(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  const HomeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, ({String? nextCursor, List<PostModel> posts})>>
  getNearByPosts({
    required String userId,
    double? latitude,
    double? longitude,
    int limit = 15,
    String? cursor,
  }) async {
    // print('$latitude $longitude $cursor');
    // try {
    //   if (latitude == null || longitude == null) {
    //     final response = await supabaseClient
    //         .from('posts')
    //         .select('''
    //         *,
    //         post_images (
    //           id,
    //           post_id,
    //           image_url,
    //           uploaded_by,
    //           updated_by,
    //           created_at,
    //           updated_at
    //         )
    //       ''')
    //         .order('created_at', ascending: true);

    //     // if (cursor != null) {
    //     //   query = supabaseClient
    //     //       .from('posts')
    //     //       .select('*')
    //     //       .lt('created_at', cursor)
    //     //       .limit(limit + 1);
    //     // }

    //     // final response = await query;

    //     final data = response as List<dynamic>;

    //     final posts = data.map((json) => PostModel.fromJson(json)).toList();

    //     print(posts);

    //     String? nextCursor;
    //     if (posts.length > limit) {
    //       posts.removeLast();
    //       nextCursor = posts.last.createdAt.toIso8601String();
    //     }

    //     return Right((posts: posts, nextCursor: nextCursor));
    //   }

    //   final query = supabaseClient
    //       .from('posts')
    //       .select(
    //         '*,distance:ST_Distance(location::geography,ST_MakePoint($longitude,$latitude)::geography)',
    //       )
    //       .order('distance', ascending: true)
    //       // here distance is come from distance: ST_Distance(
    //       //   location::geography,
    //       //   ST_MakePoint($longitude, $latitude)::geography
    //       // )
    //       // which creates a virtual distance field that you can order by.
    //       .order('created_at', ascending: false)
    //       .limit(limit + 1);
    //   final response = await query;

    //   final posts = (response as List)
    //       .map((json) => PostModel.fromJson(json))
    //       .toList();

    //   String? nextCursor;
    //   if (posts.length > limit) {
    //     posts.removeLast();
    //     nextCursor = posts.last.createdAt.toIso8601String();
    //   }

    //   return Right((posts: posts, nextCursor: nextCursor));
    // } catch (e) {
    //   throw core_exceptions.ServerException('Failed to get the posts: $e');
    // }

    try {
      if (latitude == null || longitude == null) {
        // // Fallback: newest posts
        // var query = supabaseClient
        //     .from('posts')
        //     .select()
        //     .eq('status', 'available')
        //     .order('created_at', ascending: false)
        //     .limit(limit + 1);

        // if (cursor != null) {
        //   query = supabaseClient
        //       .from('posts')
        //       .select()
        //       .eq('status', 'available')
        //       // .lt('created_at', cursor)
        //       .order('created_at', ascending: false)
        //       .limit(limit + 1); // Add to existing query
        // }
        var query = supabaseClient.from('posts').select().limit(limit + 1);
        if (cursor != null) {
          query = supabaseClient
              .from('posts')
              .select()
              .lt('created_at', cursor)
              .limit(limit + 1);
        }
        final response = await query;
        final posts = (response as List)
            .map((json) => PostModel.fromJson(json))
            .toList();

        String? nextCursor;
        if (posts.length > limit) {
          posts.removeLast();
          nextCursor = posts.last.createdAt.toIso8601String();
        }

        return Right((posts: posts, nextCursor: nextCursor));
      }

      // With location: use RPC
      final cursorDate = cursor != null ? DateTime.parse(cursor).toUtc() : null;

      final response = await supabaseClient.rpc(
        'get_nearby_posts',
        params: {
          'p_lat': latitude,
          'p_lng': longitude,
          'p_limit': limit,
          'p_cursor': cursorDate?.toIso8601String(),
        },
      );

      // Assuming the response is a list of rows as the function returns a table.
      final List<dynamic> data = response as List;

      // Convert the response to a list of PostModel objects
      final List<PostModel> posts = data
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Extract the nextCursor, which is the `created_at` value of the last post.
      String? nextCursor;
      if (posts.isNotEmpty) {
        nextCursor = posts.last.createdAt
            .toIso8601String(); // Use the created_at timestamp as the cursor
      }

      return Right((posts: posts, nextCursor: nextCursor));
      // return Right((posts: [], nextCursor: 'nextCursor'));
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Supabase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to load posts: $e'));
    }

    // try {
    //   final response = await supabaseClient
    //       .from('posts')
    //       .select('''
    //         *,
    //         post_images (
    //           id,
    //           post_id,
    //           image_url,
    //           uploaded_by,
    //           updated_by,
    //           created_at,
    //           updated_at
    //         )
    //       ''')
    //       .order('created_at', ascending: true);

    //   final data = response as List<dynamic>;
    //   final posts = data
    //       .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
    //       .toList();
    //   return Right((posts: posts, nextCursor: 'nextCursor'));
    // } catch (e) {
    //   throw core_exceptions.ServerException('Failed to fetch posts: $e');
    // }
  }

  @override
  Future<Either<Failure, List<PostModel>>> getRecommendedPosts({
    required String userId,
    int limit = 15,
  }) {
    // TODO: implement getRecommendedPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, OrganizationModel>>
  getOrganizationDetailByPostOrganizationId(String organizationId) async {
    try {
      final organizationResponse = await supabaseClient
          .from('organizations')
          .select()
          .eq('id', organizationId)
          .single();
      final organizationModel = OrganizationModel.fromJson(
        organizationResponse,
      );
      return Right(organizationModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrganizationModel>>>
  getOrganizationsBasedOnUserAndOthersPreferences({String? userId}) async {
    try {
      // Fetch from Supabase
      final response = await supabaseClient
          .from('organizations')
          .select(
            'id, name, logo_url, address, phone, longitude, latitude, created_by, created_at, updated_at, org_global_scores(total_score)',
          )
          .limit(10);
      if ((response.isEmpty)) {
        return const Right([]);
      }

      final List data = response as List;

      // Sort by total_score from org_global_scores if exists
      data.sort((a, b) {
        final scoreA = a['org_global_scores']?['total_score'] ?? 0;
        final scoreB = b['org_global_scores']?['total_score'] ?? 0;
        return scoreB.compareTo(scoreA);
      });

      // Convert to OrganizationModel
      final organizations = data
          .map<OrganizationModel>((json) => OrganizationModel.fromJson(json))
          .toList();

      return Right(organizations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> togglePostSaveOrUnsave(
    String userId,
    String postId,
    String organizationId,
  ) async {
    try {
      // First check if it existing or not
      final existing = await supabaseClient
          .from('user_saved_posts')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .eq('organization_id', organizationId)
          .maybeSingle();
      if (existing == null) {
        // Insert in the table
        await supabaseClient.from('user_saved_posts').insert({
          'user_id': userId,
          'post_id': postId,
          'organization_id': organizationId,
        });

        // TODO, for algorithm
      } else {
        // Delete the data from the table
        // TODO, for algorithm
        await supabaseClient
            .from('user_saved_posts')
            .delete()
            .eq('id', existing['id']);
      }
    } catch (e) {
      print(e);
      throw core_exceptions.ServerException(
        'Failed to toggle post save or unsave: $e',
      );
    }
  }

  @override
  Stream<List<SavedPostModel>> streamSavedPosts(String userId) {
    try {
      return supabaseClient
          .from('user_saved_posts')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map((rows) => rows.map(SavedPostModel.fromJson).toList());
    } catch (e) {
      print(e);
      throw core_exceptions.ServerException(
        'Failed to stream post save or unsave: $e',
      );
    }
  }
}
