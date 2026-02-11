import 'dart:async';

import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/organizations/domain/usecases/can_manage_orgnization_use_case.dart';
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
  final bool canManage;

  const GetUserOrganizationDetailsSuccess({
    required this.organizationDetails,
    this.members = const [],
    this.canManage = false,
  });

  @override
  List<Object> get props => [organizationDetails, members, canManage];
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
  final CanManageOrganizationUseCase _canManageOrganizationUseCase;
  GetUserOrganizationDetailsBloc({
    required GetUserOrganizationDetailUseCase getUserOrganizationDetailUseCase,
    required GetOrganizationMembersUseCase getOrganizationMembersUseCase,
    required CanManageOrganizationUseCase canManageOrganizationUseCase,
  }) : _getUserOrganizationDetailUseCase = getUserOrganizationDetailUseCase,
       _getOrganizationMembersUseCase = getOrganizationMembersUseCase,
       _canManageOrganizationUseCase = canManageOrganizationUseCase,
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

      // First Get organization
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

      // Second Get members
      final membersEither = await _getOrganizationMembersUseCase(
        GetOrganizationMembersParams(organizationId: event.organizationId),
      );

      final members = membersEither.fold(
        (failure) => const <User>[], // ← ignore failure or show partial result
        (list) => list,
      );

      // ANd finally check whethere the user can manage the organzation or not
      if (event.userId == null) {
        emit(
          GetUserOrganizationDetailsSuccess(
            organizationDetails: organization,
            members: members,
          ),
        );
        return;
      }
      final canManageOrganizationParams = CanManageOrganizationParams(
        userId: event.userId!,
        organizationId: event.organizationId,
      );
      final canManageEither = await _canManageOrganizationUseCase(
        canManageOrganizationParams,
      );
      final canManage = canManageEither.fold(
        (failure) => false, // Ignore the failure just return the false
        (canManage) => canManage,
      );
      emit(
        GetUserOrganizationDetailsSuccess(
          organizationDetails: organization,
          members: members,
          canManage: canManage,
        ),
      );
    } catch (e) {
      emit(GetUserOrganizationDetailsError(message: e.toString()));
    }
  }
}
