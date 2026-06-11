import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/bento_card.dart';
import '../data/banks.dart';
import 'amount_pin_screen.dart';

class ContactOperationsScreen extends StatelessWidget {
  const ContactOperationsScreen({super.key});

  String _getCleanBankName(String bankCodeOrName) {
    final found = banks.firstWhere(
      (b) => b.code == bankCodeOrName || b.name.toLowerCase() == bankCodeOrName.toLowerCase(),
      orElse: () => Bank(code: '', name: bankCodeOrName),
    );
    String name = found.name;
    if (name == 'Seleccione un banco' || name.isEmpty) return '';
    
    // Clean up suffixes
    name = name
        .replaceAll(RegExp(r',?\s*S\.A\.?\s*(BANCO UNIVERSAL)?', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*C\.A\.?\s*(BANCO UNIVERSAL)?', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*BANCO UNIVERSAL.*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(.*?\)', caseSensitive: false), '')
        .trim();

    // Convert to Title Case
    if (name.toUpperCase() == name) {
      name = name.split(' ').map((word) {
        if (word.isEmpty) return '';
        final lower = word.toLowerCase();
        if (['de', 'del', 'la', 'y', 'el', 'c.a.'].contains(lower)) return lower;
        return word[0] + word.substring(1).toLowerCase();
      }).join(' ');
      // capitalize first word anyway
      if (name.isNotEmpty) {
        name = name[0].toUpperCase() + name.substring(1);
      }
    }
    return name;
  }

  String _formatDocument(String tp, String doc) {
    if (doc.isEmpty) return '';
    final cleanDoc = doc.replaceAll(RegExp(r'\D'), '');
    if (cleanDoc.isEmpty) return tp.isNotEmpty ? '$tp-$doc' : doc;
    final buffer = StringBuffer();
    for (int i = 0; i < cleanDoc.length; i++) {
      buffer.write(cleanDoc[i]);
      final remaining = cleanDoc.length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return tp.isNotEmpty ? '$tp-$buffer' : buffer.toString();
  }

  String _formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 11) {
      return '${cleanPhone.substring(0, 4)}-${cleanPhone.substring(4)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contact = ModalRoute.of(context)?.settings.arguments;

    final String name = contact is ContactItem
        ? contact.name
        : (contact is Map<String, dynamic>
            ? (contact['name']?.toString() ?? 'Contacto')
            : 'Contacto');

    final String tpdocument = contact is ContactItem
        ? contact.tpdocument
        : (contact is Map<String, dynamic>
            ? (contact['tpdocument']?.toString() ?? '')
            : '');

    final String document = contact is ContactItem
        ? contact.document
        : (contact is Map<String, dynamic>
            ? (contact['document']?.toString() ?? '')
            : '');

    final String phone = contact is ContactItem
        ? contact.phone
        : (contact is Map<String, dynamic>
            ? (contact['phone']?.toString() ?? '')
            : '');

    final String bankCode = contact is ContactItem
        ? contact.bank
        : (contact is Map<String, dynamic>
            ? (contact['bank']?.toString() ?? '')
            : '');

    final String formattedDoc = _formatDocument(tpdocument, document);
    final String bankName = _getCleanBankName(bankCode);
    final String formattedPhone = _formatPhone(phone);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Operar con contacto',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BentoCard(
              backgroundColor: AppColors.navy,
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, top: -20,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.purpleBlue.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                height: 1.2,
                              ),
                            ),
                            if (formattedDoc.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                formattedDoc,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (bankName.isNotEmpty || formattedPhone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (bankName.isNotEmpty) bankName,
                                  if (formattedPhone.isNotEmpty) formattedPhone,
                                ].join(' • '),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '¿QUÉ DESEAS HACER?',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.slate400,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _OperationCard(
              title: 'P2P (Pago Móvil)',
              subtitle: 'Envía bolívares al instante de forma segura y sencilla.',
              icon: Icons.bolt,
              onTap: () => _navigateToOperation(context, '1', 'P2P (Pago Móvil)', contact),
            ),
            const SizedBox(height: 16),
            _OperationCard(
              title: 'C2P (Cobro)',
              subtitle: 'Realiza un cobro a este contacto de forma inmediata.',
              icon: Icons.request_quote,
              onTap: () => _navigateToOperation(context, '2', 'C2P (Cobro)', contact),
            ),
            const SizedBox(height: 16),
            _OperationCard(
              title: 'Transferencia',
              subtitle: 'Envío tradicional a cuentas del mismo banco o terceros.',
              icon: Icons.account_balance,
              onTap: () => _navigateToOperation(context, '3', 'Transferencia', contact),
            ),
            const SizedBox(height: 16),
            _OperationCard(
              title: 'Débito Inmediato',
              subtitle: 'Debita fondos directamente con aprobación al momento.',
              icon: Icons.speed,
              onTap: () => _navigateToOperation(context, '6', 'Débito Inmediato', contact),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, 'edit'),
                child: const Text(
                  'Editar detalles del contacto',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOperation(BuildContext context, String operationId, String operationName, dynamic contact) {
    Map<String, dynamic>? params;
    if (contact is ContactItem) {
      params = {
        'id': contact.id,
        'name': contact.name,
        'tpdocument': contact.tpdocument,
        'document': contact.document,
        'phone': contact.phone,
        'account': contact.account,
        'bank': contact.bank,
        'type': contact.type,
      };
    } else if (contact is Map<String, dynamic>) {
      params = contact;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmountPinScreen(
          operationId: operationId,
          operationName: operationName,
          params: params,
        ),
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _OperationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.purpleBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.purpleBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.slate300,
            size: 20,
          ),
        ],
      ),
    );
  }
}
