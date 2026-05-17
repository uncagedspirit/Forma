import 'package:flutter/material.dart';
import 'package:forma/core/theme/app_theme.dart';

void main() {
  runApp(const FormaApp());
}

class FormaApp extends StatelessWidget {
  const FormaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('Forma'),
        ),
      ),
    );
  }
}