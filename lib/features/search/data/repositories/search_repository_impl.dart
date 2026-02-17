// ─────────────────────────────────────────────────────────────────
// features/search/data/repositories/search_repository_impl.dart
// ─────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/search/data/datasources/search_remote_data_source.dart';
import 'package:app/features/search/domain/entities/search_result.dart';
import 'package:app/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SearchResult>> getDiscoveryFeed({
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.getDiscoveryFeed(
        currentUserId: currentUserId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SearchResult>> search({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.search(
        query: query,
        currentUserId: currentUserId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchUsers(
        query: query,
        currentUserId: currentUserId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts({
    required String query,
    required String currentUserId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchPosts(
        query: query,
        currentUserId: currentUserId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Organization>>> searchOrganizations({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchOrganizations(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
