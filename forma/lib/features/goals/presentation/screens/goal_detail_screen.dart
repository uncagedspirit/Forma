import 'package:flutter/material.dart';

/// Placeholder screen for viewing a goal's details.
class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Goal: $id'),
      ),
    );
  }
}
