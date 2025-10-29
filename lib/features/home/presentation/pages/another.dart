import 'package:flutter/material.dart';

class Another extends StatelessWidget {
  const Another({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('another')),
      body: Center(child: Text('Welcome to another page')),
    );
  }
}
