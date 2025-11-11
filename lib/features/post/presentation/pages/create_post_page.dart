import 'dart:io';
import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/create_post_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
import 'package:app/features/post/presentation/widgets/post_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatelessWidget {
  final String? organizationId;
  final String? userId;

  const CreatePostPage({super.key, this.organizationId, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PostFormBloc(
            createPostUseCase: CreatePostUseCase(
              DependencyInjection.get<PostRepository>(),
            ),
          )..add(
            PostFormInitialized(
              userId: userId ?? '55bb4bc3-80a2-4b40-877a-cc09d70eb5ed',
              organizationId:
                  organizationId ?? '6fd1c9a6-dc5c-4c50-beb6-6ec1080bcc23',
            ),
          ),
      child: const CreatePostView(),
    );
  }
}

class CreatePostView extends StatelessWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Post'),
      body: BlocConsumer<PostFormBloc, PostFormState>(
        listener: (context, state) {
          if (state is PostFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, state.post);
          } else if (state is PostFormError) {
            print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 10),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! PostFormReady) {
            return const Center(child: CircularProgressIndicator());
          }

          final bloc = context.read<PostFormBloc>();
          final form = state;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Title
                CustomTextField(
                  label: 'Post Title *',
                  hint: 'Enter post title',
                  errorText: form.validationErrors['title'],
                  onChanged: (v) => bloc.add(PostFormTitleChanged(v.trim())),
                  prefixIcon: const Icon(Icons.title),
                ),
                const SizedBox(height: UiConstants.spacingMd),

                //  Description
                CustomTextField(
                  label: 'Description *',
                  hint: 'Enter post description',
                  errorText: form.validationErrors['description'],
                  maxLines: 4,
                  onChanged: (v) =>
                      bloc.add(PostFormDescriptionChanged(v.trim())),
                  prefixIcon: const Icon(Icons.description),
                ),
                const SizedBox(height: UiConstants.spacingMd),

                // Price
                CustomTextField(
                  label: 'Price *',
                  hint: 'Enter price',
                  errorText: form.validationErrors['price'],
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final value = double.tryParse(v) ?? 0;
                    bloc.add(PostFormPriceChanged(value));
                  },
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                const SizedBox(height: UiConstants.spacingMd),

                // Area and capacity
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Area (sq ft)',
                        hint: 'e.g. 500',
                        errorText: form.validationErrors['area'],
                        keyboardType: TextInputType.number,
                        onChanged: (v) =>
                            bloc.add(PostFormAreaChanged(double.tryParse(v))),
                        prefixIcon: const Icon(Icons.space_bar),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Capacity',
                        hint: 'e.g. 2',
                        errorText: form.validationErrors['capacity'],
                        keyboardType: TextInputType.number,
                        onChanged: (v) =>
                            bloc.add(PostFormCapacityChanged(int.tryParse(v))),
                        prefixIcon: const Icon(Icons.people),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UiConstants.spacingMd),

                //  Room Type Dropdown
                CustomDropdown<RoomType>(
                  label: 'Room Type',
                  hint: 'Select room type',
                  value: form.roomType,
                  items: RoomType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(_roomTypeLabel(t)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => bloc.add(PostFormRoomTypeChanged(val)),
                ),
                const SizedBox(height: UiConstants.spacingMd),

                //  Amenities (Multi-Select)
                CustomMultiSelect<AmenityType>(
                  label: 'Amenities',
                  items: AmenityType.values,
                  selected: form.amenities,
                  itemLabel: (a) => _amenityLabel(a),
                  onChanged: (selected) =>
                      bloc.add(PostFormAmenitiesChanged(selected)),
                ),
                const SizedBox(height: UiConstants.spacingMd),

                //  Tags (Multi-Select)
                CustomMultiSelect<PostTag>(
                  label: 'Tags',
                  items: PostTag.values,
                  selected: form.tags,
                  itemLabel: (t) => _tagLabel(t),
                  onChanged: (selected) =>
                      bloc.add(PostFormTagsChanged(selected)),
                ),
                const SizedBox(height: UiConstants.spacingMd),

                //  YouTube URL , help to show the whole detail of the hotels if the owner has a youtube channel and have uploaed the videos
                CustomTextField(
                  label: 'YouTube URL (optional)',
                  hint: 'https://youtube.com/...',
                  errorText: form.validationErrors['youtubeUrl'],
                  onChanged: (v) =>
                      bloc.add(PostFormYoutubeUrlChanged(v.trim())),
                  prefixIcon: const Icon(Icons.play_circle_outline),
                ),
                const SizedBox(height: UiConstants.spacingMd),

                PostMediaPicker(
                  primaryImageUrl: form.primaryImageUrl,
                  additionalImages: form.additionalImages,
                  videoFile: form.videoFile, // Add to state
                  // uploadProgress: bloc.uploadProgress,
                  onPrimaryImagePicked: (url) =>
                      bloc.add(PostFormPrimaryImageChanged(url)),
                  onImageAdded: (file) =>
                      bloc.add(PostFormAdditionalImageAdded(file)),
                  onImageRemoved: (i) =>
                      bloc.add(PostFormAdditionalImageRemoved(i)),
                  onVideoPicked: (file) => bloc.add(PostFormVideoPicked(file)),
                  onVideoRemoved: () => bloc.add(const PostFormVideoRemoved()),
                ),

                // // Primary Image Upload
                // _ImageUploadSection(
                //   title: 'Primary Image *',
                //   imageUrl: form.primaryImageUrl,
                //   onPick: () async {
                //     final file = await _pickImage();
                //     if (file != null) {
                //       // TODO: Upload to Cloudinary and get URL
                //       final url = await _uploadToCloudinary(
                //         file,
                //         form.organizationId,
                //         'primary',
                //       );
                //       bloc.add(PostFormPrimaryImageChanged(url));
                //     }
                //   },
                // ),
                const SizedBox(height: UiConstants.spacingMd),

                // Additional Images
                // _AdditionalImagesSection(
                //   images: form.additionalImages,
                //   onAdd: () async {
                //     final file = await _pickImage();
                //     if (file != null) {
                //       // TODO: Upload to Cloudinary
                //       // final url = await _uploadToCloudinary(file, form.organizationId, 'add');
                //       // For now, just add file (upload later in use case)
                //       bloc.add(PostFormAdditionalImageAdded(file));
                //     }
                //   },
                //   onRemove: (index) =>
                //       bloc.add(PostFormAdditionalImageRemoved(index)),
                // ),
                const SizedBox(height: UiConstants.spacingMd),

                // ─── Location (Map Picker) ──────────────
                _LocationSection(
                  latitude: form.latitude,
                  longitude: form.longitude,
                  onChanged: (lat, lng) {
                    bloc.add(
                      PostFormCoordinatesChanged(latitude: lat, longitude: lng),
                    );
                  },
                ),
                const SizedBox(height: UiConstants.spacingLg),

                // ─── Submit Button ──────────────────────
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Create Post',
                    onPressed: form.isValid
                        ? () => bloc.add(const PostFormSubmitted())
                        : null,
                    icon: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ImageUploadSection extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onPick;

  const _ImageUploadSection({
    required this.title,
    required this.imageUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Pick Image'),
            ),
            const SizedBox(width: 12),
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AdditionalImagesSection extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const _AdditionalImagesSection({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Images',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...images.asMap().entries.map(
              (e) => Stack(
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
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => onRemove(e.key),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAdd,
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

class _LocationSection extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final Function(double?, double?) onChanged;

  const _LocationSection({
    this.latitude,
    this.longitude,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Latitude',
                hint: 'e.g. 27.7172',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => onChanged(double.tryParse(v), longitude),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Longitude',
                hint: 'e.g. 85.3240',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => onChanged(latitude, double.tryParse(v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () async {
            // TODO: Open map picker
            // final location = await showMapPicker();
            // onChanged(location.lat, location.lng);
          },
          icon: const Icon(Icons.map),
          label: const Text('Pick from Map'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILS
// ─────────────────────────────────────────────────────────────────────────────

Future<File?> _pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  return picked != null ? File(picked.path) : null;
}

Future<String> _uploadToCloudinary(File file, String orgId, String type) async {
  // TODO: Implement Cloudinary upload
  // Return secure_url
  return 'https://via.placeholder.com/600x400.png?text=Uploaded+$type';
}

String _roomTypeLabel(RoomType t) => t.name.capitalize();
String _amenityLabel(AmenityType a) => a.name.replaceAll('_', ' ').capitalize();
String _tagLabel(PostTag t) => '#${t.name.capitalize()}';

extension StringExt on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
