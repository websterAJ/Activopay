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
      content: [
        FormStep(
          stepTitle: 'Step 1',
          fields: [
            FormFieldConfig(
              name: 'test_field',
              type: FormFieldType.text,
              label: 'Test Label',
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

    expect(find.text('Test Label'), findsOneWidget);
    expect(find.byType(FormBuilderTextField), findsOneWidget);
  });

  testWidgets('DynamicForm wizard mode renders step title and uses AnimatedSwitcher', (WidgetTester tester) async {
    final config = FormConfig(
      isWizard: true,
      postSubmitAction: PostSubmitAction.showSuccessScreen,
      content: [
        FormStep(
          stepTitle: 'Step 1 Title',
          fields: [
            FormFieldConfig(
              name: 'field1',
              type: FormFieldType.text,
              label: 'Label 1',
            ),
          ],
        ),
        FormStep(
          stepTitle: 'Step 2 Title',
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

    expect(find.text('Step 1 Title'), findsOneWidget);
    expect(find.text('Label 1'), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });
}
