import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'receive_payment_qr_screen.dart';
import 'make_payment_qr_screen.dart';

class QrOperationsScreen extends StatelessWidget {
  const QrOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '¿Qué deseas hacer?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _QrOptionCard(
                title: 'Realizar un Pago',
                subtitle: 'Envía dinero al instante\nmediante código QR',
                backgroundColor: AppColors.purpleBlue,
                textColor: Colors.white,
                icon: Icons.payments_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MakePaymentQrScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _QrOptionCard(
                title: 'Recibir un Pago',
                subtitle: 'Muestra tu código para\ncobrar rápidamente',
                backgroundColor: AppColors.navy,
                textColor: Colors.white,
                icon: Icons.qr_code_2,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReceivePaymentQrScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback onTap;

  const _QrOptionCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Decorative background element (the phone shape outline)
              Positioned(
                right: -40,
                bottom: -20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    width: 200,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 12),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: textColor,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
