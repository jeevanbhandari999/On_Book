// import 'dart:io';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/core/widgets/profile_avatar.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:app/core/constants/ui_constants.dart';

// class PostMediaPicker extends StatelessWidget {
//   final String? existingPrimaryImageUrl;
//   final List<String>? existingAdditionalImage;
//   final File? primaryImageFile;
//   final List<File> additionalImages;
//   final File? videoFile;
//   final Map<File, double>? uploadProgress;
//   final String? errorMessage;

//   final Function(File file) onPrimaryImagePicked;
//   final Function(File file) onImageAdded;
//   final Function(int index) onImageRemoved;
//   final Function(String) onExistingImageRemoved;
//   final Function(File file) onVideoPicked;
//   final Function() onVideoRemoved;

//   final bool enabled;
//   final int maxAdditionalImages;

//   const PostMediaPicker({
//     super.key,
//     this.existingPrimaryImageUrl,
//     this.existingAdditionalImage,
//     this.primaryImageFile,
//     this.additionalImages = const [],

//     this.videoFile,
//     this.uploadProgress,
//     this.errorMessage,
//     required this.onPrimaryImagePicked,
//     required this.onImageAdded,
//     required this.onImageRemoved,
//     required this.onExistingImageRemoved,
//     required this.onVideoPicked,
//     required this.onVideoRemoved,
//     this.enabled = true,
//     this.maxAdditionalImages = 5,
//   });

//   // int get totalImages {
//   //   if (existingAdditionalImage != null) {
//   //     return additionalImages.length +
//   //         existingAdditionalImage!.length +
//   //         (primaryImageFile != null ? 1 : 0);
//   //   } else {
//   //     return additionalImages.length + (primaryImageFile != null ? 1 : 0);
//   //   }
//   // }

//   // bool get canAddImage => totalImages < maxAdditionalImages && enabled;

//   int get totalAdditionalImages {
//     return
//     // (primaryImageFile != null || existingPrimaryImageUrl != null
//     //         ? 1
//     //         : 0) +
//     additionalImages.length + (existingAdditionalImage?.length ?? 0);
//   }

//   bool get canAddImage =>
//       totalAdditionalImages < maxAdditionalImages && enabled;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _PrimaryImageSection(
//           errorMessage: errorMessage,
//           extingPrimaryImage: existingPrimaryImageUrl,
//           imageFile: primaryImageFile,
//           onPick: () => _showImagePickerSheet(context, isPrimary: true),
//           enabled: enabled,
//         ),

//         const SizedBox(height: UiConstants.spacingMd),

//         _AdditionalImagesSection(
//           existingImages: existingAdditionalImage,
//           images: additionalImages,
//           uploadProgress: uploadProgress,
//           onAdd: () => _showImagePickerSheet(context, isPrimary: false),
//           onRemove: onImageRemoved,
//           onRemoveExisting: onExistingImageRemoved,
//           canAddMore: canAddImage,
//           maxImages: maxAdditionalImages,
//           enabled: enabled,
//         ),
//         const SizedBox(height: UiConstants.spacingMd),

//         _VideoSection(
//           videoFile: videoFile,
//           uploadProgress: uploadProgress?[videoFile],
//           onPick: () => _showVideoPickerSheet(context),
//           onRemove: onVideoRemoved,
//           enabled: enabled && videoFile == null,
//         ),
//         const SizedBox(height: UiConstants.spacingSm),
//       ],
//     );
//   }

//   // Image picker bottom sheet
//   Future<void> _showImagePickerSheet(
//     BuildContext context, {
//     required bool isPrimary,
//   }) async {
//     CustomBottomSheet.show(
//       context: context,
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take Photo'),
//               subtitle: const Text('Use camera to take a new photo'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickImage(context, ImageSource.camera, isPrimary);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from Gallery'),
//               subtitle: const Text('Select from your photo gallery'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickImage(context, ImageSource.gallery, isPrimary);
//               },
//             ),

//             if (!isPrimary)
//               ListTile(
//                 leading: const Icon(Icons.photo_library_outlined),
//                 title: const Text('Select Multiple'),
//                 subtitle: const Text('Choose multiple images at once'),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   _pickMultipleImages(context, isPrimary: isPrimary);
//                 },
//               ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImage(
//     BuildContext context,
//     ImageSource source,
//     bool? isPrimary,
//   ) async {
//     try {
//       final imagePicker = ImagePicker();
//       final pickedFile = await imagePicker.pickImage(
//         source: source,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         final file = File(pickedFile.path);

//         // Validate image
//         final validationError = await _validateImage(file);
//         if (validationError != null) {
//           _showError(context, validationError);
//           return;
//         }

