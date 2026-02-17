// ─────────────────────────────────────────────────────────────────
// features/search/domain/usecases/search_use_cases.dart
// ─────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/search/domain/entities/search_result.dart';
import 'package:app/features/search/domain/repositories/search_repository.dart';

// ── Shared params ────────────────────────────────────────────────

class SearchParams extends Equatable {
  final String query;
  final String currentUserId;
  final int page;
  final int limit;

  const SearchParams({
    required this.query,
    required this.currentUserId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, currentUserId, page, limit];
}

class DiscoveryParams extends Equatable {
  final String currentUserId;
  final int page;
  final int limit;

  const DiscoveryParams({
    required this.currentUserId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [currentUserId, page, limit];
}

class OrgSearchParams extends Equatable {
  final String query;
  final int page;
  final int limit;

  const OrgSearchParams({required this.query, this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [query, page, limit];
}

// ── Use cases ────────────────────────────────────────────────────

/// Returns content-based discovery feed (no query typed yet)
class GetDiscoveryFeedUseCase {
  final SearchRepository repository;
  GetDiscoveryFeedUseCase(this.repository);

  Future<Either<Failure, SearchResult>> call(DiscoveryParams params) =>
      repository.getDiscoveryFeed(
        currentUserId: params.currentUserId,
        page: params.page,
        limit: params.limit,
      );
}

/// Full search — posts + users + organizations
class SearchAllUseCase {
  final SearchRepository repository;
  SearchAllUseCase(this.repository);

  Future<Either<Failure, SearchResult>> call(SearchParams params) =>
      repository.search(
        query: params.query,
        currentUserId: params.currentUserId,
        page: params.page,
        limit: params.limit,
      );
}

/// Search only users (People tab)
class SearchUsersUseCase {
  final SearchRepository repository;
  SearchUsersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call(SearchParams params) =>
      repository.searchUsers(
        query: params.query,
        currentUserId: params.currentUserId,
        page: params.page,
        limit: params.limit,
      );
}

/// Search only posts (Posts tab)
class SearchPostsUseCase {
  final SearchRepository repository;
  SearchPostsUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call(SearchParams params) =>
      repository.searchPosts(
        query: params.query,
        currentUserId: params.currentUserId,
        page: params.page,
        limit: params.limit,
      );
}

/// Search only organizations (Hotels tab)
class SearchOrganizationsUseCase {
  final SearchRepository repository;
  SearchOrganizationsUseCase(this.repository);

  Future<Either<Failure, List<Organization>>> call(OrgSearchParams params) =>
      repository.searchOrganizations(
        query: params.query,
        page: params.page,
        limit: params.limit,
      );
}
