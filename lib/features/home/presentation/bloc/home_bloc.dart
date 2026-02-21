import 'dart:async';

import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/usecases/get_all_post_recommended_by_content_filter_use_case.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

// Fetch nearby posts
class FetchNearbyPosts extends HomeEvent {
  final String userId;
  final double? latitude;
  final double? longitude;
  final String? cursor; // Pagination cursor
  final int limit;

  const FetchNearbyPosts({
    required this.userId,
    this.latitude,
    this.longitude,
    this.cursor,
    this.limit = 15,
  });

  @override
  List<Object?> get props => [userId, latitude, longitude, cursor, limit];
}

class FetchNearByAndContentBasedFilteringPosts extends HomeEvent {
  final String userId;
  final double? latitude;
  final double? longitude;
  final int limit;

  const FetchNearByAndContentBasedFilteringPosts({
    required this.userId,
    this.longitude,
    this.latitude,
    this.limit = 15,
  });

  @override
  List<Object?> get props => [userId, longitude, latitude, limit];
}

class RefreshNearbyPosts extends HomeEvent {
  final String userId;
  final double? latitude;
  final double? longitude;

  const RefreshNearbyPosts({
    required this.userId,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [userId, latitude, longitude];
}

class FetchOrganizationDetails extends HomeEvent {
  final String organizationId;
  const FetchOrganizationDetails(this.organizationId);

  @override
  List<Object?> get props => [organizationId];
}

// States

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Post> posts;
  final String? nextCursor;
  final Map<String, Organization> organizations;

  const HomeLoaded(
    this.posts,
    this.nextCursor, {
    this.organizations = const {},
  });

  HomeLoaded copyWith({
    List<Post>? posts,
    String? nextCursor,
    Map<String, Organization>? organizations,
  }) {
    return HomeLoaded(
      posts ?? this.posts,
      nextCursor ?? this.nextCursor,
      organizations: organizations ?? this.organizations,
    );
  }

  @override
  List<Object?> get props => [posts, nextCursor, organizations];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllPostsNearByUserUseCase getNearbyPostsUseCase;
  final GetOrganizationDetailByPostOrganizationIdUseCase
  getOrganizationDetailByPostOrganizationIdUseCase;
  final GetAllPostRecommendedByContentFilterUseCase
  getAllPostRecommendedByContentFilterUseCase;

  HomeBloc({
    required this.getNearbyPostsUseCase,
    required this.getOrganizationDetailByPostOrganizationIdUseCase,
    required this.getAllPostRecommendedByContentFilterUseCase,
  }) : super(const HomeInitial()) {
    on<FetchNearbyPosts>(_onFetchNearbyPosts);
    on<FetchNearByAndContentBasedFilteringPosts>(
      _onFetchNearByAndContentBasedFilteringPosts,
    );
    on<FetchOrganizationDetails>(_onFetchOrganizationDetails);
    on<RefreshNearbyPosts>(_onRefreshNearbyPosts);
  }

  Future<void> _onFetchNearbyPosts(
    FetchNearbyPosts event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await getNearbyPostsUseCase(
      GetAllPostsNearByUserParams(
        userId: event.userId,
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit,
        cursor: event.cursor,
      ),
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(HomeLoaded(data.posts, data.nextCursor)),
    );
  }

  Future<void> _onFetchOrganizationDetails(
    FetchOrganizationDetails event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    // Already cached? Don’t fetch again.
    if (currentState.organizations.containsKey(event.organizationId)) {
      return;
    }

    final result = await getOrganizationDetailByPostOrganizationIdUseCase(
      GetOrganizationDetailByPostOrganizationIdParams(
        organizationId: event.organizationId,
      ),
    );

    result.fold(
      (failure) {
        // You can ignore or show error
      },
      (organization) {
        final updatedMap = Map<String, Organization>.from(
          currentState.organizations,
        );
        updatedMap[event.organizationId] = organization;

        emit(currentState.copyWith(organizations: updatedMap));
      },
    );
  }

  Future<void> _onRefreshNearbyPosts(
    RefreshNearbyPosts event,
    Emitter<HomeState> emit,
  ) async {
    final result = await getNearbyPostsUseCase(
      GetAllPostsNearByUserParams(
        userId: event.userId,
        latitude: event.latitude,
        longitude: event.longitude,
        limit: 15,
        cursor: null,
      ),
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(
        HomeLoaded(data.posts, data.nextCursor, organizations: const {}),
      ),
    );
  }

  Future<void> _onFetchNearByAndContentBasedFilteringPosts(
    FetchNearByAndContentBasedFilteringPosts event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await getAllPostRecommendedByContentFilterUseCase(
      GetAllPostRecommendedByContentFilterParams(
        userId: event.userId,
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (posts) => emit(
        HomeLoaded(
          posts,
          null, // No cursor for recommendation feed (for now)
          organizations: const {},
        ),
      ),
    );
  }
}
