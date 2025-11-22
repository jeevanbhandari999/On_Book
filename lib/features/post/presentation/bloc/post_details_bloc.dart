import 'dart:async';

import 'package:app/app/dependency_injection.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/delete_post_use_case.dart';
import 'package:app/features/post/domain/usecases/get_post_by_id_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

// If the Post(as a parameter/extra data) is not provided then try to load by post id.
class PostDetailLoadRequested extends PostDetailEvent {
  final String postId;
  final String? userId;
  const PostDetailLoadRequested({required this.postId, this.userId});

  @override
  List<Object?> get props => [postId, userId];
}

class PostLocationViewRequested extends PostDetailEvent {
  const PostLocationViewRequested();
}

class PostDetailRefreshRequested extends PostDetailEvent {
  const PostDetailRefreshRequested();
}

class PostDetailPermissionCheckedRequested extends PostDetailEvent {
  final String userId;
  final String? organizationId; // Made optional

  const PostDetailPermissionCheckedRequested({
    required this.userId,
    this.organizationId,
  });

  @override
  List<Object?> get props => [userId, organizationId];
}

class PostDetailVideoViewRequested extends PostDetailEvent {
  const PostDetailVideoViewRequested();
}

class PostDetailVideoViewCloseRequested extends PostDetailEvent {
  const PostDetailVideoViewCloseRequested();
}

class PostDetailImageViewRequested extends PostDetailEvent {
  final int imageIndex;
  const PostDetailImageViewRequested({required this.imageIndex});

  @override
  List<Object?> get props => [imageIndex];
}

class PostDetailImageViewCloseRequested extends PostDetailEvent {
  const PostDetailImageViewCloseRequested();
}

class PostDetailSharedRequested extends PostDetailEvent {
  const PostDetailSharedRequested();
}

class PostDetailDeleteRequested extends PostDetailEvent {
  final String userId;
  //   final bool confirmed;
  const PostDetailDeleteRequested({
    required this.userId,
    // this.confirmed = false,
  });

  @override
  List<Object?> get props => [
    userId,
    // confirmed
  ];
}

class PostDetailToggleDescriptionRequested extends PostDetailEvent {
  final bool isDescriptionToggled;
  const PostDetailToggleDescriptionRequested({
    this.isDescriptionToggled = false,
  });

  @override
  List<Object?> get props => [isDescriptionToggled];
}

// States
abstract class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostDetailInitial extends PostDetailState {
  const PostDetailInitial();
}

class PostdetailLoading extends PostDetailState {
  const PostdetailLoading();
}

class PostDetailRefreshing extends PostDetailState {
  final Post currentPost; // for fallback if unable to refresh;
  const PostDetailRefreshing({required this.currentPost});

  @override
  List<Object?> get props => [currentPost];
}

class PostDetailDeleting extends PostDetailState {
  final Post currentPost; // for fallback if unable to delete;
  const PostDetailDeleting({required this.currentPost});

  @override
  List<Object?> get props => [currentPost];
}

class PostDetailDeleted extends PostDetailState {
  final String postId;
  final String message;

  const PostDetailDeleted({required this.postId, required this.message});

  @override
  List<Object?> get props => [postId, message];
}

class PostDetailLoaded extends PostDetailState {
  final Post post;
  final List<String> additionalImageUrls;

  final bool canEdit;
  final bool canDelete;
  final int? viewingImageIndex;
  final bool? watchingVideo;
  final bool? isSharing;
  final bool isDescriptionExpanded;

  const PostDetailLoaded({
    required this.post,
    required this.additionalImageUrls,
    this.canEdit = false,
    this.canDelete = false,
    this.viewingImageIndex,
    this.watchingVideo,
    this.isSharing = false,
    this.isDescriptionExpanded = false,
  });

  @override
  List<Object?> get props => [
    post,
    canEdit,
    canDelete,
    viewingImageIndex,
    watchingVideo,
    isSharing,
    isDescriptionExpanded,
  ];

  PostDetailLoaded copyWith({
    Post? post,
    List<String>? additionalImageUrls,
    bool? canEdit,
    bool? canDelete,
    int? viewingImageIndex,
    bool? watchingVideo,
    bool? isSharing,
    bool? isDescriptionExpanded,
  }) {
    return PostDetailLoaded(
      post: post ?? this.post,
      additionalImageUrls: additionalImageUrls ?? this.additionalImageUrls,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      viewingImageIndex: viewingImageIndex ?? this.viewingImageIndex,
      watchingVideo: watchingVideo ?? this.watchingVideo,
      isSharing: isSharing ?? this.isSharing,
      isDescriptionExpanded:
          isDescriptionExpanded ?? this.isDescriptionExpanded,
    );
  }

