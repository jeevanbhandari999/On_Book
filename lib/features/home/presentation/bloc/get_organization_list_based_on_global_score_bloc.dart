import 'dart:async';

import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/usecases/get_organization_list_based_on_global_score_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class GetOrganizationListBasedOnGlobalScoreEvent extends Equatable {
  const GetOrganizationListBasedOnGlobalScoreEvent();

  @override
  List<Object?> get props => [];
}

class GetOrganizationListBasedOnGlobalScoreRequested
    extends GetOrganizationListBasedOnGlobalScoreEvent {
  final String? userId; // Made it optional for future use if required
  const GetOrganizationListBasedOnGlobalScoreRequested({this.userId});

  @override
  List<Object?> get props => [userId];
}

// States
abstract class GetOrganizationListBasedOnGlobalScoreState extends Equatable {
  const GetOrganizationListBasedOnGlobalScoreState();

  @override
  List<Object> get props => [];
}

class GetOrganizationListBasedOnGlobalScoreInitial
    extends GetOrganizationListBasedOnGlobalScoreState {
  const GetOrganizationListBasedOnGlobalScoreInitial();
}

class GetOrganizationListBasedOnGlobalScoreLoading
    extends GetOrganizationListBasedOnGlobalScoreState {
  const GetOrganizationListBasedOnGlobalScoreLoading();
}

class GetOrganizationListBasedOnGlobalScoreSuccess
    extends GetOrganizationListBasedOnGlobalScoreState {
  final List<Organization> organizations;

  const GetOrganizationListBasedOnGlobalScoreSuccess({
    required this.organizations,
  });

  @override
  List<Object> get props => [organizations];
}

class GetOrganizationListBasedOnGlobalScoreError
    extends GetOrganizationListBasedOnGlobalScoreState {
  final String message;
  const GetOrganizationListBasedOnGlobalScoreError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class GetOrganizationListBasedOnGlobalScoreBloc
    extends
        Bloc<
          GetOrganizationListBasedOnGlobalScoreEvent,
          GetOrganizationListBasedOnGlobalScoreState
        > {
  final GetOrganizationListBasedOnGlobalScoreUseCase
  _getOrganizationListBasedOnGlobalScoreUseCase;

  GetOrganizationListBasedOnGlobalScoreBloc({
    required GetOrganizationListBasedOnGlobalScoreUseCase
    getOrganizationListBasedOnGlobalScoreUseCase,
  }) : _getOrganizationListBasedOnGlobalScoreUseCase =
           getOrganizationListBasedOnGlobalScoreUseCase,
       super(const GetOrganizationListBasedOnGlobalScoreInitial()) {
    on<GetOrganizationListBasedOnGlobalScoreRequested>(
      _onGetOrganizationListBasedOnGlobalScoreRequested,
    );
  }

  Future<void> _onGetOrganizationListBasedOnGlobalScoreRequested(
    GetOrganizationListBasedOnGlobalScoreRequested event,
    Emitter<GetOrganizationListBasedOnGlobalScoreState> emit,
  ) async {
    emit(const GetOrganizationListBasedOnGlobalScoreLoading());
    try {
      // No need for any params for now, later we will provide the user id id necessary.

      final result = await _getOrganizationListBasedOnGlobalScoreUseCase();

      result.fold(
        (failure) => emit(
          GetOrganizationListBasedOnGlobalScoreError(message: failure.message),
        ),
        (organizationLists) => emit(
          GetOrganizationListBasedOnGlobalScoreSuccess(
            organizations: organizationLists,
          ),
        ),
      );
    } catch (e) {
      emit(GetOrganizationListBasedOnGlobalScoreError(message: e.toString()));
    }
  }
}
