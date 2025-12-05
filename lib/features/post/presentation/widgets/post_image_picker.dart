import 'dart:io';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/core/constants/ui_constants.dart';

class PostMediaPicker extends StatelessWidget {
  final String? existingPrimaryImageUrl;
  final List<String>? existingAdditionalImage;
  final File? primaryImageFile;
  final List<File> additionalImages;
  final File? videoFile;
  final Map<File, double>? uploadProgress;
  final String? errorMessage;

  final Function(File file) onPrimaryImagePicked;
  final Function(File file) onImageAdded;
  final Function(int index) onImageRemoved;
  final Function(String) onExistingImageRemoved;
  final Function(File file) onVideoPicked;
  final Function() onVideoRemoved;

  final bool enabled;
  final int maxAdditionalImages;

  const PostMediaPicker({
    super.key,
    this.existingPrimaryImageUrl,
    this.existingAdditionalImage,
    this.primaryImageFile,
    this.additionalImages = const [],

    this.videoFile,
    this.uploadProgress,
    this.errorMessage,
    required this.onPrimaryImagePicked,
    required this.onImageAdded,
    required this.onImageRemoved,
    required this.onExistingImageRemoved,
    required this.onVideoPicked,
    required this.onVideoRemoved,
    this.enabled = true,
    this.maxAdditionalImages = 5,
  });

  int get totalImages {
    if (existingAdditionalImage != null) {
      return additionalImages.length +
          existingAdditionalImage!.length +
          (primaryImageFile != null ? 1 : 0);
    } else {
      return additionalImages.length + (primaryImageFile != null ? 1 : 0);
    }
  }

  bool get canAddImage => totalImages < maxAdditionalImages && enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryImageSection(
          errorMessage: errorMessage,
          extingPrimaryImage: existingPrimaryImageUrl,
          imageFile: primaryImageFile,
          onPick: () => _showImagePickerSheet(context, isPrimary: true),
          enabled: enabled,
        ),
        const SizedBox(height: UiConstants.spacingMd),

        _AdditionalImagesSection(
          existingImages: existingAdditionalImage,
          images: additionalImages,
          uploadProgress: uploadProgress,
          onAdd: () => _showImagePickerSheet(context, isPrimary: false),
          onRemove: onImageRemoved,
          onRemoveExisting: onExistingImageRemoved,
          canAddMore: canAddImage,
          maxImages: maxAdditionalImages,
          enabled: enabled,
        ),
        const SizedBox(height: UiConstants.spacingMd),

