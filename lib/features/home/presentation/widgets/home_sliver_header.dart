import 'dart:math';

import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSliverHeader extends StatelessWidget {
  const HomeSliverHeader({super.key});

  static const double _collapsedHeight = kToolbarHeight + 20;

  GreetingData _getGreeting(String fullName, String role) {
    final firstName = fullName.trim().isNotEmpty
        ? fullName.split(' ').first
        : 'there';

    final hour = DateTime.now().hour;

    final headline = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : hour < 21
        ? 'Good evening'
        : 'Welcome back';

    final roleMessages = {
      'admin': ['Ready to run the show?', 'All systems are yours.'],
      'owner': ['Your listings are waiting.', 'Time to grow your business.'],
      'user': ['Let’s find something great.', 'What’s new today?'],
    };

    final generic = [
      'Let’s make today count.',
      'Something good awaits you.',
      'Glad to see you here.',
    ];

    final extras = roleMessages[role.toLowerCase()] ?? generic;

    return GreetingData(
      headline: headline,
      nameLine: '$firstName 👋',
      subtitle: extras[Random().nextInt(extras.length)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.biggest.height;
        final isCollapsed = top <= _collapsedHeight + 10;

        return BlocBuilder<
          GetCurrentUserProfileDetailsBloc,
          GetCurrentUserProfileDetailsState
        >(
          builder: (context, state) {
            if (state is GetCurrentUserProfileDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            if (state is GetCurrentUserProfileDetailsError) {
              return const SizedBox.shrink();
            }

            if (state is GetCurrentUserProfileDetailsSuccess) {
              final user = state.user;

              final greetingData = _getGreeting(user.fullName, user.role.name);

              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(UiConstants.radiusXl),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: UiConstants.spacingLg),
                    child: AnimatedOpacity(
                      opacity: isCollapsed ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greetingData.headline,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    greetingData.nameLine,
                                    key: ValueKey(greetingData.nameLine),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: UiConstants.spacingXs),
                                Text(
                                  greetingData.subtitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: UiConstants.spacingSm),
                                Text(
                                  user.role.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 1.1,
                                    color: Colors.white,
                                  ),
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
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class GreetingData {
  final String headline;
  final String nameLine;
  final String subtitle;

  GreetingData({
    required this.headline,
    required this.nameLine,
    required this.subtitle,
  });
}
