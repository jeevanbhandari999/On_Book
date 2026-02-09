import 'dart:async';

import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/organizations/domain/usecases/get_organization_members_use_case.dart';
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
  final List<User> members;

  const GetUserOrganizationDetailsSuccess({
    required this.organizationDetails,
    this.members = const [],
  });

  @override
  List<Object> get props => [organizationDetails, members];
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
  final GetOrganizationMembersUseCase _getOrganizationMembersUseCase;
  GetUserOrganizationDetailsBloc({
    required GetUserOrganizationDetailUseCase getUserOrganizationDetailUseCase,
    required GetOrganizationMembersUseCase getOrganizationMembersUseCase,
  }) : _getUserOrganizationDetailUseCase = getUserOrganizationDetailUseCase,
       _getOrganizationMembersUseCase = getOrganizationMembersUseCase,
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
      // final params = GetUserOrganizationDetailParams(
      //   organizationId: event.organizationId,
      //   userId: event.userId,
      // );

      // final response = await _getUserOrganizationDetailUseCase(params);

      // response.fold(
      //   (failure) =>
      //       emit(GetUserOrganizationDetailsError(message: failure.message)),
      //   (organizationDetails) => emit(
      //     GetUserOrganizationDetailsSuccess(
      //       organizationDetails: organizationDetails,
      //     ),
      //   ),
      // );

      // 1. Get organization
      final orgParams = GetUserOrganizationDetailParams(
        organizationId: event.organizationId,
        userId: event.userId,
      );

      final orgEither = await _getUserOrganizationDetailUseCase(orgParams);

      if (orgEither.isLeft()) {
        final failure = orgEither.fold((l) => l, (_) => null)!;
        emit(GetUserOrganizationDetailsError(message: failure.message));
        return;
      }

      final organization = orgEither.getOrElse(() => throw Exception());

      // 2. Get members
      final membersEither = await _getOrganizationMembersUseCase(
        GetOrganizationMembersParams(organizationId: event.organizationId),
      );

      final members = membersEither.fold(
        (failure) => const <User>[], // ← ignore failure or show partial result
        (list) => list,
      );

      emit(
        GetUserOrganizationDetailsSuccess(
          organizationDetails: organization,
          members: members,
        ),
      );
    } catch (e) {
      emit(GetUserOrganizationDetailsError(message: e.toString()));
    }
  }
}
