import 'dart:math';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/home/presentation/cubit/location_cubit.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      'user': ['Let\'s find something great.', 'What\'s new today?'],
    };

    final generic = [
      'Let\'s make today count.',
      'Something good awaits you.',
      'Glad to see you here.',
    ];

    final extras = roleMessages[role.toLowerCase()] ?? generic;

    return GreetingData(
      headline: headline,
      nameLine: firstName,
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
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha(100),
                          Theme.of(context).colorScheme.primary.withAlpha(150),
                          Theme.of(context).colorScheme.primary.withAlpha(200),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
                        padding: const EdgeInsets.fromLTRB(16, 85, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                          greetingData.headline,
                                          style: const TextStyle(
                                            // fontSize:
                                            //     MediaQuery.of(context).size.width *
                                            //     0.06,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        )
                                        .animate()
                                        .slideY(
                                          begin: -1.5,
                                          duration: UiConstants.animationSlow,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .fadeIn(
                                          duration: UiConstants.animationSlow,
                                        ),
                                    const SizedBox(
                                      height: UiConstants.spacingSm,
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child:
                                          Row(
                                                children: [
                                                  Text(
                                                    greetingData.nameLine,
                                                    style: const TextStyle(
                                                      fontSize: 23,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.waving_hand,
                                                    size: 22,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              )
                                              .animate()
                                              .slideX(
                                                begin: -1,
                                                duration:
                                                    UiConstants.animationNormal,
                                                curve: Curves.easeOutCubic,
                                              )
                                              .fadeIn(
                                                duration:
                                                    UiConstants.animationNormal,
                                              ),
                                    ),
                                    const SizedBox(
                                      height: UiConstants.spacingSm,
                                    ),
                                    Text(
                                          greetingData.subtitle,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        )
                                        .animate(
                                          delay: UiConstants.animationFast,
                                        )
                                        .slideY(
                                          begin: 0.5,
                                          duration: UiConstants.animationNormal,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .fadeIn(
                                          duration: UiConstants.animationNormal,
                                        ),

                                    // Add this inside the Column after greetingData.subtitle Text widget:
                                    const SizedBox(
                                      height: UiConstants.spacingSm,
                                    ),

                                    BlocBuilder<LocationCubit, LocationState>(
                                      builder: (context, state) {
                                        if (state is LocationGranted &&
                                            state.cityName.isNotEmpty) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                state.cityName,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ).animate().fadeIn();
                                        }

                                        if (state is LocationDenied) {
                                          return GestureDetector(
                                            onTap: () =>
                                                _showLocationSheetFromHeader(
                                                  context,
                                                ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.location_off,
                                                  size: 14,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Location off',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ).animate().fadeIn();
                                        }

                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(width: UiConstants.spacingSm),
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

  void _showLocationSheetFromHeader(BuildContext context) {
    // Reset state so sheet shows again
    context.read<LocationCubit>().emit(const LocationShouldPrompt());
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<LocationCubit>(),
        child: const _LocationPermissionSheet(),
      ),
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

class _LocationPermissionSheet extends StatelessWidget {
  const _LocationPermissionSheet();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationState>(
      listener: (context, state) {
        if (state is LocationGranted || state is LocationDenied) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Allow Location Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We use your location to show nearby places and personalize your experience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            BlocBuilder<LocationCubit, LocationState>(
              builder: (context, state) {
                final isLoading = state is LocationLoading;
                return Column(
                  children: [
                    // Allow button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => context
                                  .read<LocationCubit>()
                                  .requestLocation(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Allow Location',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Deny button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.read<LocationCubit>().dismiss(),
                        child: Text(
                          'Not Now',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
