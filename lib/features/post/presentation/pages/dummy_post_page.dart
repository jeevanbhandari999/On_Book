import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/router/route_constants.dart';

class DummyPostPage extends StatelessWidget {
  final UserModel user;
  const DummyPostPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(200),
                              AppColors.primary.withAlpha(150),
                              AppColors.primary.withAlpha(77),
                              AppColors.primary.withAlpha(100),
                              AppColors.primary.withAlpha(150),
                              AppColors.primary.withAlpha(200),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(77),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Colors.black54,
                        ),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                        delay: 100.ms,
                      )
                      .then()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 1.0,
                        end: 1.06,
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(height: 32),
                  const Text(
                    'Access Restricted',
                    style: TextStyle(fontSize: 28),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 12),
                  const Text(
                    'Only hotel owners and managers can create posts.\nYou can still view what’s already shared!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  const SizedBox(height: 36),
                  CustomButton(
                    text: 'Return to Home',
                    onPressed: () => context.go(RouteConstants.home),
                    icon: const Icon(Icons.home_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
