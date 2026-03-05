import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activopay/main.dart';

void main() {
  testWidgets('App starts with AuthGate showing a loader', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that AuthGate shows a CircularProgressIndicator initially.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
