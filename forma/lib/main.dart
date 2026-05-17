import 'package:flutter/material.dart';
import 'package:forma/core/theme/app_theme.dart';

void main() {
  runApp(const FormaApp());
}

/// The root widget of the Forma application.
///
/// Automatically detects system brightness and applies the appropriate theme.
class FormaApp extends StatelessWidget {
  const FormaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('Forma'),
        ),
      ),
    );
  }
}