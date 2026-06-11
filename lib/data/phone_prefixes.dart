class PhonePrefix {
  final String label;
  final String value;

  const PhonePrefix({required this.label, required this.value});
}

const List<PhonePrefix> phonePrefixesAll = [
  PhonePrefix(label: '0414', value: '0414'),
  PhonePrefix(label: '0424', value: '0424'),
  PhonePrefix(label: '0412', value: '0412'),
  PhonePrefix(label: '0422', value: '0422'),
  PhonePrefix(label: '0416', value: '0416'),
  PhonePrefix(label: '0426', value: '0426'),
];

const List<String> idDocumentPrefixes = ['V', 'E', 'J', 'P', 'G', 'C'];
