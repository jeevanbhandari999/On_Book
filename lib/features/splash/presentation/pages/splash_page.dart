import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DependencyInjection.get<AuthBloc>()..add(const AuthCheckStatus()),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => SplashViewState();
}

class SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  String? _targetRoute;
  Object? _routeExtra;
  bool _animationDone = false;
  bool _authDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _animationDone = true);
        _tryNavigate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tryNavigate() {
    if (_navigated || !_animationDone || !_authDone || _targetRoute == null) {
      return;
    }
    _navigated = true;
    context.go(_targetRoute!, extra: _routeExtra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BLoC Listener for Auth Status
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading) {
                _authDone = false;
              }
              // print(state);
              if (state is AuthAuthenticated) {
                _targetRoute = RouteConstants.home;
                _routeExtra = null;
              } else if (state is AuthNeedsProfileCompletion) {
                // It's not use for now..
                _targetRoute = RouteConstants.register;
                _routeExtra = state.user;
              } else if (state is AuthNeedsOrganizationCreation) {
                _targetRoute = RouteConstants.createHotelOrganization;
                _routeExtra = state.user;
              } else if (state is AuthUnauthenticated) {
                _targetRoute = RouteConstants.login;
                _routeExtra = null;
              }
              _authDone = true;
              _tryNavigate();
            },
            child: const SizedBox.shrink(),
          ),

          // Animated Logo + Text
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      height: 90,
                      width: 90,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const Center(
                        child: Text(
                          "O",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App Name
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: const Text(
                        "OnBook",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tagline
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Connecting knowledge & people",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