//         if (isPrimary != null && isPrimary) {
//           // final url = await _uploadImageToSupabase(file);
//           onPrimaryImagePicked(file);
//           // print('file: $file');
//         } else {
//           onImageAdded(file);
//         }
//       }
//     } catch (e) {
//       _showError(context, 'Failed to pick image: ${e.toString()}');
//     }
//   }

//   Future<void> _pickVideo(BuildContext context, ImageSource source) async {
//     try {
//       final videoPicked = ImagePicker();
//       final pickedFile = await videoPicked.pickVideo(
//         source: source,
//         maxDuration: const Duration(minutes: 1),
//       );

//       if (pickedFile != null && context.mounted) {
//         final file = File(pickedFile.path);
//         final error = await _validateVideo(file);
//         if (error != null) {
//           _showError(context, error);
//           return;
//         }
//         onVideoPicked(file);
//       }
//     } catch (e) {
//       _showError(context, 'Failed to pick image: ${e.toString()}');
//     }
//   }

//   //Multiple image picker (Only for additional images)
//   Future<void> _pickMultipleImages(
//     BuildContext context, {
//     required bool isPrimary,
//   }) async {
//     if (isPrimary) return; // Should never happen

//     final remainingSlots = maxAdditionalImages - totalAdditionalImages;
//     if (remainingSlots <= 0) {
//       _showError(context, 'Maximum additional images reached');
//       return;
//     }

//     final picker = ImagePicker();
//     final pickedFiles = await picker.pickMultiImage(
//       maxWidth: 1920,
//       maxHeight: 1080,
//       imageQuality: 85,
//     );

//     if (pickedFiles.isEmpty || !context.mounted) return;

//     final filesToAdd = pickedFiles.take(remainingSlots).toList();
//     int addedCount = 0;

//     for (final picked in filesToAdd) {
//       final file = File(picked.path);
//       final error = await _validateImage(file);
//       if (error != null) {
//         _showError(context, '${picked.name}: $error');
//         continue;
//       }
//       onImageAdded(file);
//       addedCount++;
//     }

//     if (pickedFiles.length > remainingSlots) {
//       _showError(context, 'Only $remainingSlots images added due to limit');
//     } else if (addedCount > 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('$addedCount images added'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   // Video picker
//   // TODO
//   Future<void> _showVideoPickerSheet(BuildContext context) async {
//     final source = CustomBottomSheet.show(
//       context: context,
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.videocam),
//               title: const Text('Record Video'),
//               subtitle: const Text('Record video through your device'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickVideo(context, ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.video_library),
//               title: const Text('Choose from Gallery'),
//               subtitle: const Text('Select from your video gallery'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickVideo(context, ImageSource.gallery);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Validation and upload
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

//     final ext = file.path.split('.').last.toLowerCase();
//     if (!['mp4', 'mov', 'avi'].contains(ext)) {
//       return 'Only MP4, MOV, AVI allowed';
//     }
//     return null;
//   }

//   void _showError(BuildContext context, String msg) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
//   }
// }

// // Primary image section
// class _PrimaryImageSection extends StatelessWidget {
//   final String? extingPrimaryImage;
//   final File? imageFile;
//   final VoidCallback onPick;
//   final bool enabled;
//   final String? errorMessage;

//   const _PrimaryImageSection({
//     this.extingPrimaryImage,
//     this.imageFile,
//     required this.onPick,
//     required this.enabled,
//     this.errorMessage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // print('image picked');
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               errorMessage ?? 'Primary Image *',
//               style: TextStyle(color: errorMessage != null ? Colors.red : null),
//             ),
//             CustomButton(
//               text: 'Pick Image',
//               icon: const Icon(Icons.camera_alt),
//               onPressed: enabled ? onPick : null,
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         if (extingPrimaryImage != null &&
//             extingPrimaryImage != '' &&
//             imageFile == null)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.network(
//               extingPrimaryImage!,
//               width: double.infinity,
//               height: 250,
//               fit: BoxFit.cover,
//             ),
//           ),
//         if (imageFile != null)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               imageFile!,
//               width: double.infinity,
//               height: 250,
//               fit: BoxFit.cover,
//             ),
//           ),
//       ],
//     );
//   }
// }

// // Additional images sections
// class _AdditionalImagesSection extends StatelessWidget {
//   final List<File> images;
//   final List<String>? existingImages;
//   final Map<File, double>? uploadProgress;
//   final VoidCallback onAdd;
//   final Function(int) onRemove;
//   final Function(String) onRemoveExisting;
//   final bool canAddMore;
//   final int maxImages;
//   final bool enabled;

//   const _AdditionalImagesSection({
//     required this.images,
//     this.existingImages,
//     this.uploadProgress,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onRemoveExisting,
//     required this.canAddMore,
//     required this.maxImages,
//     required this.enabled,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Additional Images (${existingImages != null ? (images.length + existingImages!.length) : images.length}/$maxImages)',
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),

