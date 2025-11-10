import 'package:app/app/dependency_injection.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/create_post_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
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
            const PostFormInitialized(
              userId: '55bb4bc3-80a2-4b40-877a-cc09d70eb5ed',
              organizationId: '6fd1c9a6-dc5c-4c50-beb6-6ec1080bcc23',
              // userId: userId!,
              // organizationId: organizationId!,
            ),
          ),
      child: const _CreatePostView(),
    );
  }
}

class _CreatePostView extends StatelessWidget {
  const _CreatePostView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: BlocConsumer<PostFormBloc, PostFormState>(
        listener: (context, state) {
          if (state is PostFormSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context, state.post);
          } else if (state is PostFormError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is! PostFormReady) {
            if (state is PostFormLoading || state is PostFormSubmitting) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('Loading...'));
          }

          final bloc = context.read<PostFormBloc>();
          final form = state;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Title ────────────────────────────
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    errorText: form.validationErrors['title'],
                  ),
                  onChanged: (v) => bloc.add(PostFormTitleChanged(v.trim())),
                ),

                const SizedBox(height: 12),

                // ─── Description ───────────────────────
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    errorText: form.validationErrors['description'],
                  ),
                  onChanged: (v) =>
                      bloc.add(PostFormDescriptionChanged(v.trim())),
                ),

                const SizedBox(height: 12),

                // ─── Price ─────────────────────────────
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                    errorText: form.validationErrors['price'],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final value = double.tryParse(v) ?? 0;
                    bloc.add(PostFormPriceChanged(value));
                  },
                ),

                const SizedBox(height: 12),

                // ─── Area ──────────────────────────────
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Area (sq ft)',
                    errorText: form.validationErrors['area'],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      bloc.add(PostFormAreaChanged(double.tryParse(v))),
                ),

                const SizedBox(height: 12),

                // ─── Capacity ──────────────────────────
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Capacity',
                    errorText: form.validationErrors['capacity'],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      bloc.add(PostFormCapacityChanged(int.tryParse(v))),
                ),

                const SizedBox(height: 12),

                // ─── Room Type Dropdown ────────────────
                DropdownButtonFormField<RoomType>(
                  value: form.roomType,
                  hint: const Text('Select Room Type'),
                  items: RoomType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (val) => bloc.add(PostFormRoomTypeChanged(val)),
                ),

                const SizedBox(height: 12),

                // ─── YouTube URL ───────────────────────
                TextField(
                  decoration: InputDecoration(
                    labelText: 'YouTube URL (optional)',
                    errorText: form.validationErrors['youtubeUrl'],
                  ),
                  onChanged: (v) =>
                      bloc.add(PostFormYoutubeUrlChanged(v.trim())),
                ),

                const SizedBox(height: 12),

                // ─── Primary Image Upload ──────────────
                TextButton.icon(
                  onPressed: () async {
                    // Add your image picker logic here
                    // e.g., final imageUrl = await uploadImage(...);
                    final imageUrl = 'https://example.com/sample.jpg';
                    bloc.add(PostFormPrimaryImageChanged(imageUrl));
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Add Primary Image'),
                ),
                if (form.primaryImageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(form.primaryImageUrl, height: 150),
                  ),

                const SizedBox(height: 12),

                // ─── Coordinates (Latitude/Longitude) ─
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) => bloc.add(
                          PostFormCoordinatesChanged(
                            latitude: double.tryParse(v),
                            longitude: form.longitude,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) => bloc.add(
                          PostFormCoordinatesChanged(
                            latitude: form.latitude,
                            longitude: double.tryParse(v),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── Submit Button ─────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: form.isValid
                        ? () => bloc.add(const PostFormSubmitted())
                        : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Create Post'),
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
