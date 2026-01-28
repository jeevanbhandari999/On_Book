import 'dart:async';

import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class GetCurrentUserProfileDetailsEvent extends Equatable {
  const GetCurrentUserProfileDetailsEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentUserProfileDetailsRequested
    extends GetCurrentUserProfileDetailsEvent {
  final String userId;

  const GetCurrentUserProfileDetailsRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

// States
abstract class GetCurrentUserProfileDetailsState extends Equatable {
  const GetCurrentUserProfileDetailsState();

  @override
  List<Object> get props => [];
}

class GetCurrentUserProfileDetailsInitial
    extends GetCurrentUserProfileDetailsState {
  const GetCurrentUserProfileDetailsInitial();
}

class GetCurrentUserProfileDetailsLoading
    extends GetCurrentUserProfileDetailsState {
  const GetCurrentUserProfileDetailsLoading();
}

class GetCurrentUserProfileDetailsSuccess
    extends GetCurrentUserProfileDetailsState {
  final User user;
  const GetCurrentUserProfileDetailsSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class GetCurrentUserProfileDetailsError
    extends GetCurrentUserProfileDetailsState {
  final String message;

  const GetCurrentUserProfileDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class GetCurrentUserProfileDetailsBloc
    extends
        Bloc<
          GetCurrentUserProfileDetailsEvent,
          GetCurrentUserProfileDetailsState
        > {
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase;

  GetCurrentUserProfileDetailsBloc({
    required GetCurrentUserProfileUseCase getCurrentUserProfileUseCase,
  }) : _getCurrentUserProfileUseCase = getCurrentUserProfileUseCase,
       super(const GetCurrentUserProfileDetailsInitial()) {
    on<GetCurrentUserProfileDetailsRequested>(
      _onGetCurrentUserProfileDetailRequested,
    );
  }

  Future<void> _onGetCurrentUserProfileDetailRequested(
    GetCurrentUserProfileDetailsRequested event,
    Emitter<GetCurrentUserProfileDetailsState> emit,
  ) async {
    emit(const GetCurrentUserProfileDetailsLoading());

    try {
      final params = GetCurrentUserProfileParams(userId: event.userId);
      final response = await _getCurrentUserProfileUseCase(params);

      response.fold(
        (failure) =>
            emit(GetCurrentUserProfileDetailsError(message: failure.message)),
        (userProfile) =>
            emit(GetCurrentUserProfileDetailsSuccess(user: userProfile)),
      );
    } catch (e) {
      emit(GetCurrentUserProfileDetailsError(message: e.toString()));
    }
  }
}
