// Events

import 'dart:async';
import 'dart:io';

import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/update_profile_picture_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateProfilePictureEvent extends Equatable {
  const UpdateProfilePictureEvent();
  @override
  List<Object?> get props => [];
}

class UpdateProfilePictureRequested extends UpdateProfilePictureEvent {
  final String userId;
  final File newPictureFile;

  const UpdateProfilePictureRequested({
    required this.userId,
    required this.newPictureFile,
  });

  @override
  List<Object?> get props => [userId, newPictureFile];
}

class DeleteProfilePictureRequested extends UpdateProfilePictureEvent {
  final String userId;
  final String pictureUrlToDelete;

  const DeleteProfilePictureRequested({
    required this.userId,
    required this.pictureUrlToDelete,
  });

  @override
  List<Object?> get props => [userId, pictureUrlToDelete];
}

// States
abstract class UpdateProfilePictureState extends Equatable {
  const UpdateProfilePictureState();

  @override
  List<Object?> get props => [];
}

class UpdateProfilePictureInitial extends UpdateProfilePictureState {
  const UpdateProfilePictureInitial();
}

class UpdateProfilePictureLoading extends UpdateProfilePictureState {
  const UpdateProfilePictureLoading();
}

class ProfilePictureUpdating extends UpdateProfilePictureState {
  const ProfilePictureUpdating();
}

class UpdateProfilePictureSuccess extends UpdateProfilePictureState {
  final String newProfilePictureUrl;
  const UpdateProfilePictureSuccess(this.newProfilePictureUrl);
  @override
  List<Object?> get props => [newProfilePictureUrl];
}

class DeleteProfilePictureSuccess extends UpdateProfilePictureState {
  const DeleteProfilePictureSuccess();
}

class ProfilePictureDeleting extends UpdateProfilePictureState {
  const ProfilePictureDeleting();
}

class UpdateProfilePictureError extends UpdateProfilePictureState {
  final String message;

  const UpdateProfilePictureError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class UpdateProfilePictureBloc
    extends Bloc<UpdateProfilePictureEvent, UpdateProfilePictureState> {
  final UpdateProfilePictureUseCase _updateProfilePictureUseCase;
  final ProfileRepository _repository;
  UpdateProfilePictureBloc({
    required UpdateProfilePictureUseCase updateProfilePictureUseCase,
    required ProfileRepository repository,
  }) : _updateProfilePictureUseCase = updateProfilePictureUseCase,
       _repository = repository,
       super(const UpdateProfilePictureInitial()) {
    on<UpdateProfilePictureRequested>(_onUpdateRequested);
    on<DeleteProfilePictureRequested>(_onDeleteRequested);
  }

  Future<void> _onUpdateRequested(
    UpdateProfilePictureRequested event,
    Emitter<UpdateProfilePictureState> emit,
  ) async {
    emit(const ProfilePictureUpdating());
    try {
      String? imageUrl;
      final uploadResult = await _repository.uploadProfilePicture(
        event.newPictureFile,
        event.userId,
      );
      imageUrl = uploadResult.fold((failure) => throw failure, (url) => url);

      final result = await _updateProfilePictureUseCase(
        UpdateProfilePictureParams(userId: event.userId, imageUrl: imageUrl!),
      );

      result.fold(
        (failure) => emit(UpdateProfilePictureError(message: failure.message)),
        (profile) => emit(UpdateProfilePictureSuccess(profile.imageUrl!)),
      );
    } catch (e) {
      emit(
        UpdateProfilePictureError(
          message: 'Failed to update the avater image: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    DeleteProfilePictureRequested event,
    Emitter<UpdateProfilePictureState> emit,
  ) async {
    emit(const ProfilePictureDeleting());
    try {
      String deletedUrl = '';
      await _repository.deleteProfilePicture(event.pictureUrlToDelete);

      final result = await _updateProfilePictureUseCase(
        UpdateProfilePictureParams(
          userId: event.userId,
          imageUrl: deletedUrl,
        ),
      );

      result.fold(
        (failure) => emit(UpdateProfilePictureError(message: failure.message)),
        (profile) {
          // print('soemtning');
          // print(profile);
          emit(UpdateProfilePictureSuccess(profile.imageUrl!));
        },
      );
    } catch (e) {
      // print('$e from bloc');
      emit(
        UpdateProfilePictureError(
          message: 'Failed to delete the profile image: ${e.toString()}',
        ),
      );
    }
  }
}
