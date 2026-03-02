class Contact {
  final String id;
  final String name;
  final String bank;
  final String documentType;
  final String documentNumber;
  final String phone;
  final String accountNumber;
  final bool isFavorite;

  Contact({
    required this.id,
    required this.name,
    required this.bank,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
    required this.accountNumber,
    this.isFavorite = false,
  });
}