        _VideoSection(
          videoFile: videoFile,
          uploadProgress: uploadProgress?[videoFile],
          onPick: () => _showVideoPickerSheet(context),
          onRemove: onVideoRemoved,
          enabled: enabled && videoFile == null,
        ),
        const SizedBox(height: UiConstants.spacingSm),
      ],
    );
  }

  // Image picker bottom sheet
  Future<void> _showImagePickerSheet(
    BuildContext context, {
    required bool isPrimary,
  }) async {
    CustomBottomSheet.show(
      context: context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              subtitle: const Text('Use camera to take a new photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(context, ImageSource.camera, isPrimary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your photo gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(context, ImageSource.gallery, isPrimary);
              },
            ),

            if (!isPrimary)
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Select Multiple'),
                subtitle: const Text('Choose multiple images at once'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMultipleImages(context, isPrimary: isPrimary);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
    bool? isPrimary,
  ) async {
    try {
      final imagePicker = ImagePicker();
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
          _showError(context, validationError);
          return;
        }

        if (isPrimary != null && isPrimary) {
          // final url = await _uploadImageToSupabase(file);
          onPrimaryImagePicked(file);
          // print('file: $file');
        } else {
          onImageAdded(file);
        }
      }
    } catch (e) {
      _showError(context, 'Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _pickVideo(BuildContext context, ImageSource source) async {
    try {
      final videoPicked = ImagePicker();
      final pickedFile = await videoPicked.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 1),
      );

      if (pickedFile != null && context.mounted) {
        final file = File(pickedFile.path);
        final error = await _validateVideo(file);
        if (error != null) {
          _showError(context, error);
          return;
        }
        onVideoPicked(file);
      }
    } catch (e) {
      _showError(context, 'Failed to pick image: ${e.toString()}');
    }
  }

  //Multiple image picker (Only for additional images)
  Future<void> _pickMultipleImages(
    BuildContext context, {
    required bool isPrimary,
  }) async {
    if (isPrimary) return; // Should never happen

    final remainingSlots = maxAdditionalImages - totalImages;
    if (remainingSlots <= 0) {
      _showError(context, 'Maximum additional images reached');
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFiles.isEmpty || !context.mounted) return;

    final filesToAdd = pickedFiles.take(remainingSlots).toList();
    int addedCount = 0;

    for (final picked in filesToAdd) {
      final file = File(picked.path);
      final error = await _validateImage(file);
      if (error != null) {
        _showError(context, '${picked.name}: $error');
        continue;
      }
      onImageAdded(file);
      addedCount++;
    }

    if (pickedFiles.length > remainingSlots) {
      _showError(context, 'Only $remainingSlots images added due to limit');
    } else if (addedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount images added'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Video picker
  Future<void> _showVideoPickerSheet(BuildContext context) async {
    final source = CustomBottomSheet.show(
      context: context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              subtitle: const Text('Record video through your device'),
              onTap: () {
                Navigator.of(context).pop();
                _pickVideo(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your video gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickVideo(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Validation and upload
  Future<String?> _validateImage(File file) async {
    final size = await file.length();
    if (size > 10 * 1024 * 1024) return 'Image must be < 10MB';

    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      return 'Only JPG, PNG, WebP allowed';
    }
    return null;
  }

  Future<String?> _validateVideo(File file) async {
    final size = await file.length();
    if (size > 100 * 1024 * 1024) return 'Video must be < 100MB';

    final ext = file.path.split('.').last.toLowerCase();
    if (!['mp4', 'mov', 'avi'].contains(ext)) {
      return 'Only MP4, MOV, AVI allowed';
    }
    return null;
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}

// Primary image section
class _PrimaryImageSection extends StatelessWidget {
  final String? extingPrimaryImage;
  final File? imageFile;
  final VoidCallback onPick;
  final bool enabled;
  final String? errorMessage;

  const _PrimaryImageSection({
    this.extingPrimaryImage,
    this.imageFile,
    required this.onPick,
    required this.enabled,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // print('image picked');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              errorMessage ?? 'Primary Image *',
              style: TextStyle(color: errorMessage != null ? Colors.red : null),
            ),
            CustomButton(
              text: 'Pick Image',
              icon: const Icon(Icons.camera_alt),
              onPressed: enabled ? onPick : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (extingPrimaryImage != null &&
            extingPrimaryImage != '' &&
            imageFile == null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              extingPrimaryImage!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
        if (imageFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}

// Additional images sections
class _AdditionalImagesSection extends StatelessWidget {
  final List<File> images;
  final List<String>? existingImages;
  final Map<File, double>? uploadProgress;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final Function(String) onRemoveExisting;
  final bool canAddMore;
  final int maxImages;
  final bool enabled;

  const _AdditionalImagesSection({
    required this.images,
    this.existingImages,
    this.uploadProgress,
    required this.onAdd,
    required this.onRemove,
    required this.onRemoveExisting,
    required this.canAddMore,
    required this.maxImages,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Images (${existingImages != null ? (images.length + existingImages!.length) : images.length}/$maxImages)',
            ),
          ],
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (existingImages != null)
              ...existingImages!.asMap().entries.map((e) {
                final progress = uploadProgress?[e.value];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        e.value,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (progress != null)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: enabled ? () => onRemoveExisting(e.value) : null,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ...images.asMap().entries.map((e) {
              final progress = uploadProgress?[e.value];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      e.value,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (progress != null)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: enabled ? () => onRemove(e.key) : null,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (canAddMore)
              GestureDetector(
                onTap: enabled ? onAdd : null,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Colors.grey),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Video section
class _VideoSection extends StatelessWidget {
  final File? videoFile;
  final double? uploadProgress;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final bool enabled;

  const _VideoSection({
    this.videoFile,
    this.uploadProgress,
    required this.onPick,
    required this.onRemove,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    if (videoFile == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Add video'),
          CustomButton(
            text: 'Add Video',
            icon: const Icon(Icons.video_call),
            onPressed: enabled ? onPick : null,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Video'),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: const Center(
                child: Icon(Icons.play_circle, size: 48, color: Colors.white70),
              ),
            ),
            if (uploadProgress != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: uploadProgress,
                          strokeWidth: 4,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(uploadProgress! * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


// import 'dart:io';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';

// class PostMediaPicker extends StatelessWidget {
//   final String? existingPrimaryImageUrl;
//   final List<String>? existingAdditionalImages;
//   final File? primaryImageFile;
//   final List<File> additionalImages;
//   final File? videoFile;

//   final Function(File) onPrimaryImagePicked;
//   final Function(File) onImageAdded;
//   final Function(int) onImageRemoved;           // for newly added images
//   final Function(String) onExistingImageRemoved; // for images from DB
//   final Function(File) onVideoPicked;
//   final Function() onVideoRemoved;

//   final bool enabled;
//   final int maxAdditionalImages = 5;

//   const PostMediaPicker({
//     super.key,
//     this.existingPrimaryImageUrl,
//     this.existingAdditionalImages,
//     this.primaryImageFile,
//     this.additionalImages = const [],
//     this.videoFile,
//     required this.onPrimaryImagePicked,
//     required this.onImageAdded,
//     required this.onImageRemoved,
//     required this.onExistingImageRemoved,
//     required this.onVideoPicked,
//     required this.onVideoRemoved,
//     this.enabled = true,
//   });

//  @override
// Widget build(BuildContext context) {
//   return BlocBuilder<PostFormBloc, PostFormState>(
//     builder: (context, state) {
//       if (state is! PostFormReady) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       final form = state;
//       final int totalImages = (form.editPost?.additionalImages.length ?? 0) -
//           form.imagesMarkedForDeletion.length +
//           additionalImages.length;

//       final bool canAddMore = totalImages < maxAdditionalImages && enabled;

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Primary Image
//           _PrimaryImageSection(
//             existingUrl: existingPrimaryImageUrl,
//             newFile: primaryImageFile,
//             onPick: () => _pickImage(context, isPrimary: true),
//             enabled: enabled,
//           ),
//           const SizedBox(height: UiConstants.spacingLg),

//           // Additional Images
//           _AdditionalImagesSection(
//             existingImages: existingAdditionalImages ?? [],
//             newImages: additionalImages,
//             markedForDeletion: form.imagesMarkedForDeletion,
//             onAdd: canAddMore ? () => _pickImage(context, isPrimary: false) : null,
//             onRemoveNew: onImageRemoved,
//             onRemoveExisting: onExistingImageRemoved,
//             canAddMore: canAddMore,
//             enabled: enabled,
//           ),
//           const SizedBox(height: UiConstants.spacingLg),

//           // Video
//           _VideoSection(
//             videoFile: videoFile,
//             onPick: enabled && videoFile == null ? () => _pickVideo(context) : null,
//             onRemove: onVideoRemoved,
//           ),
//         ],
//       );
//     },
//   );
// }

//   Future<void> _pickImage(BuildContext context, {required bool isPrimary}) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 1920,
//       maxHeight: 1080,
//       imageQuality: 85,
//     );

//     if (picked == null || !context.mounted) return;

//     final file = File(picked.path);
//     final error = await _validateImage(file);
//     if (error != null) {
//       _showError(context, error);
//       return;
//     }

//     if (isPrimary) {
//       onPrimaryImagePicked(file);
//     } else {
//       onImageAdded(file);
//     }
//   }

//   Future<void> _pickVideo(BuildContext context) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickVideo(
//       source: ImageSource.gallery,
//       maxDuration: const Duration(minutes: 2),
//     );

//     if (picked == null || !context.mounted) return;

//     final file = File(picked.path);
//     final error = await _validateVideo(file);
//     if (error != null) {
//       _showError(context, error);
//       return;
//     }

//     onVideoPicked(file);
//   }

//   Future<String?> _validateImage(File file) async {
//     final size = await file.length();
//     if (size > 10 * 1024 * 1024) return 'Image must be < 10MB';
//     final ext = file.path.split('.').last.toLowerCase();
//     if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
//       return 'Only JPG, PNG, WebP allowed';
//     }
//     return null;
//   }

//   Future<String?> _validateVideo(File file) async {
//     final size = await file.length();
//     if (size > 100 * 1024 * 1024) return 'Video must be < 100MB';
//     return null;
//   }

//   void _showError(BuildContext context, String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red),
//     );
//   }
// }

// // ────────────────────────────── Primary Image ──────────────────────────────
// class _PrimaryImageSection extends StatelessWidget {
//   final String? existingUrl;
//   final File? newFile;
//   final VoidCallback onPick;
//   final bool enabled;

//   const _PrimaryImageSection({
//     this.existingUrl,
//     this.newFile,
//     required this.onPick,
//     required this.enabled,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasImage = newFile != null || (existingUrl != null && existingUrl!.isNotEmpty);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Primary Image *', style: Theme.of(context).textTheme.titleMedium),
//         const SizedBox(height: 12),
//         if (hasImage)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Stack(
//               children: [
//                 AspectRatio(
//                   aspectRatio: 16 / 9,
//                   child: newFile != null
//                       ? Image.file(newFile!, fit: BoxFit.cover)
//                       : CachedNetworkImage(
//                           imageUrl: existingUrl!,
//                           fit: BoxFit.cover,
//                           placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
//                           errorWidget: (_, __, ___) => const Icon(Icons.error),
//                         ),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: CustomButton(
//                     text: 'Change',
//                     onPressed: enabled ? onPick : null,
//                     icon: const Icon(Icons.camera_alt, size: 16),
//                     isOutlined: true,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else
//           CustomButton(
//             text: 'Pick Primary Image',
//             icon: const Icon(Icons.add_a_photo),
//             onPressed: enabled ? onPick : null,
//           ),
//       ],
//     );
//   }
// }

// // ────────────────────────────── Additional Images ──────────────────────────────
// class _AdditionalImagesSection extends StatelessWidget {
//   final List<String> existingImages;
//   final List<File> newImages;
//   final List<String> markedForDeletion;
//   final VoidCallback? onAdd;
//   final Function(int) onRemoveNew;
//   final Function(String) onRemoveExisting;
//   final bool canAddMore;
//   final bool enabled;

//   const _AdditionalImagesSection({
//     required this.existingImages,
//     required this.newImages,
//     required this.markedForDeletion,
//     this.onAdd,
//     required this.onRemoveNew,
//     required this.onRemoveExisting,
//     required this.canAddMore,
//     required this.enabled,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final allImages = <Widget>[];

//     // Existing images (not deleted)
//     for (final url in existingImages) {
//       if (markedForDeletion.contains(url)) continue;

//       allImages.add(
//         _imageTile(
//           child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
//           onRemove: () => onRemoveExisting(url),
//         ),
//       );
//     }

//     // Newly added images
//     for (int i = 0; i < newImages.length; i++) {
//       allImages.add(
//         _imageTile(
//           child: Image.file(newImages[i], fit: BoxFit.cover),
//           onRemove: () => onRemoveNew(i),
//         ),
//       );
//     }

//     // Add button
//     if (canAddMore) {
//       allImages.add(
//         GestureDetector(
//           onTap: enabled ? onAdd : null,
//           child: Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade400),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.add_a_photo, color: Colors.grey),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Additional Images (${allImages.length - (canAddMore ? 1 : 0)}/5)',
//           style: Theme.of(context).textTheme.titleMedium,
//         ),
//         const SizedBox(height: 12),
//         Wrap(spacing: 12, runSpacing: 12, children: allImages),
//       ],
//     );
//   }

//   Widget _imageTile({required Widget child, required VoidCallback onRemove}) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: SizedBox(width: 100, height: 100, child: child),
//         ),
//         Positioned(
//           top: 4,
//           right: 4,
//           child: GestureDetector(
//             onTap: onRemove,
//             child: const CircleAvatar(
//               radius: 14,
//               backgroundColor: Colors.black54,
//               child: Icon(Icons.close, size: 18, color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ────────────────────────────── Video Section ──────────────────────────────
// class _VideoSection extends StatelessWidget {
//   final File? videoFile;
//   final VoidCallback? onPick;
//   final VoidCallback onRemove;

//   const _VideoSection({
//     this.videoFile,
//     this.onPick,
//     required this.onRemove,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (videoFile == null) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('Video (optional)'),
//           CustomButton(
//             text: 'Add Video',
//             icon: const Icon(Icons.video_call),
//             onPressed: onPick,
//           ),
//         ],
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Video'),
//         const SizedBox(height: 8),
//         Stack(
//           children: [
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.black,
//               ),
//               child: const Center(
//                 child: Icon(Icons.play_circle, size: 64, color: Colors.white70),
//               ),
//             ),
//             Positioned(
//               top: 8,
//               right: 8,
//               child: GestureDetector(
//                 onTap: onRemove,
//                 child: const CircleAvatar(
//                   backgroundColor: Colors.red,
//                   child: Icon(Icons.close, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }