import 'dart:async';

import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/usecases/edit_user_profile_use_case.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class EditUserProfileEvent extends Equatable {
  const EditUserProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileFullNameChanged extends EditUserProfileEvent {
  final String fullName;

  const ProfileFullNameChanged({required this.fullName});

  @override
  List<Object?> get props => [fullName];
}

class ProfileAddressChanged extends EditUserProfileEvent {
  final String address;

  const ProfileAddressChanged({required this.address});

  @override
  List<Object?> get props => [address];
}

class ProfilePhoneChanged extends EditUserProfileEvent {
  final String phone;

  const ProfilePhoneChanged({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class ProfileDetailRefreshRequested extends EditUserProfileEvent {
  final String userId;
  const ProfileDetailRefreshRequested({required this.userId});
}

class ProfileDetailUpdateRequested extends EditUserProfileEvent {
  const ProfileDetailUpdateRequested();
}

class ProfileDetailInitialized extends EditUserProfileEvent {
  final User? profile;
  final String userId;

  const ProfileDetailInitialized({this.profile, required this.userId});

  @override
  List<Object?> get props => [profile, userId];
}

class ProfileDetailLoadRequested extends EditUserProfileEvent {
  final String userId;

  const ProfileDetailLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// States
abstract class EditUserProfileState extends Equatable {
  const EditUserProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileDetailLoading extends EditUserProfileState {
  const ProfileDetailLoading();
}

class UpdateProfileDetailInitial extends EditUserProfileState {
  const UpdateProfileDetailInitial();
}

class ProfileDetailRefreshing extends EditUserProfileState {
  const ProfileDetailRefreshing();
}

class ProfileDetailUpdating extends EditUserProfileState {
  const ProfileDetailUpdating();
}

class ProfileDetailUpdateSuccess extends EditUserProfileState {
  final User updatedProfile;
  final String message;
  const ProfileDetailUpdateSuccess({
    required this.updatedProfile,
    required this.message,
  });
}

class UpdateProfileDetailError extends EditUserProfileState {
  final String message;
  const UpdateProfileDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileDetailReady extends EditUserProfileState {
  final String userId;
  final String fullName;
  final String? phone;
  final String? address;
  final DateTime updatedAt;
  final Map<String, String>? validationErrors;

  const ProfileDetailReady({
    required this.userId,
    required this.fullName,
    this.phone,
    this.address,
    required this.updatedAt,
    this.validationErrors,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    phone,
    address,
    updatedAt,
    validationErrors,
  ];

  ProfileDetailReady copyWith({
    String? userId,
    String? fullName,
    String? phone,
    String? address,
    DateTime? updatedAt,
    Map<String, String>? validationErrors,
  }) {
    return ProfileDetailReady(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      updatedAt: updatedAt ?? this.updatedAt,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

// BLoC
class EditUserProfileBloc
    extends Bloc<EditUserProfileEvent, EditUserProfileState> {
  final EditUserProfileUseCase _editUserProfileUseCase;
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase;
  EditUserProfileBloc({
    required EditUserProfileUseCase editUserProfileUseCase,
    required GetCurrentUserProfileUseCase getCurrentUserProfileUseCase,
  }) : _editUserProfileUseCase = editUserProfileUseCase,
       _getCurrentUserProfileUseCase = getCurrentUserProfileUseCase,
       super(const UpdateProfileDetailInitial()) {
    on<ProfileDetailInitialized>(_onInitialized);
    on<ProfileFullNameChanged>(_onFullNameChanged);
    on<ProfilePhoneChanged>(_onPhoneChanged);
    on<ProfileAddressChanged>(_onAddressChanged);
    on<ProfileDetailUpdateRequested>(_onUpdateRequested);
    on<ProfileDetailRefreshRequested>(_onRefresh);
  }

  Future<void> _onInitialized(
    ProfileDetailInitialized event,
    Emitter<EditUserProfileState> emit,
  ) async {
    try {
      if (event.profile != null) {
        emit(
          ProfileDetailReady(
            userId: event.userId,
            fullName: event.profile!.fullName,
            phone: event.profile!.phone,
            address: event.profile!.address,
            updatedAt: event.profile!.updatedAt,
          ),
        );
      }
    } catch (e) {
      emit(
        UpdateProfileDetailError(message: 'Failed to update the profil: $e'),
      );
    }
  }

  Future<void> _onFullNameChanged(
    ProfileFullNameChanged event,
    Emitter<EditUserProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileDetailReady) {
      emit(
        currentState.copyWith(
          fullName: event.fullName,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onPhoneChanged(
    ProfilePhoneChanged event,
    Emitter<EditUserProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileDetailReady) {
      emit(
        currentState.copyWith(phone: event.phone, updatedAt: DateTime.now()),
      );
    }
  }

  Future<void> _onAddressChanged(
    ProfileAddressChanged event,
    Emitter<EditUserProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileDetailReady) {
      emit(
        currentState.copyWith(
          address: event.address,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    ProfileDetailUpdateRequested event,
    Emitter<EditUserProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileDetailReady) {
      return;
    }
    emit(const ProfileDetailUpdating());
    try {
      final params = EditUserProfileParams(
        userId: currentState.userId,
        fullName: currentState.fullName,
        address: currentState.address,
        phone: currentState.phone,
        updatedAt: currentState.updatedAt,
      );

      final result = await _editUserProfileUseCase(params);
      result.fold(
        (failure) {
          emit(
            UpdateProfileDetailError(
              message:
                  'Filed to update the profile details: ${failure.message}',
            ),
          );
        },
        (profile) {
          emit(
            ProfileDetailReady(
              userId: profile.userId,
              fullName: profile.fullName,
              phone: profile.phone,
              address: profile.address,
              updatedAt: profile.updatedAt,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        UpdateProfileDetailError(message: 'Failed to update the profil: $e'),
      );
    }
  }

  Future<void> _onRefresh(
    ProfileDetailRefreshRequested event,
    Emitter<EditUserProfileState> emit,
  ) async {
    emit(const ProfileDetailRefreshing());
    try {
      final params = GetCurrentUserProfileParams(userId: event.userId);
      final response = await _getCurrentUserProfileUseCase(params);
      response.fold(
        (failure) => emit(UpdateProfileDetailError(message: failure.message)),
        (profileDetails) => emit(
          ProfileDetailReady(
            userId: profileDetails.userId,
            fullName: profileDetails.fullName,
            phone: profileDetails.phone,
            address: profileDetails.address,
            updatedAt: profileDetails.updatedAt,
          ),
        ),
      );
    } catch (e) {
      emit(
        UpdateProfileDetailError(message: 'Failed to update the profil: $e'),
      );
    }
  }
}
