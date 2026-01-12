import 'package:flutter/material.dart';

class CustomerReviewPage extends StatelessWidget {
  const CustomerReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Review')),
      body: const Center(child: Text('Welcome to the customer review page')),
    );
  }
}
