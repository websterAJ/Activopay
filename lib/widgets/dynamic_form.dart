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
  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: widget.config.isWizard ? _buildWizardBody() : _buildStandardBody(),
    );
  }

  Widget _buildStandardBody() {
    final allFields = widget.config.content.expand((s) => s.fields).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...allFields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _buildField(f),
              )),
          const SizedBox(height: 30),
          _buildSubmitButton('Enviar'),
        ],
      ),
    );
  }

  Widget _buildWizardBody() {
    final currentStep = widget.config.content[_currentStepIndex];

    return Column(
      children: [
        _buildWizardHeader(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              key: ValueKey<int>(_currentStepIndex),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentStep.stepTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...currentStep.fields.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: _buildField(f),
                      )),
                ],
              ),
            ),
          ),
        ),
        _buildWizardControls(),
      ],
    );
  }

  Widget _buildWizardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: List.generate(widget.config.content.length, (index) {
          final isCompleted = index < _currentStepIndex;
          final isCurrent = index == _currentStepIndex;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent ? Theme.of(context).primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWizardControls() {
    final isLastStep = _currentStepIndex == widget.config.content.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          if (_currentStepIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStepIndex--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Anterior'),
              ),
            ),
          if (_currentStepIndex > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLastStep ? _handleSubmit : _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(isLastStep ? 'Finalizar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildField(FormFieldConfig f) {
    List<String? Function(dynamic)> validators = [];
    if (f.isRequired) {
      validators.add(FormBuilderValidators.required(errorText: 'Este campo es obligatorio'));
    }
    if (f.type == FormFieldType.email) {
      validators.add((value) => FormBuilderValidators.email(errorText: 'Ingrese un email válido')(value?.toString()));
    }

    final decoration = InputDecoration(
      labelText: f.label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
    );

    switch (f.type) {
      case FormFieldType.text:
      case FormFieldType.email:
        return FormBuilderTextField(
          name: f.name,
          decoration: decoration,
          validator: FormBuilderValidators.compose(validators),
          initialValue: f.initialValue,
        );
      case FormFieldType.date:
        return FormBuilderDateTimePicker(
          name: f.name,
          decoration: decoration,
          inputType: InputType.date,
          validator: FormBuilderValidators.compose(validators),
          initialValue: f.initialValue,
        );
      case FormFieldType.dropdown:
        return FormBuilderDropdown<String>(
          name: f.name,
          decoration: decoration,
          items: f.options?.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList() ?? [],
          validator: FormBuilderValidators.compose(validators),
          initialValue: f.initialValue,
        );
      case FormFieldType.checkbox:
        return FormBuilderCheckbox(
          name: f.name,
          title: Text(f.label),
          initialValue: f.initialValue ?? false,
          validator: FormBuilderValidators.compose(validators),
        );
      case FormFieldType.switchType:
        return FormBuilderSwitch(
          name: f.name,
          title: Text(f.label),
          initialValue: f.initialValue ?? false,
          validator: FormBuilderValidators.compose(validators),
        );
    }
  }

  void _nextStep() {
    final currentStepFields = widget.config.content[_currentStepIndex].fields;
    bool isValid = true;
    for (var f in currentStepFields) {
      final fieldState = _formKey.currentState?.fields[f.name];
      if (fieldState != null) {
        if (!fieldState.validate()) {
          isValid = false;
        }
      }
    }

    if (isValid) {
      setState(() => _currentStepIndex++);
    }
  }

  void _handleSubmit() {
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
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SuccessView()));
        break;
      case PostSubmitAction.redirectTo:
        if (widget.config.onSuccessRoute != null) {
          Navigator.of(context).pushNamed(widget.config.onSuccessRoute!);
        }
        break;
      case PostSubmitAction.goHome:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
    }
  }
}
