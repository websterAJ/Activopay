import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activopay/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders correctly', (WidgetTester tester) async {
    // Avoid network image errors in tests by using a fake box
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('SEGURIDAD'), findsOneWidget);
    expect(find.text('PREFERENCIAS'), findsOneWidget);
    expect(find.text('CUENTA'), findsOneWidget);

    expect(find.text('Biometría (Face ID)'), findsOneWidget);
    expect(find.text('Cambiar Contraseña'), findsOneWidget);
    expect(find.text('Notificaciones Push'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Cuentas Bancarias Vinculadas'), findsOneWidget);
    expect(find.text('Cerrar Sesión'), findsOneWidget);
  });
}
