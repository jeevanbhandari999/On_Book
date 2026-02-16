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
  // Initial image (useful for edit mode)
  final XFile? initialImage;

  // Callback when image is selected
  final ValueChanged<XFile> onImagePicked;

  // Callback when image is selected
  final ValueChanged<XFile>? onImageRemoved;

  // Optional label text
  final String label;

  // Optional height of image preview
  final double height;

  // Optional border radius
  final double borderRadius;

  // For showing the dotted border
  final bool showDottedBorder;

  // For dotted patterns
  final List<double> dottedPatterns;

  // For existing image url
  final String? existingImageUrl;

  // For showing name
  final bool showFileName;

  final double? margin;

  final bool showUploadIcon;

  final bool showFirstNameCharacter;

  // for placing the cross icon

  const AppImagePicker({
    super.key,
    required this.onImagePicked,
    this.initialImage,
    this.label = 'Upload Image',
    this.height = 160,
    this.borderRadius = UiConstants.radiusMd,
    this.showDottedBorder = true,
    this.dottedPatterns = const [10, 10],
    this.existingImageUrl,
    this.onImageRemoved,
    this.showFileName = true,
    this.margin,
    this.showUploadIcon = false,
    this.showFirstNameCharacter = false,
  });

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (pickedFile == null) return;
      final file = File(pickedFile.path);
      final bytes = await file.length();
      const maxSize = 2 * 1024 * 1024;
      if (bytes > maxSize) {
        if (mounted) {
          // CustomSnackbar.showError(
          //   context,
          //   errorMessage: 'Image too large. Please choose a smaller image.',
          // );
        }
        return;
      }
      final xfile = XFile(pickedFile.path);
      setState(() => _image = xfile);
      widget.onImagePicked(xfile);
    } catch (_) {
      if (mounted) {
        // CustomSnackbar.showError(context, errorMessage: 'Failed to pick image');
      }
    }
  }

  void _showPickerOptions() {
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
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your photo gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_image != null && widget.showFileName) ...[
          AutoMarqueeText(
            text: _image!.name,
            maxLines: 1,
            style: const TextStyle(),
          ),
          FutureBuilder<int>(
            future: _image!.length(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final kb = snapshot.data! / 1024;
              return Text('${kb.toStringAsFixed(1)} KB');
            },
          ),
          const SizedBox(height: UiConstants.spacingSm),
        ],
        Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: widget.height,
              child: _image != null
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius,
                            ),
                            child: Image.file(
                              File(_image!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(
                              UiConstants.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                UiConstants.radiusRound,
                              ),
                              color: AppColors.error,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: UiConstants.iconSm,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : widget.existingImageUrl != null &&
                        widget.existingImageUrl!.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius,
                        ),
                        color: Colors.grey,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl: widget.existingImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'AppImages.placeholder',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        dashPattern: widget.showDottedBorder
                            ? widget.dottedPatterns
                            : const [1, 0],
                        color: AppColors.black,
                        radius: Radius.circular(widget.borderRadius),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius,
                          ),
                        ),
                        child: widget.showUploadIcon
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    UiConstants.spacingMd,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (widget.showUploadIcon &&
                                            !widget.showFirstNameCharacter)
                                          const Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        if (widget.showFirstNameCharacter)
                                          Text(
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            widget.label,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 64,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        // Container(
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.circular(
                                        //       widget.borderRadius,
                                        //     ),
                                        //   ),
                                        //   child: CachedNetworkImage(
                                        //     imageUrl:
                                        //         'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                        //   ),
                                        // ),
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
                    ),
            ),
            Positioned(
              right: 30,
              bottom: 8,
              child: InkWell(
                onTap: _showPickerOptions,
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
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
