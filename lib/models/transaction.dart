enum TransactionType { payMobile, transfer, recharge, service, pos }

class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String reference;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.reference,
    required this.type,
  });
}
