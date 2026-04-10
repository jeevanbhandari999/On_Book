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
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_import;

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
  final supabase_import.SupabaseClient supabase;

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

  Future<Map<String, double>> _buildInterestMap(String userId) async {
    try {
      final results = await Future.wait([
        supabase
            .from('user_saved_posts')
            .select('posts(tags, amenities)')
            .eq('user_id', userId)
            .limit(30),

        supabase
            .from('bookings')
            .select('posts(tags, amenities)')
            .eq('user_id', userId)
            .limit(30),

        supabase
            .from('post_views')
            .select('posts(tags, amenities)')
            .eq('user_id', userId)
            .limit(50),
      ]);

      final saved = results[0] as List;
      final booked = results[1] as List;
      final viewed = results[2] as List;

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

      void processRows(List rows, double weight) {
        for (final row in rows) {
          final post = row['posts'] as Map<String, dynamic>?;
          if (post == null) continue;
          extract(post['tags'], weight);
          extract(post['amenities'], weight);
        }
      }

      processRows(saved, 1.0); // strong signal
      processRows(booked, 1.5); // very strong signal
      processRows(viewed, 0.4); // weak signal

      return freq;
    } catch (_) {
      return {};
    }
  }

  /// score a post row against the interest map.

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
      final results = await Future.wait<dynamic>([
        _buildInterestMap(currentUserId),

        // user-org affinity
        supabase.from('user_org_scores').select().eq('user_id', currentUserId),

        // global org scores
        supabase.from('org_global_scores').select(),

        // user behavior signals
        supabase.from('user_saved_posts').select('post_id'),

        supabase
            .from('bookings')
            .select('post_id')
            .eq('user_id', currentUserId),

        supabase
            .from('post_views')
            .select('post_id')
            .eq('user_id', currentUserId),

        // candidate posts
        supabase
            .from('posts')
            .select(_postSelect)
            .eq('status', PostStatus.available.name)
            .neq('created_by', currentUserId)
            .limit(limit * 5),

        // users
        supabase
            .from('users')
            .select(_userSelect)
            .neq('user_id', currentUserId)
            .limit(20),

        // organizations
        supabase.from('organizations').select(_orgSelect).limit(20),
      ]);

      final interestMap = results[0] as Map<String, double>;
      final userOrgScores = results[1] as List<dynamic>;
      final globalOrgScores = results[2] as List<dynamic>;
      final savedPosts = (results[3] as List).map((e) => e['post_id']).toSet();
      final bookedPosts = (results[4] as List).map((e) => e['post_id']).toSet();
      final viewedPosts = (results[5] as List).map((e) => e['post_id']).toSet();
      final candidateRows = results[6] as List<dynamic>;
      final userRows = results[7] as List<dynamic>;
      final orgRows = results[8] as List<dynamic>;

      final maxFreq = interestMap.isEmpty
          ? 1.0
          : interestMap.values.reduce((a, b) => a > b ? a : b);

      // Build maps for fast lookup
      final userOrgMap = {
        for (var row in userOrgScores)
          row['organization_id']: (row['total_score'] ?? 0).toDouble(),
      };

      final globalOrgMap = {
        for (var row in globalOrgScores)
          row['organization_id']: (row['total_score'] ?? 0).toDouble(),
      };

      // ─────────────────────────────────────────────
      // SCORE POSTS
      // ─────────────────────────────────────────────

      final scoredPosts = candidateRows.map((row) {
        final r = row as Map<String, dynamic>;

        final contentScore = _contentScore(
          tagsRaw: r['tags'],
          amenitiesRaw: r['amenities'],
          freq: interestMap,
          maxFreq: maxFreq.toDouble(),
        );

        final recencyScore = _recencyScore(r['created_at'] as String?);

        double behaviorScore = 0;
        if (savedPosts.contains(r['id'])) behaviorScore += 1.0;
        if (bookedPosts.contains(r['id'])) behaviorScore += 0.8;
        if (viewedPosts.contains(r['id'])) behaviorScore += 0.3;

        behaviorScore = behaviorScore.clamp(0, 1);

        final orgId = r['organization_id'];
        final orgAffinity = (userOrgMap[orgId] ?? 0) / 100;
        final globalScore = (globalOrgMap[orgId] ?? 0) / 100;

        final finalScore =
            0.35 * contentScore +
            0.20 * behaviorScore +
            0.15 * orgAffinity +
            0.15 * globalScore +
            0.15 * recencyScore;

        return MapEntry(r, finalScore);
      }).toList()..sort((a, b) => b.value.compareTo(a.value));

      final posts = scoredPosts
          .take(limit)
          .map((e) => _postFromRow(e.key))
          .toList();

      // ─────────────────────────────────────────────
      // SCORE ORGANIZATIONS
      // ─────────────────────────────────────────────

      final scoredOrgs = orgRows.map((row) {
        final r = row as Map<String, dynamic>;
        final orgId = r['id'];

        final userScore = userOrgMap[orgId] ?? 0;
        final globalScore = globalOrgMap[orgId] ?? 0;

        final total = 0.6 * userScore + 0.4 * globalScore;
        return MapEntry(r, total);
      }).toList()..sort((a, b) => b.value.compareTo(a.value));

      final organizations = scoredOrgs
          .take(limit)
          .map((e) => _orgFromRow(e.key))
          .toList();

      // ─────────────────────────────────────────────
      // USERS (simple recency for now)
      // ─────────────────────────────────────────────

      final users = userRows
          .map((r) => _userFromRow(r as Map<String, dynamic>))
          .toList();

      return SearchResult(
        posts: posts,
        users: users,
        organizations: organizations,
      );
    } on supabase_import.PostgrestException catch (e) {
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
    } on supabase_import.PostgrestException catch (e) {
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
    } on supabase_import.PostgrestException catch (e) {
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
    } on supabase_import.PostgrestException catch (e) {
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
    } on supabase_import.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