//         Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: [
//             if (existingImages != null)
//               ...existingImages!.asMap().entries.map((e) {
//                 final progress = uploadProgress?[e.value];
//                 return Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         e.value,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     if (progress != null)
//                       Positioned.fill(
//                         child: Container(
//                           color: Colors.black54,
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               value: progress,
//                               strokeWidth: 3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: GestureDetector(
//                         onTap: enabled ? () => onRemoveExisting(e.value) : null,
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.close,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ...images.asMap().entries.map((e) {
//               final progress = uploadProgress?[e.value];
//               return Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       e.value,
//                       width: 100,
//                       height: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   if (progress != null)
//                     Positioned.fill(
//                       child: Container(
//                         color: Colors.black54,
//                         child: Center(
//                           child: CircularProgressIndicator(
//                             value: progress,
//                             strokeWidth: 3,
//                           ),
//                         ),
//                       ),
//                     ),
//                   Positioned(
//                     top: 4,
//                     right: 4,
//                     child: GestureDetector(
//                       onTap: enabled ? () => onRemove(e.key) : null,
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: const BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           size: 16,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }),
//             if (canAddMore)
//               GestureDetector(
//                 onTap: enabled ? onAdd : null,
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.add_a_photo, color: Colors.grey),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // Video section
// class _VideoSection extends StatelessWidget {
//   final File? videoFile;
//   final double? uploadProgress;
//   final VoidCallback onPick;
//   final VoidCallback onRemove;
//   final bool enabled;

//   const _VideoSection({
//     this.videoFile,
//     this.uploadProgress,
//     required this.onPick,
//     required this.onRemove,
//     required this.enabled,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (videoFile == null) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('Add video'),
//           CustomButton(
//             text: 'Add Video',
//             icon: const Icon(Icons.video_call),
//             onPressed: enabled ? onPick : null,
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
//               height: 250,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.black,
//               ),
//               child: const Center(
//                 child: Icon(Icons.play_circle, size: 48, color: Colors.white70),
//               ),
//             ),
//             if (uploadProgress != null)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black54,
//                   child: Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CircularProgressIndicator(
//                           value: uploadProgress,
//                           strokeWidth: 4,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '${(uploadProgress! * 100).toInt()}%',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             Positioned(
//               top: 8,
//               right: 8,
//               child: GestureDetector(
//                 onTap: onRemove,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.close, size: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'dart:io';

import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PostMediaPicker
// ─────────────────────────────────────────────────────────────────────────────
//
// Composes three sections:
//   1. Primary image   – tap anywhere on the preview / placeholder to pick.
//   2. Additional images – thumbnail grid; tap + tile to add, × to remove.
//   3. Video           – add / remove a short video clip.
//
// The dedicated "Pick Image" button that previously sat in the header row has
// been removed. Every interaction is now driven by tapping directly on the
// preview areas themselves.
// ─────────────────────────────────────────────────────────────────────────────

class PostMediaPicker extends StatelessWidget {
  // ── Existing remote media (edit mode) ────────────────────────────────────
  final String? existingPrimaryImageUrl;
  final List<String>? existingAdditionalImages;

  // ── Locally picked files ─────────────────────────────────────────────────
  final File? primaryImageFile;
  final List<File> additionalImages;
  final File? videoFile;

  // ── Upload progress (file → 0.0–1.0) ─────────────────────────────────────
  final Map<File, double>? uploadProgress;

  // ── Validation error shown above the primary image ───────────────────────
  final String? primaryImageError;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  final ValueChanged<File> onPrimaryImagePicked;
  final ValueChanged<File> onImageAdded;
  final ValueChanged<int> onImageRemoved;
  final ValueChanged<String> onExistingImageRemoved;
  final ValueChanged<File> onVideoPicked;
  final VoidCallback onVideoRemoved;

  // ── Config ────────────────────────────────────────────────────────────────
  final bool enabled;
  final int maxAdditionalImages;

  const PostMediaPicker({
    super.key,
    // Existing remote media
    this.existingPrimaryImageUrl,
    this.existingAdditionalImages,
    // Local picks
    this.primaryImageFile,
    this.additionalImages = const [],
    this.videoFile,
    // Progress & errors
    this.uploadProgress,
    this.primaryImageError,
    // Callbacks
    required this.onPrimaryImagePicked,
    required this.onImageAdded,
    required this.onImageRemoved,
    required this.onExistingImageRemoved,
    required this.onVideoPicked,
    required this.onVideoRemoved,
    // Config
    this.enabled = true,
    this.maxAdditionalImages = 5,
  });

