import 'dart:async';
import 'package:app/app/dependency_injection.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/session_manager.dart';
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
// import 'package:app/features/auth/domain/entities/user.dart';
// import 'package:app/features/auth/domain/usecases/forgot_password_use_case.dart';
// import 'package:app/features/auth/domain/usecases/login_use_case.dart';
// import 'package:app/features/auth/domain/usecases/register_use_case.dart';
// import 'package:app/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:app/features/auth/services/auth_service.dart';
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

class AuthCreateOrganizationRequested extends AuthEvent {
  final String name;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final String? createdBy; // though it's not needed

  const AuthCreateOrganizationRequested({
    required this.name,
    this.address,
    this.phone,
    this.logoUrl,
    this.createdBy,
  });

  @override
  List<Object?> get props => [name, address, phone, logoUrl, createdBy];
}

class AuthFetchOrganizations extends AuthEvent {
  const AuthFetchOrganizations();
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
  final UserModel user;
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

class AuthNeedsProfileCompletion extends AuthState {
  final UserModel user;

  const AuthNeedsProfileCompletion({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthNeedsOrganizationCreation extends AuthState {
  final UserModel user;

  const AuthNeedsOrganizationCreation({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthNeedsOrganizationSelection extends AuthState {
  final UserModel user;

  const AuthNeedsOrganizationSelection({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthOrganizationsLoaded extends AuthState {
  final List<OrganizationModel> organizations;
  const AuthOrganizationsLoaded({required this.organizations});

  @override
  List<Object?> get props => [organizations];
}

// BLoC

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // final LoginUseCase _loginUseCase;
  // final RegisterUseCase _registerUseCase;
  final AuthService _authService;
  // final ForgotPasswordUseCase _forgotPasswordUseCase;
  // final ResetPasswordUseCase _resetPasswordUseCase;

  AuthBloc({
    // required LoginUseCase loginUseCase,
    // required RegisterUseCase registerUseCase,
    required AuthService authService,
  }) : // _loginUseCase = loginUseCase,
       //      _registerUseCase = registerUseCase,
       _authService = authService,
       super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthCreateOrganizationRequested>(_onCreateOrganization);
    on<AuthFetchOrganizations>(_onFetchOrganizations);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.login(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        // Check if user needs to complete profile
        final needsCompletion = await _authService.needsProfileCompletion();
        if (needsCompletion) {
          emit(AuthNeedsProfileCompletion(user: user));
          return;
        }

        // Check if manager needs to create organization
        if (user.role == UserRole.owner && user.organizationId == null) {
          emit(AuthNeedsOrganizationCreation(user: user));
        }
        // Check if manager needs to join organization
        if (user.role == UserRole.manager ||
            user.role == UserRole.worker && user.organizationId == null) {
          emit(AuthNeedsOrganizationSelection(user: user));
        }

        // Get organization if user has one
        final organization = await _authService.getUserOrganization();
        emit(AuthAuthenticated(user: user, organization: organization));
      } else {
        emit(const AuthError(message: 'Login failed'));
      }

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
      final user = await _authService.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
        organizationDetails: event.organizationDetails,
        organizationId: event.organizationId,
      );

      if (user != null) {
        if (user.role == UserRole.owner && user.organizationId == null) {
          emit(AuthNeedsOrganizationCreation(user: user));
          emit(
            const AuthRegistrationSuccess(
              message:
                  'Registration successful! Please check your email to confirm your account.',
            ),
          );
        }
        if (user.role == UserRole.manager ||
            user.role == UserRole.worker && user.organizationId == null) {
          emit(AuthNeedsOrganizationSelection(user: user));
          emit(
            const AuthRegistrationSuccess(
              message:
                  'Registration successful! Please check your email to confirm your account.',
            ),
          );
        }
        // if (user.role == UserRole.owner ||
        //     user.role == UserRole.manager ||
        //     user.role == UserRole.worker) {
        //   emit(AuthNeedsOrganizationCreation(user: user));
        //   emit(
        //     const AuthRegistrationSuccess(
        //       message:
        //           'Registration successful! Please check your email to confirm your account.',
        //     ),
        //   );
        // }
        emit(
          const AuthRegistrationSuccess(
            message:
                'Registration successful! Please check your email to confirm your account.',
          ),
        );
      } else {
        emit(const AuthError(message: 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      if (_authService.isLoggedIn) {
        // Check if user needs to complete profile first
        final needsCompletion = await _authService.needsProfileCompletion();

        if (needsCompletion) {
          // User exists but profile is missing - create basic user model
          final currentUser = _authService.currentUser;
          if (currentUser != null) {
            final role = UserRoleExtension.fromString(
              currentUser.userMetadata?['role'] as String? ?? 'user',
            );
            final user = UserModel(
              id: currentUser.id,
              userId: currentUser.id,
              email: currentUser.email,
              fullName: currentUser.userMetadata?['full_name'] as String,
              role: role,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            emit(AuthNeedsProfileCompletion(user: user));
            return;
          }
        }

        // Profile exists, get full user profile
        final user = await _authService.getCurrentUserProfile();
        if (user != null) {
          // Check if owner, manager, worker needs to create organization
          if (user.role == UserRole.owner && user.organizationId == null) {
            emit(AuthNeedsOrganizationCreation(user: user));
            return;
          }
          if (user.role == UserRole.manager ||
              user.role == UserRole.worker && user.organizationId == null) {
            print(user);
            emit(AuthNeedsOrganizationSelection(user: user));
            return;
          }

          // Get organization if user has one
          final organization = await _authService.getUserOrganization();
          emit(AuthAuthenticated(user: user, organization: organization));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        // Check cached session data as fallback when Supabase session is not available
        try {
          final sessionManager = DependencyInjection.get<SessionManager>();
          if (sessionManager.isLoggedIn == true &&
              sessionManager.user != null) {
            // print('✅ Using cached session data as fallback');

            final cachedUser = sessionManager.user!;
            final organization = await _authService.getUserOrganization();

            // Check if cached user needs to complete profile or create organization
            if (cachedUser.role == UserRole.manager &&
                cachedUser.organizationId == null) {
              emit(AuthNeedsOrganizationCreation(user: cachedUser));
            } else {
              emit(
                AuthAuthenticated(user: cachedUser, organization: organization),
              );
            }
            return;
          }
        } catch (e) {
          // print('⚠️ Failed to check cached session: $e');
          throw CacheException('Failed to check cache session $e');
        }

        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onCreateOrganization(
    AuthCreateOrganizationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final organization = await _authService.createOrganization(
        name: event.name,
        address: event.address,
        phone: event.phone,
        logoUrl: event.logoUrl,
      );
      // Get updated user profile
      final user = await _authService.getCurrentUserProfile();
      if (user != null) {
        emit(AuthAuthenticated(user: user, organization: organization));
      } else {
        emit(const AuthError(message: 'Failed to get updated user profile'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onFetchOrganizations(
    AuthFetchOrganizations event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authService.fetchOrganizations();
      emit(AuthOrganizationsLoaded(organizations: result));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
