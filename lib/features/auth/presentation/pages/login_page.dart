import 'package:app/core/constants/app_images.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/validators/form_validators.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/custom_svg_icon.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/home/presentation/widgets/animated_app_icon.dart';
import 'package:app/features/home/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/dependency_injection.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/app/router/route_constants.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(authService: DependencyInjection.get<AuthService>()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RouteConstants.home, extra: state.user);
          } else if (state is AuthNeedsProfileCompletion) {
            context.go(RouteConstants.register, extra: state.user);
          } else if (state is AuthNeedsOrganizationCreation) {
            context.go(
              RouteConstants.createHotelOrganization,
              extra: state.user,
            );
          } else if (state is AuthNeedsOrganizationSelection) {
            context.go(
              RouteConstants.selectHotelOrganization,
              extra: state.user,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              /// HEADER
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 220,
                collapsedHeight: kToolbarHeight,
                pinned: true,
                centerTitle: true,
                title: ShowOnCollapsedSliverAppBar(
                  child: const Text(
                    'Sign In',
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
                      background: Padding(
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
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 300.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// FORM SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(UiConstants.spacingLg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: UiConstants.spacingLg),

                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (value) => FormValidators.required(
                            value,
                            fieldName: 'Password',
                          ),
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

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(RouteConstants.forgotPassword),
                            child: const Text('Forgot Password?'),
                          ),
                        ),

                        const SizedBox(height: UiConstants.spacingMd),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: LoadingButton(
                                onPressed: () => _onLoginPressed(context),
                                text: 'Login',
                                isLoading: state is AuthLoading,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: UiConstants.spacingSm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () =>
                                  context.push(RouteConstants.register),
                              child: const Text('Sign Up'),
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

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}
