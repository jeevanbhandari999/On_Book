import 'dart:async';

import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/entities/post_image.dart';
import 'package:app/features/post/domain/entities/post_video.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_by_organization_id_use_case.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_images_by_orgnization_id.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_videos_by_organization_id.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class OrganizationPostsEvent extends Equatable {
  const OrganizationPostsEvent();

  @override
  List<Object?> get props => [];
}

// Organization's all posts
class FetchOrganizationPosts extends OrganizationPostsEvent {
  final String? userId;
  final String organizationId;

  const FetchOrganizationPosts({this.userId, required this.organizationId});

  @override
  List<Object?> get props => [userId, organizationId];
}

// Organization's all posts images
class FetchOrganizationPostsWithImages extends OrganizationPostsEvent {
  final String organizationId;
  final String? userId;

  const FetchOrganizationPostsWithImages({
    required this.organizationId,
    this.userId,
  });

  @override
  List<Object?> get props => [userId, organizationId];
}

// Organization's all posts videos
class FetchOrganizationPostsWithVideos extends OrganizationPostsEvent {
  final String organizationId;
  final String? userId;

  const FetchOrganizationPostsWithVideos({
    required this.organizationId,
    this.userId,
  });

  @override
  List<Object?> get props => [userId, organizationId];
}

// Roll checking, (user, worker, admin, manager, owner) , which allow to navigate to the different screen easily
class ChecKUserRoleAndOrganizationDetailStatus extends OrganizationPostsEvent {
  final String? userId; // Made optional
  final String? organizationId; // Made optional
  final UserRole? role; // Made optional

  const ChecKUserRoleAndOrganizationDetailStatus({
    this.userId,
    this.organizationId,
    this.role,
  });

  @override
  List<Object?> get props => [userId, organizationId, role];
}

class SearchOrganizationPosts extends OrganizationPostsEvent {
  final String query;

  const SearchOrganizationPosts({required this.query});

  @override
  List<Object?> get props => [query];
}

// States
abstract class OrganizationPostsState extends Equatable {
  const OrganizationPostsState();

  @override
  List<Object?> get props => [];
}

class OrganizationPostsInitial extends OrganizationPostsState {
  const OrganizationPostsInitial();
}

class OrganizationPostsLoading extends OrganizationPostsState {
  const OrganizationPostsLoading();
}

class UserRoleAndOrganizationDetailStatusChecking
    extends OrganizationPostsState {
  const UserRoleAndOrganizationDetailStatusChecking();
}

class OrganizationPostsLoaded extends OrganizationPostsState {
  final List<Post> posts;
  const OrganizationPostsLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class OrganizationPostsImagesLoaded extends OrganizationPostsState {
  final List<PostImage> postImages;
  final List<Post> posts;
  const OrganizationPostsImagesLoaded(this.postImages, this.posts);

  @override
  List<Object?> get props => [postImages, posts];
}

class OrganizationPostsVideosLoaded extends OrganizationPostsState {
  final List<PostVideo> postVideos;
  final List<Post> posts;
  const OrganizationPostsVideosLoaded(this.postVideos, this.posts);

  @override
  List<Object?> get props => [postVideos, posts];
}

// for admin, no need for creation of organization , he can manage all application
class AdminLoggedIn extends OrganizationPostsState {
  final UserModel user;
  final OrganizationModel? organization; // may be he has any organization

  const AdminLoggedIn({required this.user, this.organization});

  @override
  List<Object?> get props => [user, organization];
}

// for owner(100% he must create an organization)
class OrganizationOwnerLoggedIn extends OrganizationPostsState {
  final UserModel user;
  final OrganizationModel organization;

  const OrganizationOwnerLoggedIn({
    required this.user,
    required this.organization,
  });

  @override
  List<Object> get props => [user, organization];
}

// for manager/staff who haven't joined any organization yet
class ManagerOrStaffLoggedInWithOutJoiningOrganization
    extends OrganizationPostsState {
  final UserModel user;
  final OrganizationModel?
  organization; // Made optional, though it's not needed

  const ManagerOrStaffLoggedInWithOutJoiningOrganization({
    required this.user,
    this.organization,
  });

  @override
  List<Object?> get props => [user, organization];
}

// for manager who have already joined the organization
class OrganizationManagerLoggedIn extends OrganizationPostsState {
  final UserModel user;
  final OrganizationModel organization;

