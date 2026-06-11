import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activopay/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('SEGURIDAD'), findsOneWidget);

    expect(find.text('Biometría (Face ID)'), findsOneWidget);
    expect(find.text('Cambiar Contraseña'), findsOneWidget);
  });
}
