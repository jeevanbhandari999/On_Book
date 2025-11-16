import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SelectHotelOrganizationPage extends StatelessWidget {
  final UserModel? user;
  const SelectHotelOrganizationPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        // loginUseCase: DependencyInjection.get<LoginUseCase>(),
        // registerUseCase: DependencyInjection.get<RegisterUseCase>(),
        authService: DependencyInjection.get<AuthService>(),
      )..add(const AuthFetchOrganizations()),
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
    // Fetch organizations on init
    context.read<AuthBloc>().add(const AuthFetchOrganizations());
    _email = widget.user!.emailFromUserId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mock organizations - in real app, this would come from a service
  // final List<OrganizationModel> _organizations = [
  //   OrganizationModel(
  //     id: '1',
  //     name: 'Tech Solutions Inc.',
  //     logoUrl: null,
  //     address: '123 Tech Street, Silicon Valley',
  //     phone: '+1-555-0123',
  //     createdBy: 'Jeevan',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   OrganizationModel(
  //     id: '2',
  //     name: 'Green Earth Foundation',
  //     logoUrl: null,
  //     address: '456 Green Ave, Eco City',
  //     phone: '+1-555-0456',
  //     createdBy: 'Jeevan',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   OrganizationModel(
  //     id: '3',
  //     name: 'Community Health Center',
  //     logoUrl: null,
  //     address: '789 Health Blvd, Wellness Town',
  //     phone: '+1-555-0789',
  //     createdBy: 'Jeevan',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  // ];

  // List<OrganizationModel> get _filteredOrganizations {
  //   if (_searchController.text.isEmpty) {
  //     return _organizations;
  //   }
  //   return _organizations
  //       .where(
  //         (org) => org.name.toLowerCase().contains(
  //           _searchController.text.toLowerCase(),
  //         ),
  //       )
  //       .toList();
  // }

  @override
  Widget build(BuildContext context) {
    // print('the logged in user is : ${widget.user}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Organization'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined organization!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go(RouteConstants.home);
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Title and description
              Text(
                'Join an Organization',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'As a ${widget.user!.role == UserRole.worker ? 'STAFF' : widget.user!.role.name.toUpperCase()}, you need to join an existing organization to continue.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // User info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            style: Theme.of(context).textTheme.titleMedium
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
              ),
              const SizedBox(height: 24),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextField(
                  label: 'Search Organizations',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),

              // Organizations list
              Expanded(child: _buildOrganizationsList(state)),

              // Join button
              Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return LoadingButton(
                      onPressed: _selectedOrganizationId != null
                          ? () => _onJoinOrganizationPressed(context)
                          : null,
                      text: 'Join Organization',
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
              ),

              // Skip option, as a manager or staff, he/she might have fired from the organization and other problems
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
              ),

              // Logout option
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go(RouteConstants.login);
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrganizationsList(AuthState state) {
    // print(_selectedOrganizationId);
    if (state is AuthLoading) {
      return const Center(child: LoadingWidget());
    }
    if (state is AuthOrganizationsLoaded) {
      final allOrgs = state.organizations;
      final query = _searchController.text.toLowerCase();
      final filtered = query.isEmpty
          ? allOrgs
          : allOrgs
                .where(
                  (org) =>
                      org.name.toLowerCase().contains(query) ||
                      org.address!.toLowerCase().contains(query),
                )
                .toList();

      final displayOrgs = query.isEmpty ? filtered.take(5).toList() : filtered;

      if (displayOrgs.isEmpty) {
        return const Center(child: Text('No organizations found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayOrgs.length,
        itemBuilder: (context, index) {
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
          );
        },
      );
    }

    return const Center(child: Text('Failed to load organizations'));
  }

  void _onJoinOrganizationPressed(BuildContext context) {
    if (_selectedOrganizationId != null) {
      // In a real app, this would call a service to join the organization
      // For now, we'll simulate completing the profile with the organization ID
      context.read<AuthBloc>().add(
        AuthJoinExistingOrganizationRequested(
          organizationId: _selectedOrganizationId!,
        ),
      );
      context.read<AuthBloc>().add(const AuthCheckStatus());
    }
  }
}
