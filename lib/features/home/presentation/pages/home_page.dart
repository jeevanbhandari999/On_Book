import 'package:app/app/router/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            context.push(RouteConstants.anotherPage);
          },
          child: const Text('Go'),
        ),
      ),
    );
  }
}
