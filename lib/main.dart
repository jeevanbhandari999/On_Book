import 'dart:async';
import 'package:app/app/app_config.dart';
import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/app_router.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/home/presentation/cubit/location_cubit.dart';
import 'package:app/features/notifications/domain/usecases/stream_notifications_use_case.dart';
import 'package:app/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:app/features/notifications/presentation/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    await AppConfig.initialize();

    if (AppConfig.isConfigured) {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseKey,
        debug: AppConfig.isDebug,
      );
    }

    await DependencyInjection.init();
    await NotificationService.instance.init();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
              notificationService: NotificationService.instance,
              streamNotifications:
                  DependencyInjection.get<StreamNotificationsUseCase>(),
            ),
          ),
          BlocProvider(create: (context) => LocationCubit()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, st) {
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
                        ? '${e.toString()}, Stack Trace: $st'
                        : 'Please restart the app',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return _AuthListener(child: child ?? const SizedBox());
      },
    );
  }
}

class _AuthListener extends StatefulWidget {
  final Widget child;
  const _AuthListener({required this.child});

  @override
  State<_AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<_AuthListener> {
  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();

    // Trigger for the current session if already logged in at app start.
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      // Post-frame so the cubit's context is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NotificationCubit>().start(currentUser.id);
        }
      });
    }

    // Then listen for future login / logout events.
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final cubit = context.read<NotificationCubit>();
      final userId = data.session?.user.id;

      if (userId != null) {
        cubit.start(userId);
      } else {
        cubit.stop();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
