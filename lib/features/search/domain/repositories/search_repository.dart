// ─────────────────────────────────────────────────────────────────
// features/search/domain/repositories/search_repository.dart
// ─────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/search/domain/entities/search_result.dart';

abstract class SearchRepository {
  /// Content-based discovery feed (no query).
  Future<Either<Failure, SearchResult>> getDiscoveryFeed({
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  /// Full-text search across all three types concurrently.
  Future<Either<Failure, SearchResult>> search({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  /// Search only users by full_name.
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  /// Search only posts by title / description / tags / amenities.
  Future<Either<Failure, List<Post>>> searchPosts({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  });

  /// Search only organizations by name / address.
  Future<Either<Failure, List<Organization>>> searchOrganizations({
    required String query,
    int page = 1,
    int limit = 20,
  });
}
