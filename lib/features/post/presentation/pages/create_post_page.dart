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
              userId: userId ?? '',
              organizationId: organizationId ?? '',
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
            // print(state.message);
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
                  primaryImageFile: form.primaryImageFile,
                  additionalImages: form.additionalImages,
                  videoFile: form.videoFile, // Add to state
                  // uploadProgress: bloc.uploadProgress,
                  onPrimaryImagePicked: (file) =>
                      bloc.add(PostFormPrimaryImagePicked(file)),
                  onImageAdded: (file) =>
                      bloc.add(PostFormAdditionalImageAdded(file)),
                  onImageRemoved: (i) =>
                      bloc.add(PostFormAdditionalImageRemoved(i)),
                  onVideoPicked: (file) => bloc.add(PostFormVideoPicked(file)),
                  onVideoRemoved: () => bloc.add(const PostFormVideoRemoved()),
                ),
                const SizedBox(height: UiConstants.spacingMd),
                // Location (Map Picker)
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

String _roomTypeLabel(RoomType t) => t.name.capitalize();
String _amenityLabel(AmenityType a) => a.name.replaceAll('_', ' ').capitalize();
String _tagLabel(PostTag t) => '#${t.name.capitalize()}';

extension StringExt on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
