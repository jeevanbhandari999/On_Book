import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/home/presentation/widgets/animated_app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class SplashViewState extends State<SplashView> {
  String? _targetRoute;
  Object? _routeExtra;

  bool _animationDone = false;
  bool _authDone = false;
  bool _navigated = false;

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
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading) {
                _authDone = false;
              }
              if (state is AuthAuthenticated) {
                _targetRoute = RouteConstants.home;
                _routeExtra = state.user;
              } else if (state is AuthNeedsProfileCompletion) {
                _targetRoute = RouteConstants.register;
                _routeExtra = state.user;
              } else if (state is AuthNeedsOrganizationCreation) {
                _targetRoute = RouteConstants.createHotelOrganization;
                _routeExtra = state.user;
              } else if (state is AuthNeedsOrganizationSelection) {
                _targetRoute = RouteConstants.selectHotelOrganization;
                _routeExtra = state.user;
              } else if (state is AuthUnauthenticated) {
                _targetRoute = RouteConstants.login;
              }

              _authDone = true;
              _tryNavigate();
            },
            child: const SizedBox.shrink(),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                      width: 150,
                      height: 150,
                      child: AnimatedAppIcon(),
                    )
                    .animate(
                      onComplete: (_) {
                        _animationDone = true;
                        _tryNavigate();
                      },
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: UiConstants.animationSlowest,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: UiConstants.animationSlow),

                const SizedBox(height: UiConstants.spacingSm),

                const Text(
                      "OnBook",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    )
                    .animate()
                    .slideY(
                      begin: 1,
                      duration: UiConstants.animationSlowest,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(),

                const SizedBox(height: 6),

                const Text(
                  "BOOK SMARTER, LIVE BETTER",
                  style: TextStyle(fontSize: 14, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
