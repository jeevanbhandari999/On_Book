import 'dart:async';

import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/organizations/domain/usecases/get_user_organization_detail_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class GetUserOrganizationDetailsEvent extends Equatable {
  const GetUserOrganizationDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetUserOrganizationDetailsRequested
    extends GetUserOrganizationDetailsEvent {
  final String? userId;
  final String organizationId;
  const GetUserOrganizationDetailsRequested({
    required this.organizationId,
    this.userId,
  });

  @override
  List<Object?> get props => [organizationId, userId];
}

// States
abstract class GetUserOrganizationDetailsState extends Equatable {
  const GetUserOrganizationDetailsState();

  @override
  List<Object> get props => [];
}

class GetUserOrganizationDetailsInitial
    extends GetUserOrganizationDetailsState {
  const GetUserOrganizationDetailsInitial();
}

class GetUserOrganizationDetailsLoading
    extends GetUserOrganizationDetailsState {
  const GetUserOrganizationDetailsLoading();
}

class GetUserOrganizationDetailsSuccess
    extends GetUserOrganizationDetailsState {
  final Organization organizationDetails;

  const GetUserOrganizationDetailsSuccess({required this.organizationDetails});

  @override
  List<Object> get props => [organizationDetails];
}

class GetUserOrganizationDetailsError extends GetUserOrganizationDetailsState {
  final String message;
  const GetUserOrganizationDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class GetUserOrganizationDetailsBloc
    extends
        Bloc<GetUserOrganizationDetailsEvent, GetUserOrganizationDetailsState> {
  final GetUserOrganizationDetailUseCase _getUserOrganizationDetailUseCase;
  GetUserOrganizationDetailsBloc({
    required GetUserOrganizationDetailUseCase getUserOrganizationDetailUseCase,
  }) : _getUserOrganizationDetailUseCase = getUserOrganizationDetailUseCase,
       super(const GetUserOrganizationDetailsInitial()) {
    on<GetUserOrganizationDetailsRequested>(
      _onGetUserOrganizationDetailsRequested,
    );
  }

  Future<void> _onGetUserOrganizationDetailsRequested(
    GetUserOrganizationDetailsRequested event,
    Emitter<GetUserOrganizationDetailsState> emit,
  ) async {
    emit(const GetUserOrganizationDetailsLoading());
    try {
      final params = GetUserOrganizationDetailParams(
        organizationId: event.organizationId,
        userId: event.userId,
      );

      final response = await _getUserOrganizationDetailUseCase(params);

      response.fold(
        (failure) =>
            emit(GetUserOrganizationDetailsError(message: failure.message)),
        (organizationDetails) => emit(
          GetUserOrganizationDetailsSuccess(
            organizationDetails: organizationDetails,
          ),
        ),
      );
    } catch (e) {
      emit(GetUserOrganizationDetailsError(message: e.toString()));
    }
  }
}
