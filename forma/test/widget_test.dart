import 'package:flutter_test/flutter_test.dart';

import 'package:forma/main.dart';

void main() {
  testWidgets('App renders Forma text', (WidgetTester tester) async {
    await tester.pumpWidget(const FormaApp());

    expect(find.text('Forma'), findsOneWidget);
  });
}