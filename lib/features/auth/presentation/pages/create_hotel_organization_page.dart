import 'package:app/app/dependency_injection.dart';
import 'dart:io';

import 'package:app/app/router/route_constants.dart';
import 'package:app/core/utils/validators/form_validators.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
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
  final _logoUrlController = TextEditingController();

  // Image upload state
  File? _pickedLogo;
  String? _uploadedLogoUrl;
  final _isUploadingLogo = false;
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
    _logoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organization'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Organization created successfully!'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Welcome message
                Text(
                  'Create Your Organization',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your organization to start managing posts and events',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

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

                // Organization Name field
                CustomTextField(
                  label: 'Organization Name *',
                  controller: _nameController,
                  validator: (value) => FormValidators.required(
                    value,
                    fieldName: 'Organization name',
                  ),
                  prefixIcon: const Icon(Icons.business_outlined),
                ),
                const SizedBox(height: 16),

                // Logo Upload Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organization Logo',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),

                    // Logo Preview and Upload Button
                    Center(
                      child: Column(
                        children: [
                          // Logo Preview
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _uploadedLogoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _uploadedLogoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.business,
                                              size: 50,
                                              color: Colors.grey[400],
                                            );
                                          },
                                    ),
                                  )
                                : _pickedLogo != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_pickedLogo!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.business,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Upload Button
                          ElevatedButton.icon(
                            onPressed: _isUploadingLogo
                                ? null
                                : _pickAndUploadLogo,
                            icon: _isUploadingLogo
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload),
                            label: Text(
                              _isUploadingLogo ? 'Uploading...' : 'Upload Logo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Organization Address field
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
                    return null; // Optional field
                  },
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),

                // Organization Phone field
                CustomTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return FormValidators.phoneNumber(value);
                    }
                    return null; // Optional field
                  },
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),

                const SizedBox(height: 24),

                // Info message
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
                              style: Theme.of(context).textTheme.titleSmall
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
                ),
                const SizedBox(height: 24),

                // Create Organization button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return LoadingButton(
                      onPressed: () => _onCreateOrganizationPressed(context),
                      text: 'Create Organization',
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Logout option
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go(RouteConstants.login);
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      // Pick image from gallery
      // final XFile? pickedLogo = await ImageUploadService.pickImage();
      // if (pickedLogo == null) return;

      // setState(() {
      //   _pickedLogo = pickedLogo;
      //   _isUploadingLogo = true;
      // });

      // // For organization logos, we need to create the organization first
      // // So we'll store the picked file and upload it after organization creation
      // // For now, we'll just show a preview
      // setState(() {
      //   _isUploadingLogo = false;
      // });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Logo will be uploaded when organization is created.'),
      //     backgroundColor: Colors.blue,
      //   ),
      // );
    } catch (e) {
      // setState(() {
      //   _isUploadingLogo = false;
      // });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error picking logo: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
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
          logoUrl:
              _uploadedLogoUrl ??
              (_logoUrlController.text.trim().isEmpty
                  ? null
                  : _logoUrlController.text.trim()),
        ),
      );
    }
  }
}
