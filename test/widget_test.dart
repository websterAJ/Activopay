import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activopay/main.dart';

void main() {
  testWidgets('App starts at Login Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we are on the login screen.
    expect(find.text('ActivoPay'), findsWidgets);
    expect(find.text('Iniciar'), findsOneWidget);
  });
}
