import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bento_card.dart';

class TransactionFoundScreen extends StatelessWidget {
  const TransactionFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Validar Transferencia',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transacciones Encontradas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona la transacción que deseas validar',
              style: TextStyle(fontSize: 14, color: AppColors.slate500, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            _TransactionCard(
              amount: 1250.00,
              reference: '#482930',
              date: '12 Oct, 2023',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _TransactionCard(
              amount: 450.25,
              reference: '#482711',
              date: '11 Oct, 2023',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _TransactionCard(
              amount: 3000.00,
              reference: '#482650',
              date: '10 Oct, 2023',
              onTap: () {},
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '¿No encuentras tu transacción? Verifica que los datos ingresados sean correctos o intenta nuevamente en unos minutos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.slate400, fontSize: 12, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Modificar búsqueda',
                      style: TextStyle(color: AppColors.purpleBlue, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final double amount;
  final String reference;
  final String date;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.amount,
    required this.reference,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MONTO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purpleBlue,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bs. ${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Ref: ',
                    style: TextStyle(fontSize: 13, color: AppColors.slate500),
                  ),
                  Text(
                    reference,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.slate300, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: TextStyle(fontSize: 13, color: AppColors.slate500),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: AppColors.slate300),
        ],
      ),
    );
  }
}
