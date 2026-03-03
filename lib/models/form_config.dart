enum PostSubmitAction { showSuccessScreen, redirectTo, goHome }

enum FormFieldType { text, dropdown, date, checkbox, switchType }

class FormFieldConfig {
  final String name;
  final FormFieldType type;
  final String label;
  final List<String>? options;
  final dynamic initialValue;
  final List<String>? validationRules; // e.g., ['required', 'email', 'min:6']

  FormFieldConfig({
    required this.name,
    required this.type,
    required this.label,
    this.options,
    this.initialValue,
    this.validationRules,
  });
}

class FormStep {
  final String title;
  final List<FormFieldConfig> fields;

  FormStep({
    required this.title,
    required this.fields,
  });
}

class FormConfig {
  final bool isWizard;
  final List<FormStep>? steps;
  final List<FormFieldConfig>? fields;
  final PostSubmitAction postSubmitAction;
  final String? redirectToRoute;

  FormConfig({
    required this.isWizard,
    this.steps,
    this.fields,
    required this.postSubmitAction,
    this.redirectToRoute,
  }) : assert(isWizard ? steps != null : fields != null);
}
