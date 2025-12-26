import 'package:app/app/app_config.dart';
import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/app_router.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    // Initialize app configuration
    await AppConfig.initialize();

    // Initialize Supabase
    if (AppConfig.isConfigured) {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseKey,
        debug: AppConfig.isDebug,
      );
      // print('Supabase initialize');

      // appLogger.info('✅ Supabase initialized successfully');
    } else {
      // appLogger.warning(
      //     '⚠️ Supabase configuration incomplete - running in offline mode');
    }

    // Initialize dependency injection
    await DependencyInjection.init();

    // Run the app
    runApp(const MyApp());
  } catch (e, st) {
    // Handle initialization errors
    // appLogger.error('❌ App initialization failed', e, st);

    // Run app with error state
    runApp(
      MaterialApp(
        title: AppConfig.appName,
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'App Initialization Failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.isDebug
                        ? '${e.toString()}, Stack Trace:  $st'
                        : 'Please restart the app',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
