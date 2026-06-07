import 'package:app/app/dependency_injection.dart';

import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/validators/form_validators.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/home/presentation/widgets/animated_app_icon.dart';
import 'package:app/features/home/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateHotelOrganizationPage extends StatelessWidget {
  final UserModel? user;
  const CreateHotelOrganizationPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.get<AuthBloc>(),
      child: CreateHotelOrganizationView(user: user),
    );
  }
}

class CreateHotelOrganizationView extends StatefulWidget {
  final UserModel? user;
  const CreateHotelOrganizationView({super.key, this.user});

  @override
  State<CreateHotelOrganizationView> createState() =>
      _CreateHotelOrganizationViewState();
}

class _CreateHotelOrganizationViewState
    extends State<CreateHotelOrganizationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _email;

  @override
  void initState() {
    super.initState();
    _email = widget.user!.emailFromUserId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Organization created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go(RouteConstants.home, extra: state.user);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            // ── HEADER — matches LoginPage exactly ──────────────────────────
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 220,
              collapsedHeight: kToolbarHeight,
              pinned: true,
              backgroundColor: AppColors.primaryLight,
              centerTitle: true,
              title: ShowOnCollapsedSliverAppBar(
                child: const Text(
                  'Create Organization',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 0.3,
                    color: Colors.black,
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
                                  color: Colors.black,
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
                              color: Colors.black,
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

            // ── FORM ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(UiConstants.spacingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Create Your Organization',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().moveX(begin: -20, end: 0),

                      const SizedBox(height: 4),

                      Text(
                            'Set up your organization to start managing posts and events',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black),
                            textAlign: TextAlign.center,
                          )
                          .animate(delay: UiConstants.animationDelayFaster)
                          .fadeIn()
                          .moveX(begin: -20, end: 0),

                      const SizedBox(height: UiConstants.spacingLg),

                      // Owner info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.user!.role.name.toUpperCase()}: ${widget.user!.fullName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    _email ?? 'Not Found',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),

                      const SizedBox(height: UiConstants.spacingMd),

                      // Organization Name
                      CustomTextField(
                            label: 'Organization Name *',
                            controller: _nameController,
                            validator: (value) => FormValidators.required(
                              value,
                              fieldName: 'Organization name',
                            ),
                            prefixIcon: const Icon(Icons.business_outlined),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .moveY(begin: 20, end: 0),

                      const SizedBox(height: UiConstants.spacingMd),

                      // Address
                      CustomTextField(
                            label: 'Address',
                            controller: _addressController,
                            maxLines: 3,
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.trim().length < 5) {
                                return 'Address must be at least 5 characters';
                              }
                              return null;
                            },
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .moveY(begin: 20, end: 0),

                      const SizedBox(height: UiConstants.spacingMd),

                      // Phone
                      CustomTextField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return FormValidators.phoneNumber(value);
                              }
                              return null;
                            },
                            prefixIcon: const Icon(Icons.phone_outlined),
                          )
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .moveY(begin: 20, end: 0),

                      const SizedBox(height: UiConstants.spacingLg),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withAlpha(80)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Organization Benefits:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '• Create and manage your hotel\n'
                                    '• Organize events, posts and activities\n'
                                    '• Invite manager and staff to help',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.blue[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: UiConstants.spacingLg),

                      // Create button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: LoadingButton(
                              onPressed: () =>
                                  _onCreateOrganizationPressed(context),
                              text: 'Create Organization',
                              isLoading: state is AuthLoading,
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 700.ms),

                      const SizedBox(height: UiConstants.spacingSm),

                      // Logout
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                          context.go(RouteConstants.login);
                        },
                        child: const Text('Logout'),
                      ).animate().fadeIn(delay: 800.ms),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreateOrganizationPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthCreateOrganizationRequested(
          name: _nameController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        ),
      );
    }
  }
}