  // ── Derived ───────────────────────────────────────────────────────────────

  int get _totalAdditional =>
      additionalImages.length + (existingAdditionalImages?.length ?? 0);

  bool get _canAddMore => _totalAdditional < maxAdditionalImages && enabled;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryImageSection(
          existingUrl: existingPrimaryImageUrl,
          imageFile: primaryImageFile,
          errorMessage: primaryImageError,
          enabled: enabled,
          onPick: (source) => _pickPrimaryImage(context, source),
        ),
        const SizedBox(height: UiConstants.spacingMd),

        _AdditionalImagesSection(
          existingImages: existingAdditionalImages,
          images: additionalImages,
          uploadProgress: uploadProgress,
          canAddMore: _canAddMore,
          maxImages: maxAdditionalImages,
          totalAdded: _totalAdditional,
          enabled: enabled,
          onAdd: (source, multi) => multi
              ? _pickMultipleImages(context)
              : _pickAdditionalImage(context, source),
          onRemove: onImageRemoved,
          onRemoveExisting: onExistingImageRemoved,
        ),
        const SizedBox(height: UiConstants.spacingMd),

        _VideoSection(
          videoFile: videoFile,
          uploadProgress: uploadProgress?[videoFile],
          enabled: enabled,
          onPick: (source) => _pickVideo(context, source),
          onRemove: onVideoRemoved,
        ),
        const SizedBox(height: UiConstants.spacingSm),
      ],
    );
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickPrimaryImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final error = await _validateImage(file);
      if (error != null) {
        _showError(context, error);
        return;
      }
      onPrimaryImagePicked(file);
    } catch (e) {
      _showError(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _pickAdditionalImage(
    BuildContext context,
    ImageSource source,
  ) async {
    if (!_canAddMore) {
      _showError(context, 'Maximum of $maxAdditionalImages images reached.');
      return;
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final error = await _validateImage(file);
      if (error != null) {
        _showError(context, error);
        return;
      }
      onImageAdded(file);
    } catch (e) {
      _showError(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _pickMultipleImages(BuildContext context) async {
    final remaining = maxAdditionalImages - _totalAdditional;
    if (remaining <= 0) {
      _showError(context, 'Maximum of $maxAdditionalImages images reached.');
      return;
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked.isEmpty || !context.mounted) return;

      final toAdd = picked.take(remaining).toList();
      int added = 0;

      for (final xfile in toAdd) {
        final file = File(xfile.path);
        final error = await _validateImage(file);
        if (error != null) {
          _showError(context, '${xfile.name}: $error');
          continue;
        }
        onImageAdded(file);
        added++;
      }

      if (picked.length > remaining && context.mounted) {
        _showError(context, 'Only $remaining image(s) added – limit reached.');
      } else if (added > 0 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$added image${added == 1 ? '' : 's'} added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError(context, 'Failed to pick images: $e');
    }
  }

  // ── Video picking ─────────────────────────────────────────────────────────

  Future<void> _pickVideo(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 1),
      );
      if (picked == null || !context.mounted) return;

      final file = File(picked.path);
      final error = await _validateVideo(file);
      if (error != null) {
        _showError(context, error);
        return;
      }
      onVideoPicked(file);
    } catch (e) {
      _showError(context, 'Failed to pick video: $e');
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────

  Future<String?> _validateImage(File file) async {
    final size = await file.length();
    if (size > 10 * 1024 * 1024) return 'Image must be < 10 MB';
    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      return 'Only JPG, PNG, WebP allowed';
    }
    return null;
  }

  Future<String?> _validateVideo(File file) async {
    final size = await file.length();
    if (size > 100 * 1024 * 1024) return 'Video must be < 100 MB';
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

// ─────────────────────────────────────────────────────────────────────────────
// PRIMARY IMAGE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryImageSection extends StatelessWidget {
  final String? existingUrl;
  final File? imageFile;
  final String? errorMessage;
  final bool enabled;

  /// Called with the chosen [ImageSource] when the user selects an option.
  final ValueChanged<ImageSource> onPick;

  const _PrimaryImageSection({
    this.existingUrl,
    this.imageFile,
    this.errorMessage,
    required this.enabled,
    required this.onPick,
  });

  bool get _hasImage => imageFile != null || (existingUrl?.isNotEmpty == true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row (no button here any more – tap the preview instead)
        Text(
          errorMessage ?? 'Primary Image *',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: errorMessage != null ? Colors.red : Colors.black,
          ),
        ),
        if (errorMessage == null)
          Text(
            'Tap the image area to change',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        const SizedBox(height: 8),

        // Tappable preview
        GestureDetector(
          onTap: enabled ? () => _showPickerSheet(context) : null,
          child: _buildPreview(),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    // Local file
    if (imageFile != null) {
      return _ImagePreviewFrame(
        child: Image.file(
          imageFile!,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
      );
    }

    // Existing remote URL
    if (existingUrl?.isNotEmpty == true) {
      return _ImagePreviewFrame(
        child: Image.network(
          existingUrl!,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
      );
    }

    // Empty placeholder
    return const _ImagePlaceholder(
      height: 200,
      icon: Icons.add_photo_alternate_outlined,
      label: 'Tap to add primary image',
    );
  }

  void _showPickerSheet(BuildContext context) {
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
                onPick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your photo gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onPick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADDITIONAL IMAGES SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _AdditionalImagesSection extends StatelessWidget {
  final List<File> images;
  final List<String>? existingImages;
  final Map<File, double>? uploadProgress;
  final bool canAddMore;
  final int maxImages;
  final int totalAdded;
  final bool enabled;

  /// [multi] = true means the user chose "Select Multiple".
  final void Function(ImageSource source, bool multi) onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<String> onRemoveExisting;

  const _AdditionalImagesSection({
    required this.images,
    this.existingImages,
    this.uploadProgress,
    required this.canAddMore,
    required this.maxImages,
    required this.totalAdded,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onRemoveExisting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Images ($totalAdded / $maxImages)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // ── Existing remote thumbnails ──────────────────────────────────
            if (existingImages != null)
              ...existingImages!.map((url) {
                return _Thumbnail(
                  onRemove: enabled ? () => onRemoveExisting(url) : null,
                  child: Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                );
              }),

            // ── Locally picked thumbnails ───────────────────────────────────
            ...images.asMap().entries.map((e) {
              final progress = uploadProgress?[e.value];
              return _Thumbnail(
                progress: progress,
                onRemove: enabled ? () => onRemove(e.key) : null,
                child: Image.file(
                  e.value,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              );
            }),

            // ── "Add more" tile ─────────────────────────────────────────────
            if (canAddMore)
              GestureDetector(
                onTap: enabled ? () => _showPickerSheet(context) : null,
                child: const DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    dashPattern: [8, 8],
                    color: AppColors.black,
                    radius: Radius.circular(UiConstants.spacingMd),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showPickerSheet(BuildContext context) {
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
                onAdd(ImageSource.camera, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select a single image from gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onAdd(ImageSource.gallery, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Select Multiple'),
              subtitle: Text(
                'Choose up to ${maxImages - totalAdded} more images at once',
              ),
              onTap: () {
                Navigator.of(context).pop();
                onAdd(ImageSource.gallery, true); // source ignored in multi
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _VideoSection extends StatelessWidget {
  final File? videoFile;
  final double? uploadProgress;
  final bool enabled;
  final ValueChanged<ImageSource> onPick;
  final VoidCallback onRemove;

  const _VideoSection({
    this.videoFile,
    this.uploadProgress,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (videoFile == null) {
      return GestureDetector(
        onTap: enabled ? () => _showPickerSheet(context) : null,
        child: const _ImagePlaceholder(
          height: 120,
          icon: Icons.video_call_outlined,
          label: 'Tap to add a video (optional)',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Video', style: Theme.of(context).textTheme.labelMedium),
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
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: uploadProgress,
                          strokeWidth: 4,
                          color: Colors.white,
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

  void _showPickerSheet(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              subtitle: const Text('Record a video with your camera'),
              onTap: () {
                Navigator.of(context).pop();
                onPick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select a video from your gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onPick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED MICRO-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Rounded frame for the primary image preview.
class _ImagePreviewFrame extends StatelessWidget {
  final Widget child;
  const _ImagePreviewFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: child);
  }
}

/// Dashed empty placeholder used for primary image and video sections.
class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final IconData icon;
  final String label;

  const _ImagePlaceholder({
    required this.height,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: const RoundedRectDottedBorderOptions(
        dashPattern: [8, 8],
        color: AppColors.black,
        radius: Radius.circular(UiConstants.spacingMd),
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// 100×100 thumbnail with an optional progress overlay and × remove button.
class _Thumbnail extends StatelessWidget {
  final Widget child;
  final double? progress;
  final VoidCallback? onRemove;

  const _Thumbnail({required this.child, this.progress, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        if (progress != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
