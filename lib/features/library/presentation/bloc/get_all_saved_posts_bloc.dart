import 'dart:async';

import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class GetAllSavedPostsEvent extends Equatable {
  const GetAllSavedPostsEvent();

  @override
  List<Object> get props => [];
}

class GetAllSavedPostsRequested extends GetAllSavedPostsEvent {
  final String userId;
  const GetAllSavedPostsRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

// States
abstract class GetAllSavedPostsState extends Equatable {
  const GetAllSavedPostsState();

  @override
  List<Object> get props => [];
}

class GetAllSavedPostsInitital extends GetAllSavedPostsState {
  const GetAllSavedPostsInitital();
}

class GetAllSavedPostLoading extends GetAllSavedPostsState {
  const GetAllSavedPostLoading();
}

class GetAllSavedPostsSuccess extends GetAllSavedPostsState {
  final List<Post> savedPosts;

  const GetAllSavedPostsSuccess({required this.savedPosts});

  @override
  List<Object> get props => [savedPosts];
}

class GetAllSavedPostsError extends GetAllSavedPostsState {
  final String message;
  const GetAllSavedPostsError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class GetAllSavedPostsBloc
    extends Bloc<GetAllSavedPostsEvent, GetAllSavedPostsState> {
  final GetAllSavedPostsUseCase _getAllSavedPostsUseCase;

  GetAllSavedPostsBloc({
    required GetAllSavedPostsUseCase getAllSavedPostsUseCase,
  }) : _getAllSavedPostsUseCase = getAllSavedPostsUseCase,
       super(const GetAllSavedPostsInitital()) {
    on<GetAllSavedPostsRequested>(_onGetAllSavedPostsRequested);
  }

  Future<void> _onGetAllSavedPostsRequested(
    GetAllSavedPostsRequested event,
    Emitter<GetAllSavedPostsState> emit,
  ) async {
    try {
      final params = GetAllSavedPostsParams(userId: event.userId);
      final result = await _getAllSavedPostsUseCase(params);

      result.fold(
        (failure) => emit(GetAllSavedPostsError(message: failure.message)),
        (posts) => emit(GetAllSavedPostsSuccess(savedPosts: posts)),
      );
    } catch (e) {
      emit(GetAllSavedPostsError(message: e.toString()));
    }
  }
}
