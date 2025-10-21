import 'package:app/app/app_config.dart';
import 'package:app/app/router/app_router.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Light mode
      darkTheme: AppTheme.darkTheme, // Dark mode
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
