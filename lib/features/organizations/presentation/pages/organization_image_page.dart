import 'dart:io';
import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/app_bar_popup_menu.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:app/features/organizations/domain/usecases/can_manage_orgnization_use_case.dart';
import 'package:app/features/organizations/domain/usecases/delete_organization_logo_use_case.dart';
import 'package:app/features/organizations/domain/usecases/get_organization_members_use_case.dart';
import 'package:app/features/organizations/domain/usecases/get_user_organization_detail_use_case.dart';
import 'package:app/features/organizations/domain/usecases/update_organization_logo_use_case.dart';
import 'package:app/features/organizations/presentation/bloc/get_user_organization_details_bloc.dart';
import 'package:app/features/organizations/presentation/bloc/update_organization_logo_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class OrganizationImagePage extends StatelessWidget {
  final Organization organization;
  const OrganizationImagePage({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    final authService = DependencyInjection.get<AuthService>();
    final userId = authService.getCurrentUserId();

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetUserOrganizationDetailsBloc(
                getUserOrganizationDetailUseCase:
                    DependencyInjection.get<GetUserOrganizationDetailUseCase>(),
                getOrganizationMembersUseCase:
                    DependencyInjection.get<GetOrganizationMembersUseCase>(),
                canManageOrganizationUseCase:
                    DependencyInjection.get<CanManageOrganizationUseCase>(),
              )..add(
                GetUserOrganizationDetailsRequested(
                  organizationId: organization.id,
                  userId: userId,
                ),
              ),
        ),
        BlocProvider(
          create: (context) => UpdateOrganizationLogoBloc(
            updateOrganizationLogoUseCase:
                DependencyInjection.get<UpdateOrganizationLogoUseCase>(),
            deleteOrganizationLogoUseCase:
                DependencyInjection.get<DeleteOrganizationLogoUseCase>(),
            repository: DependencyInjection.get<OrganizationRepository>(),
          ),
        ),
      ],
      child: OrganizationImageView(organization: organization, userId: userId),
    );
  }
}

class OrganizationImageView extends StatelessWidget {
  final Organization organization;
  final String userId;
  OrganizationImageView({
    super.key,
    required this.organization,
    required this.userId,
  });

  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(organization.name),
        actions: organization.createdBy != userId
            ? null
            : [
                AppPopupMenu(
                  items: [
                    AppPopupMenuItem(
                      value: 'edit',
                      label: 'Edit',
                      icon: Icons.edit_sharp,
                      onTap: () {
                        _showImagePickerOptions(context);
                      },
                    ),
                    AppPopupMenuItem(
                      value: 'refresh',
                      label: 'Refresh',
                      icon: Icons.refresh,
                      onTap: () {
                        _onRefresh(context);
                      },
                    ),
                    AppPopupMenuItem(
                      value: 'delete',
                      label: 'Delete',
                      icon: Icons.delete,
                      onTap: () {
                        _onDeleteAvatarImage(context);
                      },
                      isDistructive: true,
                    ),
                  ],
                ),
              ],
      ),
      body:
          BlocListener<UpdateOrganizationLogoBloc, UpdateOrganizationLogoState>(
            listener: (context, state) {
              if (state is UpdateOrganizationLogoError) {
                // print(state.message);
                _showErrorSnackBar(context, state.message);
              }
            },
            child:
                BlocBuilder<
                  UpdateOrganizationLogoBloc,
                  UpdateOrganizationLogoState
                >(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        InteractiveViewer(
                          child: Center(
                            child: ValueListenableBuilder<File?>(
                              valueListenable: _selectedImage,
                              builder: (context, file, _) {
                                if (file != null) {
                                  return Image.file(file, fit: BoxFit.contain);
                                }
                                return organization.logoUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: organization.logoUrl!,
                                      )
                                    : const Text('Hello');
                              },
                            ),
                          ),
                        ),

                        // overlay loader
                        if (state is OrganizationLogoUpdating ||
                            state is OrganizationLogoDeleting)
                          Container(
                            color: Colors.black45,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ValueListenableBuilder<File?>(
        valueListenable: _selectedImage,
        builder: (context, file, _) {
          if (file == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () => _onCancelAvatar(context, file),
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: UiConstants.spacingMd),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Save',
                    onPressed: () => _onSaveAvatar(context, file),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSaveAvatar(BuildContext context, File file) {
    context.read<UpdateOrganizationLogoBloc>().add(
      UpdateOrganizationLogoRequested(
        organizationId: organization.id,
        newLogoFile: file,
        existingLogoToDelete: organization.logoUrl,
      ),
    );
    // for real time view //
    _selectedImage.value = file;
  }

  void _onCancelAvatar(BuildContext context, File file) {
    _selectedImage.value = null;
  }

  Future<void> _onDeleteAvatarImage(BuildContext context) async {
    context.read<UpdateOrganizationLogoBloc>().add(
      DeleteOrganizationLogoRequested(
        organizationId: organization.id,
        logoUrlToDelete: organization.logoUrl!,
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) async {
    await CustomBottomSheet.show(
      context: context,
      // title: 'Add Image',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            subtitle: const Text('Use camera to take a new photo'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage(context, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            subtitle: const Text('Select from your photo gallery'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage(context, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  void _pickImage(BuildContext context, ImageSource source) async {
    final imagePicker = ImagePicker();
    try {
      final pickedFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Validate image
        final validationError = await _validateImage(file);
        if (validationError != null) {
          if (context.mounted) {
            _showErrorSnackBar(context, validationError);
            return;
          }
        }
        _selectedImage.value = file;
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to pick image: ${e.toString()}');
      }
    }
  }

  Future<String?> _validateImage(File file) async {
    try {
      // Check file size (max 10MB)
      const maxSizeBytes = 10 * 1024 * 1024;
      final fileSize = await file.length();

      if (fileSize > maxSizeBytes) {
        return 'Image size must be less than 10MB';
      }

      // Check file extension
      final extension = file.path.toLowerCase().split('.').last;
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

      if (!allowedExtensions.contains(extension)) {
        return 'Only JPG, PNG, and WebP images are allowed';
      }

      return null;
    } catch (e) {
      return 'Failed to validate image: ${e.toString()}';
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRefresh(BuildContext context) {
    context.read<GetUserOrganizationDetailsBloc>().add(
      GetUserOrganizationDetailsRequested(
        organizationId: organization.id,
        userId: userId,
      ),
    );
  }
}
