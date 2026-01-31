import 'dart:async';

import 'package:app/core/errors/failures.dart';
import 'package:app/features/home/domain/entities/saved_post.dart';
import 'package:app/features/home/domain/usecases/stream_saved_post_use_case.dart';
import 'package:app/features/home/domain/usecases/toggle_post_save_or_unsave_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Events
abstract class TogglePostSaveOrUnsaveEvent extends Equatable {
  const TogglePostSaveOrUnsaveEvent();

  @override
  List<Object> get props => [];
}

/// Start realtime listener
class PostSaveStarted extends TogglePostSaveOrUnsaveEvent {
  final String userId;

  const PostSaveStarted(this.userId);

  @override
  List<Object> get props => [userId];
}

class PostSaveMessageConsumed extends TogglePostSaveOrUnsaveEvent {
  const PostSaveMessageConsumed();
}

/// Toggle save / unsave
class PostSaveToggleRequested extends TogglePostSaveOrUnsaveEvent {
  final String postId;
  final String userId;
  final String organizationId;

  const PostSaveToggleRequested({
    required this.postId,
    required this.userId,
    required this.organizationId,
  });

  @override
  List<Object> get props => [postId, userId, organizationId];
}

/// States
class TogglePostSaveOrUnsaveState extends Equatable {
  final bool loading;
  final List<SavedPost> savedPosts;
  final String? error;
  final String? message;
  final bool actionSuccess;

  const TogglePostSaveOrUnsaveState({
    required this.loading,
    required this.savedPosts,
    this.error,
    this.message,
    required this.actionSuccess,
  });

  factory TogglePostSaveOrUnsaveState.initial() =>
      const TogglePostSaveOrUnsaveState(
        loading: false,
        savedPosts: [],
        error: null,
        message: null,
        actionSuccess: false,
      );

  TogglePostSaveOrUnsaveState copyWith({
    bool? loading,
    List<SavedPost>? savedPosts,
    String? error,
    String? message,
    bool? actionSuccess,
  }) {
    return TogglePostSaveOrUnsaveState(
      loading: loading ?? this.loading,
      savedPosts: savedPosts ?? this.savedPosts,
      error: error,
      message: message ?? this.message,
      actionSuccess: actionSuccess ?? this.actionSuccess,
    );
  }

  bool isSaved(String postId) {
    return savedPosts.any((p) => p.postId == postId);
  }

  @override
  List<Object?> get props => [
    loading,
    savedPosts,
    error,
    message,
    actionSuccess,
  ];
}

/// BLoC
class TogglePostSaveOrUnsaveBloc
    extends Bloc<TogglePostSaveOrUnsaveEvent, TogglePostSaveOrUnsaveState> {
  final TogglePostSaveOrUnsaveUseCase _toggleUseCase;
  final StreamSavedPostsUseCase _streamUseCase;

  StreamSubscription? _subscription;

  TogglePostSaveOrUnsaveBloc({
    required TogglePostSaveOrUnsaveUseCase toggleUseCase,
    required StreamSavedPostsUseCase streamUseCase,
  }) : _toggleUseCase = toggleUseCase,
       _streamUseCase = streamUseCase,
       super(TogglePostSaveOrUnsaveState.initial()) {
    on<PostSaveStarted>(_onStarted);
    on<PostSaveToggleRequested>(_onToggle);
    on<PostSaveMessageConsumed>(_onSavedMessageConsumed);
  }

  /// REALTIME STREAM
  Future<void> _onStarted(
    PostSaveStarted event,
    Emitter<TogglePostSaveOrUnsaveState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    await _subscription?.cancel();

    await emit.forEach<Either<Failure, List<SavedPost>>>(
      _streamUseCase(StreamSavedPostsParams(userId: event.userId)),
      onData: (either) => either.fold(
        (failure) =>
            state.copyWith(loading: false, error: _mapFailure(failure)),
        (posts) =>
            state.copyWith(loading: false, savedPosts: posts, error: null),
      ),
      onError: (error, _) =>
          state.copyWith(loading: false, error: error.toString()),
    );
  }

  /// OPTIMISTIC TOGGLE
  Future<void> _onToggle(
    PostSaveToggleRequested event,
    Emitter<TogglePostSaveOrUnsaveState> emit,
  ) async {
    final previousState = state;

    final isAlreadySaved = state.savedPosts.any(
      (p) => p.postId == event.postId,
    );

    final updatedList = List<SavedPost>.from(state.savedPosts);

    if (isAlreadySaved) {
      // UNSAVE (optimistic)
      updatedList.removeWhere((p) => p.postId == event.postId);
    } else {
      updatedList.add(
        SavedPost(
          id: 'temp',
          postId: event.postId,
          userId: event.userId,
          organizationId: event.organizationId,
          savedAt: DateTime.now(),
        ),
      );
    }

    emit(state.copyWith(savedPosts: updatedList));

    final result = await _toggleUseCase(
      TogglePostSaveOrUnsaveParams(
        postId: event.postId,
        userId: event.userId,
        organizationId: event.organizationId,
      ),
    );

    result.fold(
      (failure) {
        emit(
          previousState.copyWith(
            error: _mapFailure(failure),
            message: null,
            actionSuccess: false,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            message: isAlreadySaved
                ? 'Removed from saved'
                : 'Saved successfully',
            actionSuccess: true,
            error: null,
          ),
        );
      },
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is ValidationFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    return 'Unexpected error occurred';
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  void _onSavedMessageConsumed(
    PostSaveMessageConsumed event,
    Emitter<TogglePostSaveOrUnsaveState> emit,
  ) {
    emit(state.copyWith(message: null, actionSuccess: false));
  }
}
