import 'package:app/app/router/route_constants.dart';
import 'package:app/core/utils/validators/form_validators.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/usecases/login_use_case.dart';
import 'package:app/features/auth/domain/usecases/register_use_case.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/app/dependency_injection.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        // loginUseCase: DependencyInjection.get<LoginUseCase>(),
        // registerUseCase: DependencyInjection.get<RegisterUseCase>(),
        authService: DependencyInjection.get<AuthService>(),
      ),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.user;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // if (_selectedRole == UserRole.owner ||
            //     _selectedRole == UserRole.manager ||
            //     _selectedRole == UserRole.worker) {
            //   context.push(RouteConstants.createHotelOrganization, extra: state.user);
            // } else {
            //   context.go(RouteConstants.login);
            // }
          }
          if (state is AuthNeedsOrganizationCreation) {
            context.push(
              RouteConstants.createHotelOrganization,
              extra: state.user,
            );
          } else if (state is AuthLoading) {
            return;
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            context.go(RouteConstants.login);
          }
          // if (state is AuthNeedsOrganizationCreation) {
          //   context.push(
          //     RouteConstants.createHotelOrganization,
          //     extra: state.user,
          //   );
          // } else {
          //   context.go(RouteConstants.login);
          // }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Join Onbook',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account to get started',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Full Name field
                  CustomTextField(
                    label: 'Full Name',
                    controller: _fullNameController,
                    validator: FormValidators.name,
                    prefixIcon: const Icon(Icons.person_outlined),
                  ),
                  const SizedBox(height: 16),
                  // Email field
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: FormValidators.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password field
                  CustomTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => FormValidators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRoleSelector(),

                  const SizedBox(height: 32),
                  // Register button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return LoadingButton(
                        onPressed: () => _onRegisterPressed(context),
                        text: 'Register',
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: () => context.go(RouteConstants.login),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who are you ?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildRoleTile(UserRole.user),
        _buildRoleTile(UserRole.owner),
        _buildRoleTile(UserRole.manager),
        _buildRoleTile(UserRole.worker),
        // ...UserRole.values.map((role) => _buildRoleTile(role)),
      ],
    );
  }

  Widget _buildRoleTile(UserRole role) {
    final bool isSelected = _selectedRole == role;
    final roleConfig = _getRoleConfig(role);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Adaptive colors
    final backgroundColor = isSelected
        ? theme.chipTheme.backgroundColor
        : isDark
        ? theme.primaryColor.withAlpha(25)
        : Colors.grey[50];

    final borderColor = isSelected
        ? theme.primaryColor
        : isDark
        ? Colors.grey[700]
        : Colors.grey[300];

    final iconBgColor = isSelected
        ? theme.primaryColor.withAlpha(isDark ? 75 : 50)
        : isDark
        ? Colors.grey[800]
        : Colors.grey[200];

    final shadowColor = isSelected
        ? theme.primaryColor.withAlpha(isDark ? 100 : 65)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selectedRole = role),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor!,
                width: isSelected ? 2.2 : 1.2,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Icon with adaptive background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    roleConfig.icon,
                    color: isSelected
                        ? theme.primaryColor
                        : theme.iconTheme.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleConfig.title,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        roleConfig.description,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ],
                  ),
                ),

                // Radio Button
                Radio<UserRole>(
                  value: role,
                  groupValue: _selectedRole,
                  activeColor: theme.primaryColor,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return theme.primaryColor;
                    }
                    return isDark ? Colors.grey[600] : Colors.grey[400];
                  }),
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRegisterPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
        ),
      );
    }
  }
}

// Role Configuration
class _RoleConfig {
  final String title;
  final String description;
  final IconData icon;

  _RoleConfig(this.title, this.description, this.icon);
}

_RoleConfig _getRoleConfig(UserRole role) {
  switch (role) {
    case UserRole.user:
      return _RoleConfig(
        'Guest User',
        'Book rooms, join events, and explore hotels',
        Icons.person_outline,
      );
    case UserRole.owner:
      return _RoleConfig(
        'Hotel Owner',
        'Create and manage your own hotel/organization',
        Icons.business_center,
      );
    case UserRole.manager:
      return _RoleConfig(
        'Hotel Manager',
        'Manage staff, bookings, and operations',
        Icons.manage_accounts,
      );
    case UserRole.worker:
      return _RoleConfig(
        'Hotel Staff',
        'Assist in daily operations and guest services',
        Icons.support_agent,
      );
    default:
      return _RoleConfig('User', 'Select your role', Icons.help_outline);
  }
}
