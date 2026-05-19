import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/core/theme/app_theme.dart';
import 'package:forma/shared/widgets/storage_error_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _configureLogging();

  await _startApp();
}

void _configureLogging() {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: '
      '${record.loggerName}: '
      '${record.message}',
    );

    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }

    if (record.stackTrace != null) {
      debugPrint('${record.stackTrace}');
    }
  });
}

Future<void> _startApp() async {
  final logger = Logger('Main');

  try {
    await HiveService.init();

    runApp(
      const ProviderScope(
        child: FormaApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.severe(
      'Failed to initialize Hive',
      e,
      stackTrace,
    );

    await _closeHiveSafely();

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StorageErrorScreen(
          onRetry: () async {
            await _retryInitialization();
          },
        ),
      ),
    );
  }
}

Future<void> _retryInitialization() async {
  final logger = Logger('Retry');

  try {
    await _closeHiveSafely();

    await HiveService.init();

    runApp(
      const ProviderScope(
        child: FormaApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.severe(
      'Retry initialization failed',
      e,
      stackTrace,
    );
  }
}

Future<void> _closeHiveSafely() async {
  try {
    if (Hive.isBoxOpen('habits') ||
        Hive.isBoxOpen('goals') ||
        Hive.isBoxOpen('logs') ||
        Hive.isBoxOpen('moods') ||
        Hive.isBoxOpen('user_preferences')) {
      await Hive.close();
    }
  } catch (e) {
    debugPrint('Failed to close Hive: $e');
  }
}

/// Root widget of the Forma application.
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