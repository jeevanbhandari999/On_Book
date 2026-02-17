// ─────────────────────────────────────────────────────────────────
// features/search/data/datasources/search_remote_data_source.dart
// ─────────────────────────────────────────────────────────────────
//
// Content-Based Filtering Algorithm (discovery feed):
//
//  1.  Fetch PostTags & AmenityTypes from posts the user liked / saved
//      → build an interest-frequency map
//  2.  Fetch candidate posts (not by current user, status = available)
//  3.  Score each post:
//        contentScore  = tag-overlap / total-post-tags  (0–1)
//        recencyScore  = fades linearly from 1.0 (now) → 0.0 (30 days)
//        blendedScore  = 0.6 × content + 0.4 × recency
//  4.  Sort descending, take top-N
//  5.  Concurrently fetch suggested users + featured organizations
// ─────────────────────────────────────────────────────────────────

import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/post/data/models/post_model.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/search/domain/entities/search_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as _supabase;

// ── Column selector constants ─────────────────────────────────────

/// All columns needed to hydrate a PostModel (joins post_images)
const _postSelect = '''
  id,
  organization_id,
  title,
  description,
  primary_image_url,
  additional_images:post_images(
    id, post_id, image_url, uploaded_by, updated_by, created_at, updated_at
  ),
  youtube_url,
  video_url,
  longitude,
  latitude,
  price,
  area,
  capacity,
  room_type,
  amenities,
  tags,
  status,
  created_by,
  updated_by,
  created_at,
  updated_at
''';

/// All columns needed to hydrate a UserModel
const _userSelect = '''
  id,
  user_id,
  full_name,
  email,
  image_url,
  role,
  organization_id,
  phone,
  address,
  contacts,
  created_at,
  updated_at
''';

/// All columns needed to hydrate an OrganizationModel
const _orgSelect = '''
  id,
  name,
  logo_url,
  address,
  phone,
  longitude,
  latitude,
  created_by,
  created_at,
  updated_at
''';

// ─────────────────────────────────────────────────────────────────

