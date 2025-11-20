import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

// Events
abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

// If the Post(as a parameter/extra data) is not provided then try to load by post id.
class PostDetalLoadRequested extends PostDetailEvent {
  final String postId;
  const PostDetalLoadRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
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

class PostDetailLoaded extends PostDetailState {
  final Post post;
  final bool canEdit;
  final bool canDelete;
  final int? viewingImageIndex;
  final bool? watchingVideo;
  final bool? isSharing;

  const PostDetailLoaded({
    required this.post,
    this.canEdit = false,
    this.canDelete = false,
    this.viewingImageIndex,
    this.watchingVideo,
    this.isSharing = false,
  });

  @override
  List<Object?> get props => [
    post,
    canEdit,
    canDelete,
    viewingImageIndex,
    watchingVideo,
    isSharing,
  ];

  PostDetailLoaded copyWith({
    Post? post,
    bool? canEdit,
    bool? canDelete,
    int? viewingImageIndex,
    bool? watchingVideo,
    bool? isSharing,
  }) {
    return PostDetailLoaded(
      post: post ?? this.post,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      viewingImageIndex: viewingImageIndex ?? this.viewingImageIndex,
      watchingVideo: watchingVideo ?? this.watchingVideo,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  // Clear image viewing
  PostDetailLoaded clearImageViewing() {
    return copyWith(viewingImageIndex: null);
  }

  // Get all images (primary or additional images)
  List<String> get getAllImages {
    final images = <String>[];
    images.add(post.primaryImageUrl);
    images.addAll(post.additionalImages.map((img) => img.imageUrl));
    return images;
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
class PostDetailsBloc {}
