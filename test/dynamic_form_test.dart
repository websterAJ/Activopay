import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:activopay/models/form_config.dart';
import 'package:activopay/widgets/dynamic_form.dart';

void main() {
  testWidgets('DynamicForm standard mode renders fields', (WidgetTester tester) async {
    final config = FormConfig(
      isWizard: false,
      postSubmitAction: PostSubmitAction.goHome,
      fields: [
        FormFieldConfig(
          name: 'test_field',
          type: FormFieldType.text,
          label: 'Test Label',
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DynamicForm(config: config),
      ),
    ));

    expect(find.text('Test Label'), findsOneWidget);
    expect(find.byType(FormBuilderTextField), findsOneWidget);
  });

  testWidgets('DynamicForm wizard mode renders steps', (WidgetTester tester) async {
    final config = FormConfig(
      isWizard: true,
      postSubmitAction: PostSubmitAction.showSuccessScreen,
      steps: [
        FormStep(
          title: 'Step 1',
          fields: [
            FormFieldConfig(
              name: 'field1',
              type: FormFieldType.text,
              label: 'Label 1',
            ),
          ],
        ),
        FormStep(
          title: 'Step 2',
          fields: [
            FormFieldConfig(
              name: 'field2',
              type: FormFieldType.text,
              label: 'Label 2',
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DynamicForm(config: config),
      ),
    ));

    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Label 1'), findsOneWidget);

    // Step 2 content might be in the tree but not necessarily visible if vertical stepper
    expect(find.text('Step 2'), findsOneWidget);
  });
}
