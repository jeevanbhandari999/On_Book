import 'dart:math';

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

  Future<Either<Failure, List<PostModel>>> getRecommendedPosts({
    required String userId,
    int limit = 15,
    double? latitude,
    double? longitude,
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
    try {
      if (latitude == null || longitude == null) {
        // Without location: fetch from posts table directly
        final query = supabaseClient
            .from('posts')
            .select('*, post_images(*)') // Include related images if needed
            .order('created_at', ascending: false)
            .limit(limit + 1);

        if (cursor != null) {
          final lessThan = supabaseClient
              .from('posts')
              .select('*, post_images(*)')
              .lt('created_at', cursor);

          final response = await lessThan.limit(limit + 1);

          final List<PostModel> posts = (response as List)
              .map((json) => PostModel.fromJson(json))
              .toList();

          String? nextCursor;
          if (posts.length > limit) {
            posts.removeLast();
            nextCursor = posts.last.createdAt.toIso8601String();
          }

          return Right((posts: posts, nextCursor: nextCursor));
        }

        final response = await query.limit(limit + 1);

        final List<PostModel> posts = (response as List)
            .map((json) => PostModel.fromJson(json))
            .toList();

        String? nextCursor;
        if (posts.length > limit) {
          posts.removeLast(); // Remove the extra post
          nextCursor = posts.last.createdAt.toIso8601String();
        }

        return Right((posts: posts, nextCursor: nextCursor));
      }

      // With location: use RPC for nearby posts
      final cursorDate = cursor != null ? DateTime.parse(cursor).toUtc() : null;

      final response = await supabaseClient.rpc(
        'get_nearby_posts',
        params: {
          'p_lat': latitude,
          'p_lng': longitude,
          'p_limit': limit + 1,
          'p_cursor': cursorDate?.toIso8601String(),
        },
      );

      final List<dynamic> data = response as List;
      // data.map((d) {
      //   print('the next ${d['title']}');
      // });
      // Convert the response to a list of PostModel objects
      List<PostModel> posts = data
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();

      String? nextCursor;
      if (posts.length > limit) {
        posts.removeLast();
        nextCursor = posts.last.createdAt.toIso8601String();
      }

      return Right((posts: posts, nextCursor: nextCursor));
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Supabase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to load posts: $e'));
    }
  }

  // @override
  // Future<Either<Failure, List<PostModel>>> getRecommendedPosts({
  //   required String userId,
  //   int limit = 15,
  //   double? latitude,
  //   double? longitude,
  // }) async {
  //   try {
  //     // Build interest map
  //     final interestMap = await _buildInterestMap(userId);

  //     final maxFreq = interestMap.isEmpty
  //         ? 1.0
  //         : interestMap.values.reduce((a, b) => a > b ? a : b);

  //     // Fetch content-based candidates
  //     final contentResponse = await supabaseClient
  //         .from('posts')
  //         .select('*, post_images(*)')
  //         .order('created_at', ascending: false)
  //         .limit(limit * 3);

  //     List<Map<String, dynamic>> combined = (contentResponse as List)
  //         .cast<Map<String, dynamic>>();

  //     // If location exists → fetch nearby too
  //     if (latitude != null && longitude != null) {
  //       final nearbyResponse = await supabaseClient.rpc(
  //         'get_nearby_posts',
  //         params: {
  //           'p_lat': latitude,
  //           'p_lng': longitude,
  //           'p_limit': limit * 2,
  //           'p_cursor': null,
  //         },
  //       );

  //       final nearbyList = (nearbyResponse as List)
  //           .cast<Map<String, dynamic>>();

  //       combined.addAll(nearbyList);
  //     }

  //     // Remove duplicates (by post id)
  //     final Map<String, Map<String, dynamic>> uniqueMap = {
  //       for (var post in combined) post['id']: post,
  //     };

  //     final uniquePosts = uniqueMap.values.toList();

  //     // Score posts (content based)
  //     final scored = uniquePosts.map((json) {
  //       final score = _contentScore(
  //         tagsRaw: json['tags'],
  //         amenitiesRaw: json['amenities'],
  //         freq: interestMap,
  //         maxFreq: maxFreq,
  //       );

  //       return MapEntry(json, score);
  //     }).toList()..sort((a, b) => b.value.compareTo(a.value));

  //     // Take top limit
  //     final finalPosts = scored
  //         .take(limit)
  //         .map((e) => PostModel.fromJson(e.key))
  //         .toList();

  //     return Right(finalPosts);
  //   } on PostgrestException catch (e) {
  //     return Left(ServerFailure(e.message));
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  @override
  Future<Either<Failure, List<PostModel>>> getRecommendedPosts({
    required String userId,
    int limit = 15,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final interestMap = await _buildInterestMap(userId);
      final maxFreq = interestMap.isEmpty
          ? 1.0
          : interestMap.values
                .map((v) => v.abs())
                .reduce((a, b) => a > b ? a : b);

      List<Map<String, dynamic>> combined = [];

      // Fetch nearby posts if location available
      if (latitude != null && longitude != null) {
        final nearbyResponse = await supabaseClient.rpc(
          'get_nearby_posts',
          params: {
            'p_lat': latitude,
            'p_lng': longitude,
            'p_limit': limit * 3,
            'p_cursor': null,
          },
        );
        combined.addAll((nearbyResponse as List).cast<Map<String, dynamic>>());
      }

      // Always fetch content-based candidates and merge
      final contentResponse = await supabaseClient
          .from('posts')
          .select('*, post_images(*)')
          .order('created_at', ascending: false)
          .limit(limit * 3);

      combined.addAll((contentResponse as List).cast<Map<String, dynamic>>());

      // Deduplicate by post id
      final Map<String, Map<String, dynamic>> uniqueMap = {
        for (var post in combined) post['id']: post,
      };
      final uniquePosts = uniqueMap.values.toList();

      // Score each post with distance + interest combined
      final scored = uniquePosts.map((json) {
        final double distanceScore = _distanceScore(
          postLat: json['latitude'],
          postLng: json['longitude'],
          userLat: latitude,
          userLng: longitude,
        );

        final double interestScore = _contentScore(
          tagsRaw: json['tags'],
          amenitiesRaw: json['amenities'],
          freq: interestMap,
          maxFreq: maxFreq,
        );

        // If location available: 60% distance + 40% interest
        // If no location: 100% interest
        final double finalScore = latitude != null && longitude != null
            ? (distanceScore * 0.6) + (interestScore * 0.4)
            : interestScore;

        return MapEntry(json, finalScore);
      }).toList()..sort((a, b) => b.value.compareTo(a.value));

      final finalPosts = scored
          .take(limit)
          .map((e) => PostModel.fromJson(e.key))
          .toList();

      return Right(finalPosts);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  double _contentScore({
    required dynamic tagsRaw,
    required dynamic amenitiesRaw,
    required Map<String, double> freq,
    required double maxFreq,
  }) {
    if (freq.isEmpty) return 0;

    final signals = <String>[...?_asList(tagsRaw), ...?_asList(amenitiesRaw)];
    if (signals.isEmpty) return 0;

    double total = 0;
    for (final s in signals) {
      total += (freq[s] ?? 0) / maxFreq;
    }

    return (total / signals.length).clamp(0.0, 1.0);
  }

  List<String>? _asList(dynamic raw) {
    if (raw is List) return raw.whereType<String>().toList();
    return null;
  }

  // For easy implementation
  // Future<Map<String, double>> _buildInterestMap(String userId) async {
  //   try {
  //     final saved = await supabaseClient
  //         .from('user_saved_posts')
  //         .select('posts(tags, amenities)')
  //         .eq('user_id', userId)
  //         .limit(30);

  //     final Map<String, double> freq = {};

  //     void extract(dynamic raw) {
  //       if (raw is List) {
  //         for (final item in raw) {
  //           if (item is String && item.isNotEmpty) {
  //             freq[item] = (freq[item] ?? 0) + 1.0;
  //           }
  //         }
  //       }
  //     }

  //     for (final row in saved as List) {
  //       final post = row['posts'] as Map<String, dynamic>?;
  //       if (post == null) continue;
  //       extract(post['tags']);
  //       extract(post['amenities']);
  //     }

  //     return freq;
  //   } catch (_) {
  //     return {};
  //   }
  // }

  Future<Map<String, double>> _buildInterestMap(String userId) async {
    try {
      final saved = await supabaseClient
          .from('user_saved_posts')
          .select('posts(tags, amenities, organization_id)')
          .eq('user_id', userId)
          .limit(30);

      final rated = await supabaseClient
          .from('ratings')
          .select('rating_value, posts(tags, amenities, organization_id)')
          .eq('user_id', userId)
          .limit(30);

      final orgScores = await supabaseClient
          .from('user_org_scores')
          .select(
            'organization_id, rating_score, like_score, review_score, '
            'visit_score, save_score, booking_score, view_score, total_score',
          )
          .eq('user_id', userId)
          .order('total_score', ascending: false)
          .limit(20);

      final Map<String, double> orgEngagementWeight = {};
      for (final row in orgScores as List) {
        final orgId = row['organization_id'] as String?;
        if (orgId == null) continue;

        final double weight =
            (row['booking_score'] as num? ?? 0) * 1.5 +
            (row['visit_score'] as num? ?? 0) * 1.2 +
            (row['save_score'] as num? ?? 0) * 1.0 +
            (row['rating_score'] as num? ?? 0) * 1.0 +
            (row['review_score'] as num? ?? 0) * 0.8 +
            (row['like_score'] as num? ?? 0) * 0.5 +
            (row['view_score'] as num? ?? 0) * 0.2;

        orgEngagementWeight[orgId] = weight;
      }

      final Map<String, double> freq = {};

      void extract(dynamic raw, double weight) {
        if (raw is List) {
          for (final item in raw) {
            if (item is String && item.isNotEmpty) {
              freq[item] = (freq[item] ?? 0) + weight;
            }
          }
        }
      }

      for (final row in saved as List) {
        final post = row['posts'] as Map<String, dynamic>?;
        if (post == null) continue;
        final orgId = post['organization_id'] as String?;
        final orgBoost = orgId != null
            ? (orgEngagementWeight[orgId] ?? 0) * 0.1
            : 0.0;
        extract(post['tags'], 1.0 + orgBoost);
        extract(post['amenities'], 1.0 + orgBoost);
      }

      for (final row in rated as List) {
        final post = row['posts'] as Map<String, dynamic>?;
        if (post == null) continue;
        final int ratingValue = row['rating_value'] as int? ?? 3;
        final orgId = post['organization_id'] as String?;
        final orgBoost = orgId != null
            ? (orgEngagementWeight[orgId] ?? 0) * 0.1
            : 0.0;

        final double baseWeight = switch (ratingValue) {
          5 => 1.5,
          4 => 1.0,
          3 => 0.2,
          2 => -0.5,
          1 => -1.0,
          _ => 0.0,
        };

        final double finalWeight = baseWeight < 0
            ? baseWeight
            : baseWeight + orgBoost;
        extract(post['tags'], finalWeight);
        extract(post['amenities'], finalWeight);
      }

      final topOrgIds = orgEngagementWeight.entries
          .where((e) => e.value > 0.5)
          .map((e) => e.key)
          .take(10)
          .toList();

      if (topOrgIds.isNotEmpty) {
        final orgPosts = await supabaseClient
            .from('posts')
            .select('tags, amenities, organization_id')
            .inFilter('organization_id', topOrgIds)
            .limit(50);

        for (final row in orgPosts as List) {
          final orgId = row['organization_id'] as String?;
          if (orgId == null) continue;
          final double engagementWeight =
              (orgEngagementWeight[orgId] ?? 0) * 0.15;
          extract(row['tags'], engagementWeight);
          extract(row['amenities'], engagementWeight);
        }
      }

      return freq;
    } catch (_) {
      return {};
    }
  }

  double _distanceScore({
    required dynamic postLat,
    required dynamic postLng,
    required double? userLat,
    required double? userLng,
  }) {
    if (userLat == null || userLng == null) return 0;
    if (postLat == null || postLng == null) return 0;

    try {
      final lat1 = double.parse(postLat.toString());
      final lng1 = double.parse(postLng.toString());

      // Haversine formula to get distance in km
      const R = 6371.0;
      final dLat = _toRad(lat1 - userLat);
      final dLng = _toRad(lng1 - userLng);
      final a =
          sin(dLat / 2) * sin(dLat / 2) +
          cos(_toRad(userLat)) *
              cos(_toRad(lat1)) *
              sin(dLng / 2) *
              sin(dLng / 2);
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      final distanceKm = R * c;

      // Score drops as distance grows:
      // < 1km   → ~1.0  (very close, highest priority)
      // 5km     → ~0.67
      // 10km    → ~0.5
      // 50km    → ~0.17
      // 100km+  → ~0.09 (far, low priority)
      return 1 / (1 + (distanceKm / 5));
    } catch (_) {
      return 0;
    }
  }

  double _toRad(double deg) => deg * (pi / 180);

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
      // print(existing);

      if (existing == null) {
        // Insert in the table
        await supabaseClient.from('user_saved_posts').insert({
          'user_id': userId,
          'post_id': postId,
          'organization_id': organizationId,
        });

        // TODO, for algorithm
      } else {
        // print('deleting');
        // print(existing['id']);
        // Delete the data from the table
        // TODO, for algorithm
        await supabaseClient
            .from('user_saved_posts')
            .delete()
            .eq('id', existing['id']);
        // .select();
        // print(response);
      }
    } catch (e) {
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
      throw core_exceptions.ServerException(
        'Failed to stream post save or unsave: $e',
      );
    }
  }
}
