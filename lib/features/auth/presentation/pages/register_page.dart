import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/app_images.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/validators/form_validators.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/custom_svg_icon.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/home/presentation/widgets/animated_app_icon.dart';
import 'package:app/features/profile/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/app/dependency_injection.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(authService: DependencyInjection.get<AuthService>()),
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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
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
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 220,
                collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
                pinned: true,
                centerTitle: true,
                title: ShowOnCollapsedSliverAppBar(
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                ),
                flexibleSpace: Stack(
                  children: [
                    Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,

                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(UiConstants.radiusXl),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .slideY(
                          begin: -2,
                          duration: UiConstants.animationSlow,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: UiConstants.animationSlow),
                    FlexibleSpaceBar(
                      background: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(UiConstants.spacingLg),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: UiConstants.spacingXl),

                              SizedBox(
                                width: 100,
                                height: 100,
                                child: const AnimatedAppIcon()
                                    .animate()
                                    .scaleXY(
                                      begin: 0.8,
                                      end: 1.1,
                                      duration: UiConstants.animationSlowest,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .fadeIn(),
                              ),
                              const SizedBox(height: UiConstants.spacingSm),
                              const Text(
                                    "OnBook",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.3,
                                      color: Colors.white,
                                    ),
                                  )
                                  .animate()
                                  .slideY(
                                    begin: 1,
                                    duration: UiConstants.animationSlowest,
                                    curve: Curves.easeOutCubic,
                                  )
                                  .fadeIn(),
                              const Text(
                                "BOOK SMARTER, LIVE BETTER",
                                style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(delay: 300.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// FORM
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),

                        Text(
                          'Join OnBook',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),

                        Text(
                          'Create your account to get started',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: UiConstants.spacingLg),

                        /// FULL NAME
                        CustomTextField(
                          label: 'Full Name',
                          controller: _fullNameController,
                          validator: FormValidators.name,
                          prefixIcon: const Icon(Icons.person_outlined),
                        ),

                        const SizedBox(height: 16),

                        /// EMAIL
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),

                        const SizedBox(height: 16),

                        /// PASSWORD
                        CustomTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: FormValidators.password,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: CustomSvgIcon(
                              path: _obscurePassword
                                  ? AppImages.eyeOpenIcon
                                  : AppImages.eyeCloseIcon,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),

                        const SizedBox(height: UiConstants.spacingMd),

                        /// CONFIRM PASSWORD
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
                            icon: CustomSvgIcon(
                              path: _obscureConfirmPassword
                                  ? AppImages.eyeOpenIcon
                                  : AppImages.eyeCloseIcon,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),

                        const SizedBox(height: UiConstants.spacingMd),

                        /// ROLE SELECTOR
                        _buildRoleSelector(),

                        const SizedBox(height: UiConstants.spacingMd),

                        /// REGISTER BUTTON
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return LoadingButton(
                              onPressed: () => _onRegisterPressed(context),
                              text: 'Register',
                              isLoading: state is AuthLoading,
                            );
                          },
                        ),

                        const SizedBox(height: UiConstants.spacingSm),

                        /// LOGIN LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? '),
                            TextButton(
                              onPressed: () =>
                                  context.push(RouteConstants.login),
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoleSelector() {
    return RadioGroup<UserRole>(
      groupValue: _selectedRole,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedRole = value);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Who are you ?'),
          const SizedBox(height: 12),
          _buildRoleTile(UserRole.user),
          _buildRoleTile(UserRole.owner),
          _buildRoleTile(UserRole.manager),
          _buildRoleTile(UserRole.worker),
        ],
      ),
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
      child: SectionContainer(
        padding: const EdgeInsets.only(
          top: UiConstants.spacingMd,
          left: UiConstants.spacingMd,
          bottom: UiConstants.spacingMd,
          right: UiConstants.spacingXs,
        ),
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        onTap: () => setState(() => _selectedRole = role),
        gradientColor: isSelected
            ? LinearGradient(
                colors: [?backgroundColor, ?backgroundColor, ?backgroundColor],
              )
            : null,
        shadows: isSelected
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ]
            : null,
        child: Row(
          children: [
            // Icon with adaptive background
            Container(
              padding: const EdgeInsets.all(UiConstants.spacingSm),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(UiConstants.radiusSm),
              ),
              child: Icon(
                roleConfig.icon,
                color: isSelected ? theme.primaryColor : theme.iconTheme.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(roleConfig.title),
                  Text(
                    roleConfig.description,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Radio<UserRole>(
              value: role,
              activeColor: theme.primaryColor,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.primaryColor;
                }
                return isDark ? Colors.grey[600] : Colors.grey[400];
              }),
            ),
          ],
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
