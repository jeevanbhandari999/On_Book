import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/core/constants/ui_constants.dart';

class PostMediaPicker extends StatelessWidget {
  final String primaryImageUrl;
  final List<File> additionalImages;
  final File? videoFile;
  final Map<File, double>? uploadProgress;
  final String? errorMessage;

  final Function(String url) onPrimaryImagePicked;
  final Function(File file) onImageAdded;
  final Function(int index) onImageRemoved;
  final Function(File file) onVideoPicked;
  final Function() onVideoRemoved;

  final bool enabled;
  final int maxAdditionalImages;

  const PostMediaPicker({
    super.key,
    this.primaryImageUrl = '',
    this.additionalImages = const [],
    this.videoFile,
    this.uploadProgress,
    this.errorMessage,
    required this.onPrimaryImagePicked,
    required this.onImageAdded,
    required this.onImageRemoved,
    required this.onVideoPicked,
    required this.onVideoRemoved,
    this.enabled = true,
    this.maxAdditionalImages = 5,
  });

  int get totalImages =>
      additionalImages.length + (primaryImageUrl.isNotEmpty ? 1 : 0);
  bool get canAddImage => totalImages < maxAdditionalImages && enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryImageSection(
          imageUrl: primaryImageUrl,
          onPick: () => _showImagePickerSheet(context, isPrimary: true),
          enabled: enabled,
        ),
        const SizedBox(height: UiConstants.spacingMd),

        _AdditionalImagesSection(
          images: additionalImages,
          uploadProgress: uploadProgress,
          onAdd: () => _showImagePickerSheet(context, isPrimary: false),
          onRemove: onImageRemoved,
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

        if (errorMessage != null)
          Text(
            errorMessage!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
      ],
    );
  }

  // Image picker bottom sheet
  Future<void> _showImagePickerSheet(
    BuildContext context, {
    required bool isPrimary,
  }) async {
    await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (_) => SafeArea(
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
          final url = await _uploadImageToSupabase(file);
          onPrimaryImagePicked(url);
        } else {
          onImageAdded(file);
        }
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

    final remainingSlots = maxAdditionalImages - additionalImages.length;
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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              subtitle: const Text('Record video through your device'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your video gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 1),
    );

    if (picked != null && context.mounted) {
      final file = File(picked.path);
      final error = await _validateVideo(file);
      if (error != null) {
        _showError(context, error);
        return;
      }
      onVideoPicked(file);
    }
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

  Future<String> _uploadImageToSupabase(File file) async {
    await Future.delayed(const Duration(seconds: 1));
    // return 'https://supabase.co/storage/${file.path.split('/').last}';
    return 'https://rjqetlaghsixoeyzsoqh.supabase.co/storage/v1/object/public/announcements/96123bb2-8c01-41a3-a033-b96cce13e695/96123bb2-8c01-41a3-a033-b96cce13e695/1756574458872.jpg';
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}

// Primary image section
class _PrimaryImageSection extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onPick;
  final bool enabled;

  const _PrimaryImageSection({
    required this.imageUrl,
    required this.onPick,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Primary Image *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: enabled ? onPick : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Pick Image'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
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
  final Map<File, double>? uploadProgress;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final bool canAddMore;
  final int maxImages;
  final bool enabled;

  const _AdditionalImagesSection({
    required this.images,
    this.uploadProgress,
    required this.onAdd,
    required this.onRemove,
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
              'Additional Images (${images.length}/$maxImages)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
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
      return ElevatedButton.icon(
        onPressed: enabled ? onPick : null,
        icon: const Icon(Icons.video_call),
        label: const Text('Add Video (Optional)'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Video', style: Theme.of(context).textTheme.titleMedium),
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
