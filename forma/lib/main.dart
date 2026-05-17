import 'package:flutter/material.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text('Forma'),
        ),
      ),
    );
  }
}