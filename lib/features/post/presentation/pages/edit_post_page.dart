import 'package:flutter/material.dart';

class EditPostPage extends StatelessWidget {
  const EditPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditPostView();
  }
}

class EditPostView extends StatelessWidget {
  const EditPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit post page')),
      body: const Center(child: Text('Welcome to the edit post page')),
    );
  }
}
