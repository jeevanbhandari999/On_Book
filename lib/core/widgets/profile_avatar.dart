import 'dart:io';

import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/auto_marquee_text.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class AppImagePicker extends StatefulWidget {
  // ── Common ──────────────────────────────────────────────────────────────────

  /// Pre-selected file (edit-mode seed for single-image mode).
  final XFile? initialImage;

  /// Pre-selected files (edit-mode seed for multi-image mode).
  final List<XFile>? initialImages;

  /// Remote URL to show when no local file has been picked yet (single mode).
  final String? existingImageUrl;

  /// Remote URLs to show alongside local picks (multi mode).
  final List<String>? existingImageUrls;

  /// Label shown inside the empty placeholder / used as avatar initial.
  final String label;

  /// Height of the single-image preview area.
  final double height;

  final double borderRadius;

  final bool showDottedBorder;
  final List<double> dottedPatterns;

  final bool showFileName;
  final double? margin;

  /// Show a cloud-upload icon inside the empty placeholder.
  final bool showUploadIcon;

  /// Show the first character(s) of [label] as a large avatar letter.
  final bool showFirstNameCharacter;

  // ── Single-image mode ────────────────────────────────────────────────────────

  /// Called every time the user picks (or replaces) an image in single mode.
  final ValueChanged<XFile>? onImagePicked;

  /// Called when the user removes the picked image in single mode.
  final ValueChanged<XFile>? onImageRemoved;

  // ── Multiple-image mode ───────────────────────────────────────────────────

  /// Enable multiple-image selection.
  final bool allowMultiple;

  /// Maximum number of images the user may select (multi mode only).
  final int maxImages;

  /// Called whenever the list of picked images changes (multi mode).
  final ValueChanged<List<XFile>>? onMultipleImagesPicked;

  /// Called when the user removes one of the existing remote images (multi mode).
  final ValueChanged<String>? onExistingImageRemoved;

  const AppImagePicker({
    super.key,
    // Common
    this.initialImage,
    this.initialImages,
    this.existingImageUrl,
    this.existingImageUrls,
    this.label = 'Upload Image',
    this.height = 160,
    this.borderRadius = UiConstants.radiusMd,
    this.showDottedBorder = true,
    this.dottedPatterns = const [10, 10],
    this.showFileName = true,
    this.margin,
    this.showUploadIcon = false,
    this.showFirstNameCharacter = false,
    // Single mode
    this.onImagePicked,
    this.onImageRemoved,
    // Multi mode
    this.allowMultiple = false,
    this.maxImages = 5,
    this.onMultipleImagesPicked,
    this.onExistingImageRemoved,
  }) : assert(
         allowMultiple ? onMultipleImagesPicked != null : onImagePicked != null,
         'Provide onMultipleImagesPicked for multi mode, onImagePicked for single mode.',
       );

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  final ImagePicker _picker = ImagePicker();

  // Single-mode state
  XFile? _singleImage;

  // Multi-mode state
  late List<XFile> _multiImages;

  @override
  void initState() {
    super.initState();
    _singleImage = widget.initialImage;
    _multiImages = List<XFile>.from(widget.initialImages ?? []);
  }

  // ── Derived helpers ─────────────────────────────────────────────────────────

  int get _existingCount => widget.existingImageUrls?.length ?? 0;

  int get _totalMultiCount => _multiImages.length + _existingCount;

  bool get _canAddMore => _totalMultiCount < widget.maxImages;

  // ── Picking logic ───────────────────────────────────────────────────────────

  Future<void> _pickSingle(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await File(picked.path).length();
      if (bytes > 2 * 1024 * 1024) {
        _showError('Image too large. Please choose a smaller image (< 2 MB).');
        return;
      }

      setState(() => _singleImage = picked);
      widget.onImagePicked!(picked);
    } catch (_) {
      _showError('Failed to pick image.');
    }
  }

  Future<void> _pickMultipleSingle(ImageSource source) async {
    if (!_canAddMore) {
      _showError('Maximum of ${widget.maxImages} images reached.');
      return;
    }
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked == null) return;

      final error = await _validateImage(File(picked.path));
      if (error != null) {
        _showError(error);
        return;
      }

      setState(() => _multiImages.add(picked));
      widget.onMultipleImagesPicked!(List.unmodifiable(_multiImages));
    } catch (_) {
      _showError('Failed to pick image.');
    }
  }

  Future<void> _pickMultipleAtOnce() async {
    if (!_canAddMore) {
      _showError('Maximum of ${widget.maxImages} images reached.');
      return;
    }
    final remaining = widget.maxImages - _totalMultiCount;
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked.isEmpty) return;

      final toAdd = picked.take(remaining).toList();
      int added = 0;

      for (final xfile in toAdd) {
        final error = await _validateImage(File(xfile.path));
        if (error != null) {
          _showError('${xfile.name}: $error');
          continue;
        }
        _multiImages.add(xfile);
        added++;
      }

      setState(() {});
      widget.onMultipleImagesPicked!(List.unmodifiable(_multiImages));

      if (picked.length > remaining) {
        _showError('Only $remaining image(s) added – limit reached.');
      }
    } catch (_) {
      _showError('Failed to pick images.');
    }
  }

  void _removeMultiImage(int index) {
    setState(() => _multiImages.removeAt(index));
    widget.onMultipleImagesPicked!(List.unmodifiable(_multiImages));
  }

  void _removeExistingImage(String url) {
    widget.onExistingImageRemoved?.call(url);
  }

  // ── Bottom sheets ───────────────────────────────────────────────────────────

  void _showSinglePickerSheet() {
    CustomBottomSheet.show(
      context: context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PickerTile(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Use camera to take a new photo',
              onTap: () {
                Navigator.of(context).pop();
                _pickSingle(ImageSource.camera);
              },
            ),
            _PickerTile(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select from your photo gallery',
              onTap: () {
                Navigator.of(context).pop();
                _pickSingle(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiPickerSheet() {
    CustomBottomSheet.show(
      context: context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PickerTile(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Use camera to take a new photo',
              onTap: () {
                Navigator.of(context).pop();
                _pickMultipleSingle(ImageSource.camera);
              },
            ),
            _PickerTile(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select a single image from gallery',
              onTap: () {
                Navigator.of(context).pop();
                _pickMultipleSingle(ImageSource.gallery);
              },
            ),
            _PickerTile(
              icon: Icons.photo_library_outlined,
              title: 'Select Multiple',
              subtitle:
                  'Choose up to ${widget.maxImages - _totalMultiCount} more images',
              onTap: () {
                Navigator.of(context).pop();
                _pickMultipleAtOnce();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  Future<String?> _validateImage(File file) async {
    final size = await file.length();
    if (size > 10 * 1024 * 1024) return 'Image must be < 10 MB';
    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      return 'Only JPG, PNG, WebP allowed';
    }
    return null;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return widget.allowMultiple ? _buildMultiMode() : _buildSingleMode();
  }

  // ── Single-image mode UI ────────────────────────────────────────────────────

  Widget _buildSingleMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_singleImage != null && widget.showFileName) ...[
          AutoMarqueeText(
            text: _singleImage!.name,
            maxLines: 1,
            style: const TextStyle(),
          ),
          FutureBuilder<int>(
            future: _singleImage!.length(),
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              return Text('${(snap.data! / 1024).toStringAsFixed(1)} KB');
            },
          ),
          const SizedBox(height: UiConstants.spacingSm),
        ],
        Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: widget.height,
              child: _buildSinglePreview(),
            ),
            // Camera FAB
            Positioned(
              right: 30,
              bottom: 8,
              child: _CameraFab(onTap: _showSinglePickerSheet),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSinglePreview() {
    // ── Local file picked ──────────────────────────────────────────────────
    if (_singleImage != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Image.file(
                File(_singleImage!.path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _RemoveBadge(
              onRemove: () {
                final removed = _singleImage!;
                setState(() => _singleImage = null);
                widget.onImageRemoved?.call(removed);
              },
            ),
          ),
        ],
      );
    }

    // ── Existing remote URL ────────────────────────────────────────────────
    if (widget.existingImageUrl?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CachedNetworkImage(
          imageUrl: widget.existingImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: widget.height,
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
          errorWidget: (_, __, ___) => const _BrokenImagePlaceholder(),
        ),
      );
    }

    // ── Empty placeholder ──────────────────────────────────────────────────
    return EmptyPlaceholder(
      borderRadius: widget.borderRadius,
      showDottedBorder: widget.showDottedBorder,
      dottedPatterns: widget.dottedPatterns,
      showUploadIcon: widget.showUploadIcon,
      showFirstNameCharacter: widget.showFirstNameCharacter,
      label: widget.label,
    );
  }

  // ── Multiple-image mode UI ──────────────────────────────────────────────────

  Widget _buildMultiMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Images ($_totalMultiCount / ${widget.maxImages})',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (_totalMultiCount == 0)
              Text(
                'Tap + to add images',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: UiConstants.spacingSm),

        // Thumbnail grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Existing remote images
            if (widget.existingImageUrls != null)
              ...widget.existingImageUrls!.map(
                (url) => _MultiImageTile.network(
                  url: url,
                  onRemove: () => _removeExistingImage(url),
                ),
              ),

            // Locally picked images
            ..._multiImages.asMap().entries.map(
              (e) => _MultiImageTile.file(
                file: File(e.value.path),
                onRemove: () => _removeMultiImage(e.key),
              ),
            ),

            // "Add more" tile
            if (_canAddMore) _AddMoreTile(onTap: _showMultiPickerSheet),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Camera FAB shown over the single-image preview.
class _CameraFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CameraFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 4,
          ),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
      ),
    );
  }
}

