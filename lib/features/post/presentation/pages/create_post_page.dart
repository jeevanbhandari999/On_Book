import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/create_post_use_case.dart';
import 'package:app/features/post/domain/usecases/update_post_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
import 'package:app/features/post/presentation/widgets/post_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
            updatePostUseCase: UpdatePostUseCase(
              DependencyInjection.get<PostRepository>(),
            ),
          )..add(
            PostFormInitialized(
              userId: userId ?? '',
              organizationId: organizationId ?? '',
              editPost: null,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Creating Post',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostForm(
              onSuccess: (post) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post created!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomSubmitBar(BuildContext context, PostFormReady state, dynamic widget) {
  //  final isSubmitting =
  //       context.watch<PostFormBloc>().state is PostFormSubmitting;

  //   return Row(
  //     children: [
  //       if (onCancel != null)
  //         Expanded(
  //           flex: 1,
  //           child: CustomButton(
  //             text: 'Cancel',
  //             onPressed: isSubmitting ? null : widget.onCancel,
  //             isOutlined: true,
  //           ),
  //         ),
  //       if (widget.onCancel != null)
  //         const SizedBox(width: UiConstants.spacingMd),
  //       Expanded(
  //         flex: 2,
  //         child: CustomButton(
  //           text: widget.isEditing ? 'Update Post' : 'Create Post',
  //           onPressed: state.isValid
  //               ? () => context.read<PostFormBloc>().add(
  //                   const PostFormSubmitted(),
  //                 )
  //               : null,
  //           isLoading: isSubmitting,
  //           icon: const Icon(Icons.send),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
