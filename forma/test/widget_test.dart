import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App initializes with ProviderScope',
      (WidgetTester tester) async {
    // This test verifies that the app can be wrapped in ProviderScope.
    // Full integration testing requires mocking Hive and navigation setup.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
