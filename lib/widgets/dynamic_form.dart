import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../models/form_config.dart';
import 'success_view.dart';

class DynamicForm extends StatefulWidget {
  final FormConfig config;
  final Function(Map<String, dynamic>)? onSubmit;

  const DynamicForm({super.key, required this.config, this.onSubmit});

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return widget.config.isWizard ? _buildWizard() : _buildStandardForm();
  }

  Widget _buildStandardForm() {
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...widget.config.fields!.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildField(f),
            )).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Enviar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWizard() {
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          final stepFields = widget.config.steps![_currentStep].fields;
          bool stepValid = true;

          // Validate only fields in the current step
          for (var field in stepFields) {
             final state = _formKey.currentState?.fields[field.name];
             if (state != null) {
               if (!state.validate()) {
                 stepValid = false;
               }
             }
          }

          if (stepValid) {
            if (_currentStep < widget.config.steps!.length - 1) {
              setState(() => _currentStep++);
            } else {
              _submitForm();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: widget.config.steps!.map((step) {
          int index = widget.config.steps!.indexOf(step);
          return Step(
            title: Text(step.title),
            content: Column(
              children: step.fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildField(f),
              )).toList(),
            ),
            isActive: _currentStep >= index,
            state: _currentStep > index ? StepState.complete : StepState.indexed,
          );
        }).toList(),
        controlsBuilder: (context, controls) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: controls.onStepContinue,
                    child: Text(_currentStep == widget.config.steps!.length - 1 ? 'Finalizar' : 'Siguiente'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controls.onStepCancel,
                      child: const Text('Anterior'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(FormFieldConfig config) {
    List<String? Function(dynamic)> validators = [];
    if (config.validationRules != null) {
      for (var rule in config.validationRules!) {
        if (rule == 'required') {
          validators.add(FormBuilderValidators.required(errorText: 'Este campo es obligatorio'));
        } else if (rule == 'email') {
          validators.add((value) => FormBuilderValidators.email(errorText: 'Ingrese un email válido')(value?.toString()));
        } else if (rule.startsWith('min:')) {
          final min = int.tryParse(rule.split(':')[1]) ?? 0;
          validators.add(FormBuilderValidators.minLength(min, errorText: 'Mínimo $min caracteres'));
        }
      }
    }

    final decoration = InputDecoration(
      labelText: config.label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );

    switch (config.type) {
      case FormFieldType.text:
        return FormBuilderTextField(
          name: config.name,
          decoration: decoration,
          validator: FormBuilderValidators.compose(validators),
          initialValue: config.initialValue,
        );
      case FormFieldType.dropdown:
        return FormBuilderDropdown<String>(
          name: config.name,
          decoration: decoration,
          items: config.options!
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          validator: FormBuilderValidators.compose(validators),
          initialValue: config.initialValue,
        );
      case FormFieldType.date:
        return FormBuilderDateTimePicker(
          name: config.name,
          decoration: decoration,
          inputType: InputType.date,
          validator: FormBuilderValidators.compose(validators),
          initialValue: config.initialValue,
        );
      case FormFieldType.checkbox:
        return FormBuilderCheckbox(
          name: config.name,
          title: Text(config.label),
          validator: FormBuilderValidators.compose(validators),
          initialValue: config.initialValue ?? false,
          decoration: const InputDecoration(border: InputBorder.none),
        );
      case FormFieldType.switchType:
        return FormBuilderSwitch(
          name: config.name,
          title: Text(config.label),
          validator: FormBuilderValidators.compose(validators),
          initialValue: config.initialValue ?? false,
          decoration: const InputDecoration(border: InputBorder.none),
        );
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(_formKey.currentState!.value);
      }
      _handleNavigation();
    }
  }

  void _handleNavigation() {
    switch (widget.config.postSubmitAction) {
      case PostSubmitAction.showSuccessScreen:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SuccessView()),
        );
        break;
      case PostSubmitAction.redirectTo:
        if (widget.config.redirectToRoute != null) {
          Navigator.of(context).pushNamed(widget.config.redirectToRoute!);
        }
        break;
      case PostSubmitAction.goHome:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
    }
  }
}
