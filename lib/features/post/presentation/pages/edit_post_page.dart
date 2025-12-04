import 'package:app/app/dependency_injection.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/create_post_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
import 'package:app/features/post/presentation/pages/create_post_page.dart';
import 'package:app/features/post/presentation/widgets/post_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditPostPage extends StatelessWidget {
  final String postId;
  final Post? post;
  final String? userId;
  const EditPostPage({super.key, required this.postId, this.post, this.userId});

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
              organizationId: post?.organizationId ?? '',
              editPost: post,
            ),
          ),
      child: EditPostView(postId: postId, post: post, userId: userId),
    );
  }
}

class EditPostView extends StatelessWidget {
  final String postId;
  final Post? post;
  final String? userId;
  const EditPostView({super.key, required this.postId, this.post, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post?.title ?? '')),
      body: PostForm(
        initialPost: post,
        isEditing: true,
        onSuccess: (post) => context.pop(),
      ),
    );
  }
}
