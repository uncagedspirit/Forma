import 'package:flutter/material.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/core/theme/app_theme.dart';
import 'package:forma/shared/widgets/storage_error_screen.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initApp();
}

Future<void> _initApp() async {
  final logger = Logger('Main');
  try {
    await HiveService.init();
    runApp(const FormaApp());
  } catch (e, stackTrace) {
    logger.severe('Failed to initialize Hive', e, stackTrace);
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StorageErrorScreen(
          onRetry: _initApp,
        ),
      ),
    );
  }
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
