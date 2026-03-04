import 'package:flutter/material.dart';
import '../models/form_config.dart';
import '../widgets/dynamic_form.dart';

class DynamicFormDemoScreen extends StatelessWidget {
  const DynamicFormDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> wizardJson = {
      "isWizard": true,
      "postSubmitAction": "showSuccessScreen",
      "content": [
        {
          "stepTitle": "Datos Personales",
          "fields": [
            {"name": "fullname", "type": "text", "label": "Nombre Completo", "required": true},
            {"name": "birthdate", "type": "date", "label": "Fecha Nacimiento", "required": false}
          ]
        },
        {
          "stepTitle": "Contacto",
          "fields": [
            {"name": "email", "type": "email", "label": "Correo", "required": true}
          ]
        }
      ]
    };

    final Map<String, dynamic> standardJson = {
      "isWizard": false,
      "postSubmitAction": "goHome",
      "content": [
        {
          "stepTitle": "Simple Form",
          "fields": [
            {"name": "subject", "type": "text", "label": "Asunto", "required": true},
            {"name": "message", "type": "text", "label": "Mensaje", "required": true}
          ]
        }
      ]
    };

    final wizardConfig = FormConfig.fromMap(wizardJson);
    final standardConfig = FormConfig.fromMap(standardJson);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Form Engine'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Wizard Mode'),
              Tab(text: 'Standard Mode'),
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
