import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
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

  const HomeLoaded(this.posts, this.nextCursor);

  @override
  List<Object?> get props => [posts, nextCursor];
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

  HomeBloc({required this.getNearbyPostsUseCase})
      : super(const HomeInitial()) {
    on<FetchNearbyPosts>(_onFetchNearbyPosts);
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
}