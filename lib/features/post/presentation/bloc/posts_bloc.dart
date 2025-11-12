import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_image.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_by_organization_id_use_case.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_images_by_orgnization_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class OrganizationPostsBloc
    extends Bloc<OrganizationPostsEvent, OrganizationPostsState> {
  final GetAllPostsByOrganizationIdUseCase getAllPostsByOrganizationId;
  final GetAllPostsWithImagesByOrganizationIdUseCase
  getAllPostsWithImagesByOrganizationId;

  OrganizationPostsBloc({
    required this.getAllPostsByOrganizationId,
    required this.getAllPostsWithImagesByOrganizationId,
  }) : super(OrganizationPostsInitial()) {
    on<FetchOrganizationPosts>((event, emit) async {
      emit(OrganizationPostsLoading());
      final result = await getAllPostsByOrganizationId(
        GetAllPostsByOrganizationIdParams(
          userId: event.userId,
          organizationId: event.organizationId,
        ),
      );
      result.fold(
        (failure) => emit(OrganizationPostsError(failure.message)),
        (posts) => emit(OrganizationPostsLoaded(posts)),
      );
    });
    on<FetchOrganizationPostsWithImages>((event, emit) async {
      emit(OrganizationPostsLoading());
      final result = await getAllPostsWithImagesByOrganizationId(
        GetAllPostsWithImagesByOrganizationIdParams(
          userId: event.userId,
          organizationId: event.organizationId,
        ),
      );
      result.fold(
        (failure) => emit(OrganizationPostsError(failure.message)),
        (posts) => emit(OrganizationPostsImagesLoaded(posts)),
      );
    });
  }
}

// ─── Events ────────────────────────────────────────────────────────────────
abstract class OrganizationPostsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchOrganizationPosts extends OrganizationPostsEvent {
  final String? userId;
  final String organizationId;

  FetchOrganizationPosts({this.userId, required this.organizationId});

  @override
  List<Object?> get props => [userId, organizationId];
}

class FetchOrganizationPostsWithImages extends OrganizationPostsEvent {
  final String organizationId;
  final String? userId;

  FetchOrganizationPostsWithImages({required this.organizationId, this.userId});

  @override
  List<Object?> get props => [userId, organizationId];
}

// States
abstract class OrganizationPostsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrganizationPostsInitial extends OrganizationPostsState {}

class OrganizationPostsLoading extends OrganizationPostsState {}

class OrganizationPostsLoaded extends OrganizationPostsState {
  final List<Post> posts;
  OrganizationPostsLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class OrganizationPostsImagesLoaded extends OrganizationPostsState {
  final List<PostImage> postImages;
  OrganizationPostsImagesLoaded(this.postImages);

  @override
  List<Object?> get props => [postImages];
}

class OrganizationPostsError extends OrganizationPostsState {
  final String message;
  OrganizationPostsError(this.message);

  @override
  List<Object?> get props => [message];
}
