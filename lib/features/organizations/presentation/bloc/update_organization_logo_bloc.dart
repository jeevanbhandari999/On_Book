import 'dart:async';
import 'dart:io';

import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:app/features/organizations/domain/usecases/delete_organization_logo_use_case.dart';
import 'package:app/features/organizations/domain/usecases/update_organization_logo_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UpdateOrganizationLogoEvent extends Equatable {
  const UpdateOrganizationLogoEvent();

  @override
  List<Object?> get props => [];
}

class UpdateOrganizationLogoRequested extends UpdateOrganizationLogoEvent {
  final String organizationId;
  final File newLogoFile;
  final String? existingLogoToDelete;

  const UpdateOrganizationLogoRequested({
    required this.organizationId,
    required this.newLogoFile,
    this.existingLogoToDelete,
  });

  @override
  List<Object?> get props => [
    organizationId,
    newLogoFile,
    existingLogoToDelete,
  ];
}

class DeleteOrganizationLogoRequested extends UpdateOrganizationLogoEvent {
  final String organizationId;
  final String logoUrlToDelete;

  const DeleteOrganizationLogoRequested({
    required this.organizationId,
    required this.logoUrlToDelete,
  });

  @override
  List<Object?> get props => [organizationId, logoUrlToDelete];
}

// States
abstract class UpdateOrganizationLogoState extends Equatable {
  const UpdateOrganizationLogoState();

  @override
  List<Object?> get props => [];
}

class UpdateOrganizationLogoInitial extends UpdateOrganizationLogoState {
  const UpdateOrganizationLogoInitial();
}

class UpdateOrganizationLogoLoading extends UpdateOrganizationLogoState {
  const UpdateOrganizationLogoLoading();
}

class OrganizationLogoUpdating extends UpdateOrganizationLogoState {
  const OrganizationLogoUpdating();
}

class OrganizationLogoDeleting extends UpdateOrganizationLogoState {
  const OrganizationLogoDeleting();
}

class UpdateOrganizationLogoSuccess extends UpdateOrganizationLogoState {
  final String newLogoPictureUrl;
  const UpdateOrganizationLogoSuccess({required this.newLogoPictureUrl});

  @override
  List<Object?> get props => [newLogoPictureUrl];
}

class DeleteOrganizationLogoSuccess extends UpdateOrganizationLogoState {
  const DeleteOrganizationLogoSuccess();
}

class UpdateOrganizationLogoError extends UpdateOrganizationLogoState {
  final String message;
  const UpdateOrganizationLogoError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class UpdateOrganizationLogoBloc
    extends Bloc<UpdateOrganizationLogoEvent, UpdateOrganizationLogoState> {
  final UpdateOrganizationLogoUseCase _updateOrganizationLogoUseCase;
  final DeleteOrganizationLogoUseCase _deleteOrganizationLogoUseCase;
  final OrganizationRepository _repository;

  UpdateOrganizationLogoBloc({
    required UpdateOrganizationLogoUseCase updateOrganizationLogoUseCase,
    required DeleteOrganizationLogoUseCase deleteOrganizationLogoUseCase,
    required OrganizationRepository repository,
  }) : _updateOrganizationLogoUseCase = updateOrganizationLogoUseCase,
       _deleteOrganizationLogoUseCase = deleteOrganizationLogoUseCase,
       _repository = repository,
       super(const UpdateOrganizationLogoInitial()) {
    on<UpdateOrganizationLogoRequested>(_onUpdateOrganizationLogoRequested);
    on<DeleteOrganizationLogoRequested>(_onDeleteOrganizationLogoRequested);
  }

  Future<void> _onUpdateOrganizationLogoRequested(
    UpdateOrganizationLogoRequested event,
    Emitter<UpdateOrganizationLogoState> emit,
  ) async {
    emit(const OrganizationLogoUpdating());
    try {
      String? logoUrl;
      final uploadResult = await _repository.uploadOrganizationLogo(
        event.newLogoFile,
        event.organizationId,
      );
      logoUrl = uploadResult.fold((failure) => throw failure, (url) => url);
      final updateParams = UpdateOrganizationLogoParams(
        organizationId: event.organizationId,
        logoUrl: logoUrl!,
        existingLogoToDelte: event.existingLogoToDelete,
      );

      final result = await _updateOrganizationLogoUseCase(updateParams);
      result.fold(
        (failure) =>
            emit(UpdateOrganizationLogoError(message: failure.message)),
        (organizationLogo) => emit(
          UpdateOrganizationLogoSuccess(
            newLogoPictureUrl: organizationLogo.logoUrl!,
          ),
        ),
      );
    } catch (e) {
      emit(UpdateOrganizationLogoError(message: e.toString()));
    }
  }

  Future<void> _onDeleteOrganizationLogoRequested(
    DeleteOrganizationLogoRequested event,
    Emitter<UpdateOrganizationLogoState> emit,
  ) async {
    emit(const OrganizationLogoDeleting());
    try {
      await _repository.deleteOrganizationLogo(event.logoUrlToDelete);
      final deleteParams = DeleteOrganizationLogoParams(
        organizationId: event.organizationId,
        logoUrlToDelete: event.logoUrlToDelete,
      );
      final result = await _deleteOrganizationLogoUseCase(deleteParams);
      result.fold(
        (failure) =>
            emit(UpdateOrganizationLogoError(message: failure.message)),
        (profile) {
          emit(const UpdateOrganizationLogoSuccess(newLogoPictureUrl: ''));
        },
      );
    } catch (e) {
      emit(UpdateOrganizationLogoError(message: e.toString()));
    }
  }
}