  // Clear image viewing
  PostDetailLoaded clearImageViewing() {
    return copyWith(viewingImageIndex: null);
  }

  // Get all images (primary or additional images)
  List<String> get getAllImages {
    return [post.primaryImageUrl, ...additionalImageUrls];
  }

  // Check if the post has additional images
  bool get hasAdditionalImages => post.hasAdditionalImages;

  // Check if currently viewing an image
  bool get isViewingImage => viewingImageIndex != null;

  // Get the current viewing image url
  String? get currentViewingImageUrl {
    if (viewingImageIndex != null && viewingImageIndex! < getAllImages.length) {
      return getAllImages[viewingImageIndex!];
    }
    return null;
  }

  // Check if user can manage
  bool get canManage => canEdit || canDelete;

  // Get post status
  PostStatus get postStatus {
    return post.status;
  }
}

class PostDetailError extends PostDetailState {
  final String message;
  final Post? post; // Made optional, for fallback if there is an error

  const PostDetailError({required this.message, this.post});

  @override
  List<Object?> get props => [message, post];
}

class PostDetailNotFound extends PostDetailState {
  final String postId;

  const PostDetailNotFound({required this.postId});

  @override
  List<Object> get props => [postId];
}

// BLoC
class PostDetailsBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final GetPostByIdUseCase _getPostByIdUseCase;
  final DeletePostUseCase _deletePostUseCase;

  // Made optional for more customize
  String? _currentUserId;
  String? _currentPostId;

  PostDetailsBloc({
    required GetPostByIdUseCase getPostByIdUseCase,
    required DeletePostUseCase deletePostUseCase,
  }) : _getPostByIdUseCase = getPostByIdUseCase,
       _deletePostUseCase = deletePostUseCase,
       super(const PostDetailInitial()) {
    on<PostDetailLoadRequested>(_onLoadRequested);
    on<PostDetailRefreshRequested>(_onRefreshRequested);
    on<PostLocationViewRequested>(_onLocationViewRequested);
    on<PostDetailPermissionCheckedRequested>(_onPermissionCheckedRequested);
    on<PostDetailVideoViewRequested>(_onVideoViewRequested);
    on<PostDetailVideoViewCloseRequested>(_onVideoCloseRequested);
    on<PostDetailImageViewRequested>(_onImageViewRequested);
    on<PostDetailImageViewCloseRequested>(_onImageCloseRequested);
    on<PostDetailSharedRequested>(_onSharedRequested);
    on<PostDetailDeleteRequested>(_onDeleteRequested);
    on<PostDetailToggleDescriptionRequested>(_onToggleDescriptionRequested);
  }

  Future<void> _onLoadRequested(
    PostDetailLoadRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    _currentPostId = event.postId;
    _currentUserId = event.userId;

    emit(const PostdetailLoading());
    try {
      // Get the params
      final params = event.userId != null
          ? GetPostByIdParams.fetchWithUser(
              postId: event.postId,
              userId: event.userId!,
            )
          : GetPostByIdParams.generalFetch(event.postId);

      final result = await _getPostByIdUseCase(params);

      if (result.isLeft()) {
        final failure = result.swap().getOrElse(() => throw Exception());
        if (failure.message.contains('not found')) {
          emit(PostDetailNotFound(postId: event.postId));
        } else {
          emit(PostDetailError(message: failure.message));
        }
        return;
      }

      final postData = result.getOrElse(() => throw Exception());

      final postRepo = DependencyInjection.get<PostRepository>();

      final imageResult = await postRepo.getAllSpecificPostImagesByPostId(
        postData.id,
      );

      // extract the image urls safely
      final additionalImageUrls = imageResult.fold(
        (failure) => <String>[],
        (images) => images.map((img) => img.imageUrl).toList(),
      );

      emit(
        PostDetailLoaded(
          post: postData,
          additionalImageUrls: additionalImageUrls,
        ),
      );

      // Check the permission also
      if (event.userId != null) {
        add(PostDetailPermissionCheckedRequested(userId: event.userId!));
      }

      // result.fold(
      //   (failure) {
      //     if (failure.message.contains('not found')) {
      //       emit(PostDetailNotFound(postId: event.postId));
      //     } else {
      //       emit(PostDetailError(message: failure.message));
      //     }
      //   },
      //   (postData) async {
      //     final postRepo = DependencyInjection.get<PostRepository>();

      //     final imageResult = await postRepo.getPostsWithImagesByOrganizationId(
      //       postData.organizationId,
      //     );

      //     // extract the image urls safely
      //     final additionalImageUrls = imageResult.fold(
      //       (failure) => <String>[],
      //       (images) => images.map((img) => img.imageUrl).toList(),
      //     );

      //     emit(
      //       PostDetailLoaded(
      //         post: postData,
      //         additionalImageUrls: additionalImageUrls,
      //       ),
      //     );

      //     // Check the permission also
      //     if (event.userId != null) {
      //       add(PostDetailPermissionCheckedRequested(userId: event.userId!));
      //     }
      //   },
      // );
    } catch (e) {
      // To enhance the performance it's a best way to use const constructor
      emit(
        const PostDetailError(
          message: 'Unable to load the post detail, please try again',
        ),
      );

      // We can print the error here to see what hapens, like this way.
      //   emit(
      //     PostDetailError(
      //       message: 'Unable to load the post detail, please try again ${e.toString()}',
      //     ),
      //   );
    }
  }

  Future<void> _onRefreshRequested(
    PostDetailRefreshRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;

    if (currentState is PostDetailLoaded) {
      emit(PostDetailRefreshing(currentPost: currentState.post));
    }

    if (_currentPostId != null) {
      add(
        PostDetailLoadRequested(
          postId: _currentPostId!,
          userId: _currentUserId,
        ),
      );
    }
  }

  Future<void> _onLocationViewRequested(
    PostLocationViewRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    // TODO
  }

  Future<void> _onPermissionCheckedRequested(
    PostDetailPermissionCheckedRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostDetailLoaded) {
      return;
    }
    try {
      // TODO
    } catch (e) {
      emit(const PostDetailError(message: 'Unable to check permission'));
    }
  }

  Future<void> _onVideoViewRequested(
    PostDetailVideoViewRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is PostDetailLoaded) {
      emit(currentState.copyWith(watchingVideo: true));
    }
  }

  Future<void> _onVideoCloseRequested(
    PostDetailVideoViewCloseRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is PostDetailLoaded) {
      emit(currentState.copyWith(watchingVideo: false));
    }
  }

  Future<void> _onImageViewRequested(
    PostDetailImageViewRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is PostDetailLoaded) {
      if (event.imageIndex >= 0 &&
          event.imageIndex < currentState.getAllImages.length) {
        emit(currentState.copyWith(viewingImageIndex: event.imageIndex));
      }
    }
  }

  Future<void> _onImageCloseRequested(
    PostDetailImageViewCloseRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is PostDetailLoaded) {
      emit(currentState.clearImageViewing());
    }
  }

  Future<void> _onSharedRequested(
    PostDetailSharedRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    // TODO
  }

  Future<void> _onDeleteRequested(
    PostDetailDeleteRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostDetailLoaded) {
      return;
    }

    // if (!event.confirmed) {
    //   // Emit the error requesting confirmation
    //   emit(
    //     PostDetailError(
    //       message: 'Deletion post requires confirmation',
    //       post: currentState.post,
    //     ),
    //   );
    //   return;
    // }

    emit(PostDetailDeleting(currentPost: currentState.post));

    try {
      final params = DeletePostParams(
        postId: currentState.post.id,
        userId: event.userId,
      );

      final result = await _deletePostUseCase(params);

      result.fold(
        (failure) {
          emit(
            PostDetailError(
              message: 'Unable to delete the post: ${failure.message}',
              post: currentState.post,
            ),
          );
        },
        (_) {
          emit(
            PostDetailDeleted(
              postId: currentState.post.id,
              message: 'Post deleted successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        PostDetailError(
          message: 'Uexpected error: ${e.toString()}',
          post: currentState.post,
        ),
      );
    }
  }

  Future<void> _onToggleDescriptionRequested(
    PostDetailToggleDescriptionRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is PostDetailLoaded) {
      emit(
        currentState.copyWith(
          isDescriptionExpanded: !event.isDescriptionToggled,
        ),
      );
    }
  }
}