/// Red × badge for removing a single selected image.
class _RemoveBadge extends StatelessWidget {
  final VoidCallback onRemove;
  const _RemoveBadge({required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.all(UiConstants.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(UiConstants.radiusRound),
        ),
        child: const Icon(
          Icons.close,
          size: UiConstants.iconSm,
          color: AppColors.white,
        ),
      ),
    );
  }
}

/// Empty dashed placeholder shown before any image is selected.
class EmptyPlaceholder extends StatelessWidget {
  final double borderRadius;
  final bool showDottedBorder;
  final List<double> dottedPatterns;
  final bool showUploadIcon;
  final bool showFirstNameCharacter;
  final String label;
  final Color defaultBackgroundColor;

  const EmptyPlaceholder({
    super.key,
    required this.borderRadius,
    required this.showDottedBorder,
    required this.dottedPatterns,
    required this.showUploadIcon,
    required this.showFirstNameCharacter,
    required this.label,
    this.defaultBackgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        dashPattern: showDottedBorder ? dottedPatterns : const [1, 0],
        color: AppColors.black,
        radius: Radius.circular(borderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: showUploadIcon
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(UiConstants.spacingMd),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!showFirstNameCharacter)
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: Colors.white70,
                          ),
                        if (showFirstNameCharacter)
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                width: 200,
                height: 200,
                child: ClipOval(
                  child: CachedNetworkImage(
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl:
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                  ),
                ),
              ),
      ),
    );
  }
}

/// Fallback shown when a network image fails to load.
class _BrokenImagePlaceholder extends StatelessWidget {
  const _BrokenImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }
}

/// A 100×100 thumbnail tile used in the multi-image grid (local file variant).
class _MultiImageTile extends StatelessWidget {
  final Widget _image;
  final VoidCallback onRemove;

  const _MultiImageTile._({required Widget image, required this.onRemove})
    : _image = image;

  factory _MultiImageTile.file({
    required File file,
    required VoidCallback onRemove,
  }) {
    return _MultiImageTile._(
      image: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
      onRemove: onRemove,
    );
  }

  factory _MultiImageTile.network({
    required String url,
    required VoidCallback onRemove,
  }) {
    return _MultiImageTile._(
      image: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
      onRemove: onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: _image),
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

/// Dashed "add more" tile shown at the end of the multi-image grid.
class _AddMoreTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoreTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 28),
      ),
    );
  }
}

/// Reusable bottom-sheet list tile for the picker options.
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
