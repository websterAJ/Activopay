enum PostSubmitAction { showSuccessScreen, redirectTo, goHome }

enum FormFieldType { text, email, dropdown, date, checkbox, switchType }

class FormFieldConfig {
  final String name;
  final FormFieldType type;
  final String label;
  final bool isRequired;
  final List<String>? options;
  final dynamic initialValue;

  FormFieldConfig({
    required this.name,
    required this.type,
    required this.label,
    this.isRequired = false,
    this.options,
    this.initialValue,
  });

  factory FormFieldConfig.fromMap(Map<String, dynamic> map) {
    return FormFieldConfig(
      name: map['name'] ?? '',
      type: _parseType(map['type']),
      label: map['label'] ?? '',
      isRequired: map['required'] ?? false,
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      initialValue: map['initialValue'],
    );
  }

  static FormFieldType _parseType(String? type) {
    switch (type) {
      case 'email':
        return FormFieldType.email;
      case 'date':
        return FormFieldType.date;
      case 'dropdown':
        return FormFieldType.dropdown;
      case 'checkbox':
        return FormFieldType.checkbox;
      case 'switch':
        return FormFieldType.switchType;
      default:
        return FormFieldType.text;
    }
  }
}

class FormStep {
  final String stepTitle;
  final List<FormFieldConfig> fields;

  FormStep({
    required this.stepTitle,
    required this.fields,
  });

  factory FormStep.fromMap(Map<String, dynamic> map) {
    return FormStep(
      stepTitle: map['stepTitle'] ?? '',
      fields: (map['fields'] as List? ?? [])
          .map((f) => FormFieldConfig.fromMap(f))
          .toList(),
    );
  }
}

class FormConfig {
  final bool isWizard;
  final PostSubmitAction postSubmitAction;
  final String? onSuccessRoute;
  final List<FormStep> content;

  FormConfig({
    required this.isWizard,
    required this.postSubmitAction,
    this.onSuccessRoute,
    required this.content,
  });

  factory FormConfig.fromMap(Map<String, dynamic> map) {
    return FormConfig(
      isWizard: map['isWizard'] ?? false,
      postSubmitAction: _parseAction(map['postSubmitAction']),
      onSuccessRoute: map['onSuccessRoute'],
      content: (map['content'] as List? ?? [])
          .map((s) => FormStep.fromMap(s))
          .toList(),
    );
  }

  static PostSubmitAction _parseAction(String? action) {
    switch (action) {
      case 'redirectToProfile':
      case 'redirectTo':
        return PostSubmitAction.redirectTo;
      case 'goHome':
        return PostSubmitAction.goHome;
      default:
        return PostSubmitAction.showSuccessScreen;
    }
  }
}