abstract class SearchRemoteDataSource {
  Future<SearchResult> getDiscoveryFeed({
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  Future<SearchResult> search({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  Future<List<User>> searchUsers({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  Future<List<Post>> searchPosts({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  Future<List<Organization>> searchOrganizations({
    required String query,
    int page = 1,
    int limit = 20,
  });
}

// ─────────────────────────────────────────────────────────────────

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final _supabase.SupabaseClient supabase;

  SearchRemoteDataSourceImpl({required this.supabase});

  // ── helpers ──────────────────────────────────────────────────────

  int _offset(int page, int limit) => (page - 1) * limit;

  Post _postFromRow(Map<String, dynamic> row) =>
      PostModel.fromJson(row).toEntity();

  User _userFromRow(Map<String, dynamic> row) =>
      UserModel.fromJson(row).toEntity();

  Organization _orgFromRow(Map<String, dynamic> row) =>
      OrganizationModel.fromJson(row).toEntity();

  // ── Content-Based Filtering helpers ──────────────────────────────

  /// Step 1 — build interest-frequency map from liked + saved posts.
  /// We look at both `tags` (List<PostTag>) and `amenities` (List<AmenityType>)
  /// because your PostModel stores both as string arrays in Supabase.
  Future<Map<String, int>> _buildInterestMap(String userId) async {
    try {
      // Fetch tags/amenities from posts the user liked
      // final liked = await supabase
      //     .from('post_likes')
      //     .select('posts(tags, amenities)')
      //     .eq('user_id', userId)
      //     .limit(60);

      // Fetch tags/amenities from posts the user saved
      final saved = await supabase
          .from('saved_posts')
          .select('posts(tags, amenities)')
          .eq('user_id', userId)
          .limit(60);

      final Map<String, int> freq = {};

      void extractList(dynamic raw) {
        if (raw is List) {
          for (final item in raw) {
            if (item is String && item.isNotEmpty) {
              freq[item] = (freq[item] ?? 0) + 1;
            }
          }
        }
      }

      for (final row in [
        // ...liked,
        ...saved,
      ]) {
        final post = row['posts'] as Map<String, dynamic>?;
        if (post == null) continue;
        extractList(post['tags']);
        extractList(post['amenities']);
      }

      return freq;
    } catch (_) {
      return {};
    }
  }

  /// Step 2 — score a post row against the interest map.
  double _contentScore({
    required dynamic tagsRaw,
    required dynamic amenitiesRaw,
    required Map<String, int> freq,
    required int maxFreq,
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

  /// Step 3 — recency score: 1.0 if < 24 h, fades to 0 at 30 days.
  double _recencyScore(String? createdAtStr) {
    if (createdAtStr == null) return 0;
    final dt = DateTime.tryParse(createdAtStr);
    if (dt == null) return 0;
    final ageHours = DateTime.now().difference(dt).inHours;
    if (ageHours <= 24) return 1.0;
    if (ageHours >= 720) return 0.0;
    return 1.0 - ((ageHours - 24) / (720 - 24));
  }

  List<String>? _asList(dynamic raw) {
    if (raw is List) return raw.whereType<String>().toList();
    return null;
  }

  // ── Discovery feed ────────────────────────────────────────────────

  @override
  Future<SearchResult> getDiscoveryFeed({
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Run interest-map fetch + user fetch + org fetch concurrently
      // final results = await Future.wait(
      //   [
      //         _buildInterestMap(currentUserId),
      //         // Suggested users: exclude self, any role, ordered by created_at
      //         supabase
      //             .from('users')
      //             .select(_userSelect)
      //             .neq('user_id', currentUserId)
      //             .order('created_at', ascending: false)
      //             .limit(10),
      //         // Featured orgs: most recently added
      //         supabase
      //             .from('organizations')
      //             .select(_orgSelect)
      //             .order('created_at', ascending: false)
      //             .limit(10),
      //         // Candidate posts: status=available, not by current user
      //         supabase
      //             .from('posts')
      //             .select(_postSelect)
      //             .eq('status', PostStatus.available.name)
      //             .neq('created_by', currentUserId)
      //             .order('created_at', ascending: false)
      //             .limit(limit * 5), // fetch 5× to allow re-ranking
      //       ]
      //       as Iterable<Future<dynamic>>,
      // );

      final results = await Future.wait<dynamic>([
        _buildInterestMap(currentUserId),
        supabase
            .from('users')
            .select(_userSelect)
            .neq('user_id', currentUserId)
            .order('created_at', ascending: false)
            .limit(10),
        supabase
            .from('organizations')
            .select(_orgSelect)
            .order('created_at', ascending: false)
            .limit(10),
        supabase
            .from('posts')
            .select(_postSelect)
            .eq('status', PostStatus.available.name)
            .neq('created_by', currentUserId)
            .order('created_at', ascending: false)
            .limit(limit * 5),
      ]);

      final freq = results[0] as Map<String, int>;
      final userRows = results[1] as List<dynamic>;
      final orgRows = results[2] as List<dynamic>;
      final candidateRows = results[3] as List<dynamic>;

      final maxFreq = freq.isEmpty
          ? 1
          : freq.values.reduce((a, b) => a > b ? a : b);

      // Score & sort candidates
      final scored = candidateRows.map((row) {
        final r = row as Map<String, dynamic>;
        final cs = _contentScore(
          tagsRaw: r['tags'],
          amenitiesRaw: r['amenities'],
          freq: freq,
          maxFreq: maxFreq,
        );
        final rs = _recencyScore(r['created_at'] as String?);
        final blended = 0.6 * cs + 0.4 * rs;
        return MapEntry(r, blended);
      }).toList()..sort((a, b) => b.value.compareTo(a.value));

      final posts = scored.take(limit).map((e) => _postFromRow(e.key)).toList();
      final users = userRows
          .map((r) => _userFromRow(r as Map<String, dynamic>))
          .toList();
      final orgs = orgRows
          .map((r) => _orgFromRow(r as Map<String, dynamic>))
          .toList();

      return SearchResult(posts: posts, users: users, organizations: orgs);
    } on _supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Full search ───────────────────────────────────────────────────

  @override
  Future<SearchResult> search({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // All three run concurrently
      final results = await Future.wait([
        searchPosts(
          query: query,
          currentUserId: currentUserId,
          page: page,
          limit: limit,
        ),
        searchUsers(
          query: query,
          currentUserId: currentUserId,
          page: page,
          limit: limit,
        ),
        searchOrganizations(query: query, page: page, limit: limit),
      ]);

      return SearchResult(
        posts: results[0] as List<Post>,
        users: results[1] as List<User>,
        organizations: results[2] as List<Organization>,
      );
    } on _supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Search posts ──────────────────────────────────────────────────

  @override
  Future<List<Post>> searchPosts({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = _offset(page, limit);

      // Supabase full-text search on title column (tsvector index)
      // Also OR with ilike on description for partial matches
      final rows = await supabase
          .from('posts')
          .select(_postSelect)
          .eq('status', PostStatus.available.name)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // print(rows.first);

      return rows.map((r) => _postFromRow(r)).toList();
    } on _supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Search users ──────────────────────────────────────────────────
  // Uses UserModel.full_name (snake_case in DB).
  // Excludes the current user from results.

  @override
  Future<List<User>> searchUsers({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = _offset(page, limit);

      final rows = await supabase
          .from('users')
          .select(_userSelect)
          .ilike('full_name', '%$query%')
          .neq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return rows.map((r) => _userFromRow(r)).toList();
    } on _supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Search organizations ──────────────────────────────────────────
  // Uses OrganizationModel.name and .address

  @override
  Future<List<Organization>> searchOrganizations({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = _offset(page, limit);

      final rows = await supabase
          .from('organizations')
          .select(_orgSelect)
          .or('name.ilike.%$query%,address.ilike.%$query%')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return rows.map((r) => _orgFromRow(r)).toList();
    } on _supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
