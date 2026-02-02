import 'dart:io';

import 'package:app/app/dependency_injection.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/update_profile_picture_use_case.dart';
import 'package:app/features/profile/presentation/bloc/update_profile_picture_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileImagePage extends StatelessWidget {
  final User user;
  const ProfileImagePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateProfilePictureBloc(
        updateProfilePictureUseCase:
            DependencyInjection.get<UpdateProfilePictureUseCase>(),
        repository: DependencyInjection.get<ProfileRepository>(),
      ),
      child: ProfileImageView(user: user),
    );
  }
}

class ProfileImageView extends StatelessWidget {
  final User user;
  ProfileImageView({super.key, required this.user});

  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.fullName)),
      body: Stack(
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
                      : Text('Hello');
                },
              ),
            ),
          ),

          // overlay loader
          // if (state is ProfileAvatarUpdating || state is ProfileAvatarDeleting)
          //   Container(
          //     color: Colors.black45,
          //     child: const Center(
          //       child: CircularProgressIndicator(color: Colors.white),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
