import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/custom_drop_down.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
import 'package:app/features/post/presentation/widgets/post_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class PostForm extends StatefulWidget {
  final Post? initialPost;
  final bool isEditing;
  final VoidCallback? onCancel;
  final void Function(Post)? onSuccess;

  const PostForm({
    super.key,
    this.initialPost,
    this.isEditing = false,
    this.onCancel,
    this.onSuccess,
  });

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  // Controllers for text fields
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _areaController;
  late final TextEditingController _capacityController;
  late final TextEditingController _youtubeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _areaController = TextEditingController();
    _capacityController = TextEditingController();
    _youtubeController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _capacityController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostFormBloc, PostFormState>(
      listener: (context, state) {
        if (state is PostFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSuccess?.call(state.post);
        } else if (state is PostFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is! PostFormReady) {
          return const Center(child: CircularProgressIndicator());
        }

        final form = state;

        // Sync controllers with BLoC state
        _titleController.text = form.title;
        _descriptionController.text = form.description;
        _priceController.text = form.price > 0
            ? form.price.toStringAsFixed(0)
            : '';
        _areaController.text = form.area != null
            ? form.area!.toStringAsFixed(0)
            : '';
        _capacityController.text = form.capacity != null
            ? form.capacity!.toString()
            : '';
        _youtubeController.text = form.youtubeUrl;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Post Title *',
                hint: 'Enter post title',
                errorText: form.validationErrors['title'],
                onChanged: (v) => context.read<PostFormBloc>().add(
                  PostFormTitleChanged(v.trim()),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              const SizedBox(height: UiConstants.spacingMd),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description *',
                hint: 'Tell us about your place',
                maxLines: 5,
                errorText: form.validationErrors['description'],
                onChanged: (v) => context.read<PostFormBloc>().add(
                  PostFormDescriptionChanged(v.trim()),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              const SizedBox(height: UiConstants.spacingMd),

              // Price
              CustomTextField(
                controller: _priceController,
                label: 'Price (Rs.) *',
                hint: 'e.g. 5000',
                keyboardType: TextInputType.number,
                errorText: form.validationErrors['price'],
                onChanged: (v) {
                  final value = double.tryParse(v) ?? 0;
                  context.read<PostFormBloc>().add(PostFormPriceChanged(value));
                },
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: UiConstants.spacingMd),

              // Area & Capacity
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _areaController,
                      label: 'Area (sq ft)',
                      hint: 'e.g. 800',
                      keyboardType: TextInputType.number,
                      onChanged: (v) => context.read<PostFormBloc>().add(
                        PostFormAreaChanged(double.tryParse(v)),
                      ),
                      prefixIcon: const Icon(Icons.space_bar),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _capacityController,
                      label: 'Capacity',
                      hint: 'e.g. 4',
                      keyboardType: TextInputType.number,
                      onChanged: (v) => context.read<PostFormBloc>().add(
                        PostFormCapacityChanged(int.tryParse(v)),
                      ),
                      prefixIcon: const Icon(Icons.people),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UiConstants.spacingMd),

              // Room Type
              // CustomDropdown<RoomType>(
              //   label: 'Room Type',
              //   hint: 'Select room type',
              //   value: form.roomType,
              //   items: RoomType.values
              //       .map(
              //         (t) => DropdownMenuItem(
              //           value: t,
              //           child: Text(t.displayName),
              //         ),
              //       )
              //       .toList(),
              //   onChanged: (val) => context.read<PostFormBloc>().add(
              //     PostFormRoomTypeChanged(val),
              //   ),
              // ),
              CustomDropdown<RoomType>(
                title: 'Room Type',
                hint: 'Select room type',
                dropdownHeaderName: 'List of room type',
                initialValue: form.roomType,
                shouldDivideItems: true,
                items: RoomType.values
                    .map(
                      (t) => DropdownItem<RoomType>(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  context.read<PostFormBloc>().add(
                    PostFormRoomTypeChanged(val),
                  );
                },
              ),
              const SizedBox(height: UiConstants.spacingMd),

              // Amenities
              CustomMultiSelect<AmenityType>(
                label: 'Amenities',
                items: AmenityType.values,
                selected: form.amenities,
                itemLabel: (a) => a.name,
                onChanged: (selected) => context.read<PostFormBloc>().add(
                  PostFormAmenitiesChanged(selected),
                ),
              ),
              const SizedBox(height: UiConstants.spacingMd),

              // Tags
              CustomMultiSelect<PostTag>(
                label: 'Tags',
                items: PostTag.values,
                selected: form.tags,
                itemLabel: (t) => '#${t.name}',
                onChanged: (selected) => context.read<PostFormBloc>().add(
                  PostFormTagsChanged(selected),
                ),
              ),
              const SizedBox(height: UiConstants.spacingMd),

              // YouTube URL
              CustomTextField(
                controller: _youtubeController,
                label: 'YouTube URL (optional)',
                hint: 'https://youtube.com/...',
                errorText: form.validationErrors['youtubeUrl'],
                onChanged: (v) => context.read<PostFormBloc>().add(
                  PostFormYoutubeUrlChanged(v.trim()),
                ),
                prefixIcon: const Icon(Icons.play_circle_outline),
              ),
              const SizedBox(height: UiConstants.spacingMd),
              // Media Picker
              PostMediaPicker(
                errorMessage: form.validationErrors['primary_image'],
                existingAdditionalImage: form.existingAdditionalImages,
                existingPrimaryImageUrl: form.editPost?.primaryImageUrl,
                primaryImageFile: form.primaryImageFile,
                additionalImages: form.additionalImages,
                videoFile: form.videoFile,
                onPrimaryImagePicked: (f) => context.read<PostFormBloc>().add(
                  PostFormPrimaryImagePicked(f),
                ),
                onImageAdded: (f) => context.read<PostFormBloc>().add(
                  PostFormAdditionalImageAdded(f),
                ),
                onImageRemoved: (i) => context.read<PostFormBloc>().add(
                  PostFormAdditionalImageRemoved(i),
                ),
                onExistingImageRemoved: (url) => context
                    .read<PostFormBloc>()
                    .add(PostFormExistingImageRemoved(imageUrl: url)),
                onVideoPicked: (f) =>
                    context.read<PostFormBloc>().add(PostFormVideoPicked(f)),
                onVideoRemoved: () => context.read<PostFormBloc>().add(
                  const PostFormVideoRemoved(),
                ),
              ),
              // PostMediaPicker(
              //   existingPrimaryImageUrl: form.editPost?.primaryImageUrl,
              //   existingAdditionalImages: form.existingAdditionalImages,
              //   primaryImageFile: form.primaryImageFile,
              //   additionalImages: form.additionalImages,
              //   videoFile: form.videoFile,
              //   onPrimaryImagePicked: (f) =>
              //       bloc.add(PostFormPrimaryImagePicked(f)),
              //   onImageAdded: (f) => bloc.add(PostFormAdditionalImageAdded(f)),
              //   onImageRemoved: (i) =>
              //       bloc.add(PostFormAdditionalImageRemoved(i)),
              //   onExistingImageRemoved: (url) =>
              //       bloc.add(PostFormExistingImageRemoved(imageUrl: url)),
              //   onVideoPicked: (f) => bloc.add(PostFormVideoPicked(f)),
              //   onVideoRemoved: () => bloc.add(const PostFormVideoRemoved()),
              // ),
              const SizedBox(height: UiConstants.spacingMd),

              // Location Picker
              _LocationSection(
                latitude: form.latitude,
                longitude: form.longitude,
                onChanged: (lat, lng) {
                  context.read<PostFormBloc>().add(
                    PostFormCoordinatesChanged(latitude: lat, longitude: lng),
                  );
                },
              ),
              const SizedBox(height: UiConstants.spacingXl),

              // Action Buttons
              _buildActionButtons(context, form),
              const SizedBox(height: UiConstants.spacingXl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, PostFormReady state) {
    final isSubmitting =
        context.watch<PostFormBloc>().state is PostFormSubmitting;

    return Row(
      children: [
        if (widget.onCancel != null)
          Expanded(
            flex: 1,
            child: CustomButton(
              text: 'Cancel',
              onPressed: isSubmitting ? null : widget.onCancel,
              isOutlined: true,
            ),
          ),
        if (widget.onCancel != null)
          const SizedBox(width: UiConstants.spacingMd),
        Expanded(
          flex: 2,
          child: CustomButton(
            text: widget.isEditing ? 'Update Post' : 'Create Post',
            onPressed: state.isValid
                ? () => context.read<PostFormBloc>().add(
                    const PostFormSubmitted(),
                  )
                : null,
            isLoading: isSubmitting,
            icon: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}

// Reuse your existing _LocationSection (just move it here or keep separate)
class _LocationSection extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final Function(double?, double?) onChanged;

  const _LocationSection({
    required this.latitude,
    required this.longitude,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Create controllers that reflect current values
    final latController = TextEditingController(
      text: latitude != null ? latitude!.toStringAsFixed(6) : '',
    );
    final lngController = TextEditingController(
      text: longitude != null ? longitude!.toStringAsFixed(6) : '',
    );

    // Keep controllers in sync if value changes externally (e.g. from map)
    latController.text = latitude?.toStringAsFixed(6) ?? '';
    lngController.text = longitude?.toStringAsFixed(6) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (optional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (latitude != null && longitude != null)
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: latController,
                  label: 'Latitude',
                  hint: 'e.g. 27.7172',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) {
                    final val = double.tryParse(v);
                    onChanged(val, longitude);
                  },
                  prefixIcon: const Icon(Icons.location_on, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: lngController,
                  label: 'Longitude',
                  hint: 'e.g. 85.3240',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) {
                    final val = double.tryParse(v);
                    onChanged(latitude, val);
                  },
                  prefixIcon: const Icon(Icons.explore, size: 20),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),

        // Pick from Map Button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Pick Location from Map',
            icon: const Icon(Icons.map_outlined),
            onPressed: () async {
              final result = await context.push(
                RouteConstants.anotherPage,
              ); // your Another page

              if (result is LatLng && context.mounted) {
                onChanged(result.latitude, result.longitude);
              }
            },
          ),
        ),

        const SizedBox(height: 8),

        // Optional: Clear button
        if (latitude != null || longitude != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onChanged(null, null),
              child: const Text('Clear Location'),
            ),
          ),
      ],
    );
  }
}
