import 'dart:async';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:app/features/auth/domain/usecases/login_use_case.dart';
import 'package:app/features/auth/domain/usecases/register_use_case.dart';
import 'package:app/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  final Map<String, dynamic>?
  organizationDetails; // right now this is a details of hotel
  final String? organizationId;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.organizationDetails,
    this.organizationId,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    fullName,
    role,
    organizationDetails,
    organizationId,
  ];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final OrganizationModel? organization;

  const AuthAuthenticated({required this.user, this.organization});

  @override
  List<Object?> get props => [user, organization];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  // final ForgotPasswordUseCase _forgotPasswordUseCase;
  // final ResetPasswordUseCase _resetPasswordUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );

      result.fold(
        (failure) {
          if (failure.message.toLowerCase().contains('not found')) {
            emit(AuthError(message: failure.message));
          }
        },
        (user) {
          emit(AuthAuthenticated(user: user));
        },
      );

      // if (user != null) {
      //   // Check if user needs to complete profile
      //   final needsCompletion = await _authService.needsProfileCompletion();
      //   if (needsCompletion) {
      //     emit(AuthNeedsProfileCompletion(user: user));
      //     return;
      //   }

      //   // Check if manager needs to create organization
      //   if (user.role == UserRole.manager && user.organizationId == null) {
      //     emit(AuthNeedsOrganizationCreation(user: user));
      //     return;
      //   }

      // Get organization if user has one
      // final organization = _get.getUserOrganization();
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _registerUseCase(
        RegisterParams(
          email: event.email,
          password: event.password,
          fullname: event.fullName,
          role: event.role.name,
        ),
      );

      result.fold(
        (failure) {
          if (failure.message.toLowerCase().contains('not found')) {
            emit(AuthError(message: failure.message));
          }
        },
        (user) {
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  FutureOr<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {}

  FutureOr<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) {}
}
