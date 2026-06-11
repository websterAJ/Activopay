import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bento_card.dart';
import '../services/operation_service.dart';

class TransactionFoundScreen extends StatefulWidget {
  const TransactionFoundScreen({super.key});

  @override
  State<TransactionFoundScreen> createState() => _TransactionFoundScreenState();
}

class _TransactionFoundScreenState extends State<TransactionFoundScreen> {
  bool _isLoading = false;

  Future<void> _validateItem(Map<String, dynamic> item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar operación'),
        content: const Text('¿Está seguro de que desea validar esta operación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleBlue),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await OperationService.confirmTransactionValidation(item);
      
      if (!mounted) return;

      if (result.success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Éxito'),
            content: Text('Transacción validada con éxito.\nN° de referencia: ${result.referenceNumber ?? "N/A"}'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleBlue),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.popUntil(context, ModalRoute.withName('/home')); // Go back to home
                },
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final args = ModalRoute.of(context)?.settings.arguments;
    final List<dynamic> transactions = (args is List) ? args : [];

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.purpleBlue))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transacciones Encontradas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecciona la transacción que deseas validar',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                
                if (transactions.isEmpty)
                  const Center(
                    child: Text(
                      'No se encontraron transacciones',
                      style: TextStyle(color: AppColors.slate500, fontSize: 14),
                    ),
                  )
                else
                  ...transactions.map((item) {
                    final itemMap = item as Map<String, dynamic>;
                    final amount = double.tryParse(itemMap['credito']?.toString() ?? '0') ?? 0.0;
                    final ref = itemMap['referencia']?.toString() ?? 'N/A';
                    final date = itemMap['fecha']?.toString() ?? 'N/A';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _TransactionCard(
                        amount: amount,
                        reference: ref,
                        date: date,
                        onTap: () => _validateItem(itemMap),
                      ),
                    );
                  }),
                
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '¿No encuentras tu transacción? Verifica que los datos ingresados sean correctos o intenta nuevamente en unos minutos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.slate400,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Modificar búsqueda',
                          style: TextStyle(
                            color: AppColors.purpleBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Ref: ',
                    style: TextStyle(fontSize: 13, color: AppColors.slate500),
                  ),
                  Text(
                    reference,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.slate300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 13, color: AppColors.slate500),
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
