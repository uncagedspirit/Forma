import 'package:flutter/material.dart';

/// Placeholder screen for viewing a habit's details.
class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Habit: $id'),
      ),
    );
  }
}
