import 'package:flutter/material.dart';

class WriteAReviewPage extends StatelessWidget {
  const WriteAReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write A Review')),
      body: const Center(child: Text('Welcome to the write a review page')),
    );
  }
}
