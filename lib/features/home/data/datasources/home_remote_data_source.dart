import 'package:app/core/errors/exceptions.dart' as core_exceptions;
import 'package:app/core/errors/failures.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDataSource {
  // Get all posts near user
  Future<Either<Failure, ({List<PostModel> posts, String? nextCursor})>>
  getNearByPosts({
    required String useerId,
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
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  const HomeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, ({String? nextCursor, List<PostModel> posts})>>
  getNearByPosts({
    required String useerId,
    double? latitude,
    double? longitude,
    int limit = 15,
    String? cursor,
  }) async {
    try {
      if (latitude == null || longitude == null) {
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

      final query = supabaseClient
          .from('posts')
          .select(''' 
              *,
              distance: ST_Distance(
                location::geography, 
                ST_MakePoint($longitude, $latitude)::geography
              )
            ''')
          .order('distance', ascending: true)
          // here distance is come from distance: ST_Distance(
          //   location::geography,
          //   ST_MakePoint($longitude, $latitude)::geography
          // )
          // which creates a virtual distance field that you can order by.
          .order('created_at', ascending: false)
          .limit(limit + 1);
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
    } catch (e) {
      throw core_exceptions.ServerException('Failed to get the posts: $e');
    }
  }

  @override
  Future<Either<Failure, List<PostModel>>> getRecommendedPosts({
    required String userId,
    int limit = 15,
  }) {
    // TODO: implement getRecommendedPosts
    throw UnimplementedError();
  }
}
