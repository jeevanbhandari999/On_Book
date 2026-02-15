import 'dart:io';

import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/app_bar_popup_menu.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/delete_profile_picture_use_case.dart';
import 'package:app/features/profile/domain/usecases/update_profile_picture_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:app/features/profile/presentation/bloc/update_profile_picture_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePage extends StatelessWidget {
  final User user;
  const ProfileImagePage({super.key, required this.user});

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
          create: (context) => UpdateProfilePictureBloc(
            updateProfilePictureUseCase:
                DependencyInjection.get<UpdateProfilePictureUseCase>(),
            deleteProfilePictureUseCase:
                DependencyInjection.get<DeleteProfilePictureUseCase>(),
            repository: DependencyInjection.get<ProfileRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => GetCurrentUserProfileDetailsBloc(
            getCurrentUserProfileUseCase: DependencyInjection.get(),
          ),
        ),
      ],
      child: ProfileImageView(user: user, userId: userId),
    );
  }
}

class ProfileImageView extends StatelessWidget {
  final User user;
  final String userId;
  ProfileImageView({super.key, required this.user, required this.userId});

  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName),
        actions: user.userId != userId
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
      body: BlocListener<UpdateProfilePictureBloc, UpdateProfilePictureState>(
        listener: (context, state) {
          if (state is UpdateProfilePictureError) {
            print(state.message);
            _showErrorSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<UpdateProfilePictureBloc, UpdateProfilePictureState>(
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
                        return user.imageUrl != null
                            ? CachedNetworkImage(imageUrl: user.imageUrl!)
                            : const Text('Hello');
                      },
                    ),
                  ),
                ),

                // overlay loader
                if (state is ProfilePictureUpdating ||
                    state is ProfilePictureDeleting)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
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
    context.read<UpdateProfilePictureBloc>().add(
      UpdateProfilePictureRequested(
        userId: user.userId,
        newPictureFile: file,
        existingImageUrlToDelete: user.imageUrl,
      ),
    );
    // for real time view //
    _selectedImage.value = file;
  }

  void _onCancelAvatar(BuildContext context, File file) {
    _selectedImage.value = null;
  }

  Future<void> _onDeleteAvatarImage(BuildContext context) async {
    context.read<UpdateProfilePictureBloc>().add(
      DeleteProfilePictureRequested(
        userId: user.userId,
        pictureUrlToDelete: user.imageUrl!,
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
    context.read<GetCurrentUserProfileDetailsBloc>().add(
      GetCurrentUserProfileDetailsRequested(userId: user.userId),
    );
  }
}
