import 'package:flutter/material.dart';

class Another extends StatelessWidget {
  const Another({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('another')),
      body: const Center(child: Text('Welcome to another page')),
    );
  }
}
