import 'package:flutter/material.dart';
import '../models/form_config.dart';
import '../widgets/dynamic_form.dart';

class DynamicFormDemoScreen extends StatelessWidget {
  const DynamicFormDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wizardConfig = FormConfig(
      isWizard: true,
      postSubmitAction: PostSubmitAction.showSuccessScreen,
      steps: [
        FormStep(
          title: 'Información Personal',
          fields: [
            FormFieldConfig(
              name: 'full_name',
              type: FormFieldType.text,
              label: 'Nombre Completo',
              validationRules: ['required'],
            ),
            FormFieldConfig(
              name: 'email',
              type: FormFieldType.text,
              label: 'Correo Electrónico',
              validationRules: ['required', 'email'],
            ),
          ],
        ),
        FormStep(
          title: 'Preferencias',
          fields: [
            FormFieldConfig(
              name: 'notification_type',
              type: FormFieldType.dropdown,
              label: 'Tipo de Notificación',
              options: ['Email', 'SMS', 'Push'],
              initialValue: 'Email',
            ),
            FormFieldConfig(
              name: 'birth_date',
              type: FormFieldType.date,
              label: 'Fecha de Nacimiento',
            ),
          ],
        ),
        FormStep(
          title: 'Confirmación',
          fields: [
            FormFieldConfig(
              name: 'accept_terms',
              type: FormFieldType.checkbox,
              label: 'Acepto los términos y condiciones',
              validationRules: ['required'],
            ),
            FormFieldConfig(
              name: 'newsletter',
              type: FormFieldType.switchType,
              label: 'Suscribirse al boletín',
              initialValue: true,
            ),
          ],
        ),
      ],
    );

    final standardConfig = FormConfig(
      isWizard: false,
      postSubmitAction: PostSubmitAction.goHome,
      fields: [
        FormFieldConfig(
          name: 'subject',
          type: FormFieldType.text,
          label: 'Asunto',
          validationRules: ['required'],
        ),
        FormFieldConfig(
          name: 'category',
          type: FormFieldType.dropdown,
          label: 'Categoría',
          options: ['Soporte', 'Ventas', 'Feedback'],
          validationRules: ['required'],
        ),
        FormFieldConfig(
          name: 'message',
          type: FormFieldType.text,
          label: 'Mensaje',
          validationRules: ['required', 'min:10'],
        ),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Form Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Wizard'),
              Tab(text: 'Standard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DynamicForm(
              config: wizardConfig,
              onSubmit: (data) => print('Wizard Data: $data'),
            ),
            DynamicForm(
              config: standardConfig,
              onSubmit: (data) => print('Standard Data: $data'),
            ),
          ],
        ),
      ),
    );
  }
}