  const OrganizationManagerLoggedIn({
    required this.user,
    required this.organization,
  });

  @override
  List<Object> get props => [user, organization];
}

// for manager who have already joined the organization
class OrganizationStaffLoggedIn extends OrganizationPostsState {
  final UserModel user;
  final OrganizationModel organization;

  const OrganizationStaffLoggedIn({
    required this.user,
    required this.organization,
  });

  @override
  List<Object> get props => [user, organization];
}

class GeneralUserLoggedIn extends OrganizationPostsState {
  final UserModel user;

  const GeneralUserLoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

class OrganizationPostsError extends OrganizationPostsState {
  final String message;
  const OrganizationPostsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoCs
class OrganizationPostsBloc
    extends Bloc<OrganizationPostsEvent, OrganizationPostsState> {
  final GetAllPostsByOrganizationIdUseCase getAllPostsByOrganizationId;
  final GetAllPostsWithImagesByOrganizationIdUseCase
  getAllPostsWithImagesByOrganizationId;
  final GetAllPostsWithVideosByOrganizationId
  getAllPostsWithVideosByOrganizationId;
  final PostServices postServices;

  List<Post> _allPosts = [];

  OrganizationPostsBloc({
    required this.getAllPostsByOrganizationId,
    required this.getAllPostsWithImagesByOrganizationId,
    required this.getAllPostsWithVideosByOrganizationId,
    required this.postServices,
  }) : super(const OrganizationPostsInitial()) {
    on<FetchOrganizationPosts>(_onFetchOrganizationPosts);
    on<FetchOrganizationPostsWithImages>(_onFetchOrganizationPostsImages);
    on<FetchOrganizationPostsWithVideos>(_onFetchOrganizationPostsVideos);
    on<ChecKUserRoleAndOrganizationDetailStatus>(
      _onCheckUserRoleAndOrganizationDetailStatus,
    );
    on<SearchOrganizationPosts>(_onSearchOrganizationPosts);
  }

  Future<void> _onFetchOrganizationPosts(
    FetchOrganizationPosts event,
    Emitter<OrganizationPostsState> emit,
  ) async {
    emit(const OrganizationPostsLoading());
    final result = await getAllPostsByOrganizationId(
      GetAllPostsByOrganizationIdParams(
        userId: event.userId,
        organizationId: event.organizationId,
      ),
    );
    result.fold((failure) => emit(OrganizationPostsError(failure.message)), (
      posts,
    ) {
      _allPosts = posts;

      emit(OrganizationPostsLoaded(posts));
    });
  }

  Future<void> _onFetchOrganizationPostsImages(
    FetchOrganizationPostsWithImages event,
    Emitter<OrganizationPostsState> emit,
  ) async {
    emit(const OrganizationPostsLoading());
    final resultForImages = await getAllPostsWithImagesByOrganizationId(
      GetAllPostsWithImagesByOrganizationIdParams(
        userId: event.userId,
        organizationId: event.organizationId,
      ),
    );
    final resultForPosts = await getAllPostsByOrganizationId(
      GetAllPostsByOrganizationIdParams(
        organizationId: event.organizationId,
        userId: event.userId,
      ),
    );

    final failure1 = resultForImages.fold((f) => f, (_) => null);
    final failure2 = resultForPosts.fold((f) => f, (_) => null);

    if (failure1 != null) {
      emit(OrganizationPostsError(failure1.message));
      return;
    }
    if (failure2 != null) {
      emit(OrganizationPostsError(failure2.message));
      return;
    }

    final postsWithImages = resultForImages.fold((_) => null, (data) => data)!;
    final postsOnly = resultForPosts.fold((_) => null, (data) => data)!;

    emit(OrganizationPostsImagesLoaded(postsWithImages, postsOnly));
  }

  Future<void> _onFetchOrganizationPostsVideos(
    FetchOrganizationPostsWithVideos event,
    Emitter<OrganizationPostsState> emit,
  ) async {
    emit(const OrganizationPostsLoading());
    final resultForImages = await getAllPostsWithVideosByOrganizationId(
      GetAllPostsWithVideosByOrganizationIdParams(
        userId: event.userId,
        organizationId: event.organizationId,
      ),
    );
    final resultForPosts = await getAllPostsByOrganizationId(
      GetAllPostsByOrganizationIdParams(
        organizationId: event.organizationId,
        userId: event.userId,
      ),
    );

    final failure1 = resultForImages.fold((f) => f, (_) => null);
    final failure2 = resultForPosts.fold((f) => f, (_) => null);

    if (failure1 != null) {
      emit(OrganizationPostsError(failure1.message));
      return;
    }
    if (failure2 != null) {
      emit(OrganizationPostsError(failure2.message));
      return;
    }

    final postsWithImages = resultForImages.fold((_) => null, (data) => data)!;
    final postsOnly = resultForPosts.fold((_) => null, (data) => data)!;

    emit(OrganizationPostsVideosLoaded(postsWithImages, postsOnly));
  }

  Future<void> _onCheckUserRoleAndOrganizationDetailStatus(
    ChecKUserRoleAndOrganizationDetailStatus event,
    Emitter<OrganizationPostsState> emit,
  ) async {
    emit(const UserRoleAndOrganizationDetailStatusChecking());
    try {
      final user = await postServices.getCurrentUserProfile();
      if (user == null) {
        emit(
          const OrganizationPostsError(
            'Failed to get user data: please re-login:',
          ),
        );
        return;
      }

      // check whether the general user logged in before get the organization details
      if (user.role == UserRole.user) {
        emit(GeneralUserLoggedIn(user: user));
        return;
      }

      final userOrganizationDetails = await postServices
          .getCurrentUserOrganization();

      // for admin (no restriction)
      if (user.role == UserRole.admin) {
        emit(AdminLoggedIn(user: user));
        return;
      }

      // for owner (they can only manage their organizatuions)
      if (user.role == UserRole.owner && userOrganizationDetails != null) {
        emit(
          OrganizationOwnerLoggedIn(
            user: user,
            organization: userOrganizationDetails,
          ),
        );
        return;
      }

      // For manager/staff without organizations
      if ((user.role == UserRole.manager || user.role == UserRole.worker) &&
          userOrganizationDetails == null) {
        // organization details will be null of course
        emit(ManagerOrStaffLoggedInWithOutJoiningOrganization(user: user));
        return;
      }

      // For manager with organization
      if (user.role == UserRole.manager && userOrganizationDetails != null) {
        // organization details will be null of course
        emit(
          OrganizationManagerLoggedIn(
            user: user,
            organization: userOrganizationDetails,
          ),
        );
        return;
      }

      // For staff with organization
      if (user.role == UserRole.worker && userOrganizationDetails != null) {
        emit(
          OrganizationStaffLoggedIn(
            user: user,
            organization: userOrganizationDetails,
          ),
        );
        return;
      }

      emit(GeneralUserLoggedIn(user: user));
    } catch (e) {
      emit(
        OrganizationPostsError('Failed to check user status: ${e.toString()}'),
      );
    }
  }

  Future<void> _onSearchOrganizationPosts(
    SearchOrganizationPosts event,
    Emitter<OrganizationPostsState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(OrganizationPostsLoaded(_allPosts));
      return;
    }

    final filteredPosts = _allPosts.where((post) {
      return post.title.toLowerCase().contains(event.query.toLowerCase()) ||
          (post.description ?? '').toLowerCase().contains(
            event.query.toLowerCase(),
          ) ||
          post.price.toString().contains(event.query) ||
          (post.tags != null &&
              post.tags!
                  .map((tag) => enumToString(tag))
                  .join(',')
                  .toLowerCase()
                  .contains(event.query.toLowerCase())) ||
          (post.amenities != null &&
              post.amenities!
                  .map((amenity) => enumToString(amenity))
                  .join(',')
                  .toLowerCase()
                  .contains(event.query.toLowerCase()));
    }).toList();

    emit(OrganizationPostsLoaded(filteredPosts));
  }
}
