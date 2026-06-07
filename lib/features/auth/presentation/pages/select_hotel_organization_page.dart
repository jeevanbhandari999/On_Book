import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/home/presentation/widgets/animated_app_icon.dart';
import 'package:app/features/home/presentation/widgets/show_on_collapsed_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SelectHotelOrganizationPage extends StatelessWidget {
  final UserModel? user;
  const SelectHotelOrganizationPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(authService: DependencyInjection.get<AuthService>())
            ..add(const AuthFetchOrganizations()),
      child: SelectHotelOrganizationView(user: user),
    );
  }
}

class SelectHotelOrganizationView extends StatefulWidget {
  final UserModel? user;
  const SelectHotelOrganizationView({super.key, this.user});

  @override
  State<SelectHotelOrganizationView> createState() =>
      _SelectHotelOrganizationViewState();
}

class _SelectHotelOrganizationViewState
    extends State<SelectHotelOrganizationView> {
  final _searchController = TextEditingController();
  String? _selectedOrganizationId;
  String? _email;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthFetchOrganizations());
    _email = widget.user!.emailFromUserId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined organization!'),
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
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── HEADER ──────────────────────────────────────────────────
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 220,
                collapsedHeight: kToolbarHeight,
                pinned: true,
                backgroundColor: AppColors.primaryLight,
                centerTitle: true,
                title: ShowOnCollapsedSliverAppBar(
                  child: const Text(
                    'Select Organization',
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

              // ── BODY ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(UiConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Join an Organization',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().moveX(begin: -20, end: 0),

                      const SizedBox(height: 4),

                      Text(
                            'As a ${widget.user!.role == UserRole.worker ? 'STAFF' : widget.user!.role.name.toUpperCase()}, you need to join an existing organization to continue.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black),
                            textAlign: TextAlign.center,
                          )
                          .animate(delay: UiConstants.animationDelayFaster)
                          .fadeIn()
                          .moveX(begin: -20, end: 0),

                      const SizedBox(height: UiConstants.spacingLg),

                      // User info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withAlpha(75),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.supervisor_account,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.user!.role == UserRole.worker ? 'STAFF' : widget.user!.role.name.toUpperCase()}: ${widget.user!.fullName}',
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

                      // Search
                      CustomTextField(
                            label: 'Search Organizations',
                            controller: _searchController,
                            prefixIcon: const Icon(Icons.search),
                            onChanged: (value) => setState(() {}),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .moveY(begin: 20, end: 0),
                    ],
                  ),
                ),
              ),

              // ── ORGANIZATIONS LIST ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConstants.spacingMd,
                ),
                sliver: _buildOrganizationsList(state),
              ),

              // ── BOTTOM ACTIONS ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(UiConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return LoadingButton(
                            onPressed: _selectedOrganizationId != null
                                ? () => _onJoinOrganizationPressed(context)
                                : null,
                            text: 'Join Organization',
                            isLoading: state is AuthOrganizationJoining,
                          );
                        },
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: UiConstants.spacingSm),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No rush — complete setup later'),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => context.go(RouteConstants.home),
                            icon: const Icon(Icons.arrow_forward_ios, size: 14),
                            label: const Text('Skip'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),

                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                          context.go(RouteConstants.login);
                        },
                        child: const Text('Logout'),
                      ).animate().fadeIn(delay: 700.ms),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrganizationsList(AuthState state) {
    if (state is AuthLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: LoadingWidget()),
        ),
      );
    }

    if (state is AuthOrganizationsLoaded) {
      final allOrgs = state.organizations;
      final query = _searchController.text.toLowerCase();
      final filtered = query.isEmpty
          ? allOrgs
          : allOrgs
                .where((org) => org.name.toLowerCase().contains(query))
                .toList();

      final displayOrgs = query.isEmpty ? filtered.take(5).toList() : filtered;

      if (displayOrgs.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No organizations found')),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final org = displayOrgs[index];
          final isSelected = _selectedOrganizationId == org.id;

          return Card(
            elevation: isSelected ? 4 : 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Radio<String>(
                value: org.id,
                groupValue: _selectedOrganizationId,
                onChanged: (val) =>
                    setState(() => _selectedOrganizationId = val),
              ),
              title: Text(
                org.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (org.address != null)
                    Text(org.address!, style: const TextStyle(fontSize: 13)),
                  if (org.phone != null)
                    Text(org.phone!, style: const TextStyle(fontSize: 13)),
                ],
              ),
              trailing: Icon(
                Icons.business,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onTap: () => setState(() => _selectedOrganizationId = org.id),
            ),
          ).animate().fadeIn(delay: (100 * index).ms).moveY(begin: 20, end: 0);
        }, childCount: displayOrgs.length),
      );
    }

    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('Failed to load organizations')),
      ),
    );
  }

  void _onJoinOrganizationPressed(BuildContext context) {
    if (_selectedOrganizationId != null) {
      context.read<AuthBloc>().add(
        AuthJoinExistingOrganizationRequested(
          organizationId: _selectedOrganizationId!,
        ),
      );
      context.read<AuthBloc>().add(const AuthCheckStatus());
    }
  }
}
