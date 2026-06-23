import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

enum SuccessScreenType { payment, validation, receipt }

class OperationSuccessScreen extends StatelessWidget {
  final SuccessScreenType type;
  final String title;
  final String subtitle;
  final double amount;
  final String? reference;
  final DateTime? date;
  
  // Custom fields
  final String? recipientName;
  final String? bankName;
  final String? concept;
  final String? operationType;

  const OperationSuccessScreen({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.reference,
    this.date,
    this.recipientName,
    this.bankName,
    this.concept,
    this.operationType,
  });

  String _formatAmount(double amt) {
    final formatter = NumberFormat.currency(locale: 'es_VE', symbol: 'Bs.', decimalDigits: 2);
    return formatter.format(amt);
  }

  String _formatDate(DateTime dt) {
    final formatter = DateFormat('dd MMM yyyy - hh:mm a');
    return formatter.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bool isReceipt = type == SuccessScreenType.receipt;
    final bool isValidation = type == SuccessScreenType.validation;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FE),
      appBar: isReceipt || isValidation ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.navy),
          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
        ),
        title: Text(
          isValidation ? 'Validación Exitosa' : 'Comprobante',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(height: isReceipt || isValidation ? 24 : 64),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      color: AppColors.purpleBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.purpleBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleBlue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, size: 48, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              if (!isValidation) ...[
                const SizedBox(height: 32),
                Text(
                  _formatAmount(amount),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.navy,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navy : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    if (isValidation) ...[
                      _buildDetailRow('Monto', _formatAmount(amount), isDark: isDark, isBoldValue: true),
                      const SizedBox(height: 24),
                    ],
                    if (recipientName != null) ...[
                      _buildDetailRow(isReceipt ? 'Comercio' : 'Destinatario', recipientName!, isDark: isDark, isBoldValue: true),
                      const SizedBox(height: 24),
                    ],
                    if (bankName != null) ...[
                      _buildDetailRow('Banco', bankName!, isDark: isDark, isBoldValue: true),
                      const SizedBox(height: 24),
                    ],
                    _buildDetailRow(isValidation ? 'Referencia' : 'Número de referencia', '#${reference ?? "N/A"}', isDark: isDark, isBoldValue: true),
                    const SizedBox(height: 24),
                    _buildDetailRow(isValidation ? 'Fecha' : 'Fecha y hora', _formatDate(date ?? DateTime.now()), isDark: isDark, isBoldValue: true),
                    if (concept != null || operationType != null) ...[
                      const SizedBox(height: 24),
                      _buildDetailRow(
                        isValidation ? 'Tipo' : (isReceipt ? 'Método de Pago' : 'Concepto'), 
                        concept ?? operationType ?? '', 
                        isDark: isDark, 
                        isBoldValue: true
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
              if (type == SuccessScreenType.payment || type == SuccessScreenType.receipt) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Share action logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    label: const Text(
                      'Compartir Comprobante',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/home'));
                  },
                  child: const Text(
                    'Ir al Inicio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purpleBlue,
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ir al Inicio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OperationSuccessScreen(
                          type: SuccessScreenType.receipt,
                          title: 'Pago Realizado con Éxito',
                          subtitle: '',
                          amount: amount,
                          reference: reference,
                          date: date,
                          recipientName: recipientName,
                          operationType: operationType ?? 'Transferencia Bancaria',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Ver Comprobante',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purpleBlue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {required bool isDark, bool isBoldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : AppColors.navy,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
