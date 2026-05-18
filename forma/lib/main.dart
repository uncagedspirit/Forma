import 'package:flutter/material.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage before running the app
  await HiveService.init();

  runApp(const FormaApp());
}

/// The root widget of the Forma application.
///
/// Automatically detects system brightness and applies the appropriate theme.
  /// Delegates all navigation to GoRouter via MaterialApp.router.
class FormaApp extends StatelessWidget {
  const FormaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Forma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}