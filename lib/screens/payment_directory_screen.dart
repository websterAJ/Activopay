import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bento_card.dart';
import '../widgets/app_bottom_nav_bar.dart';

class PaymentDirectoryScreen extends StatefulWidget {
  const PaymentDirectoryScreen({super.key});

  @override
  State<PaymentDirectoryScreen> createState() => _PaymentDirectoryScreenState();
}

class _PaymentDirectoryScreenState extends State<PaymentDirectoryScreen> {
  int _currentIndex = 2; // Contacts tab

  final List<Map<String, String>> _contacts = [
    {'name': 'Carlos Pérez', 'bank': 'Banesco', 'favorite': 'true'},
    {'name': 'Maria García', 'bank': 'Mercantil', 'favorite': 'true'},
    {'name': 'Juan Rodríguez', 'bank': 'Banco Activo', 'favorite': 'false'},
    {'name': 'Ana López', 'bank': 'BBVA Provincial', 'favorite': 'true'},
    {'name': 'David Méndez', 'bank': 'BNC', 'favorite': 'false'},
    {'name': 'Sofía Torres', 'bank': 'Banplus', 'favorite': 'false'},
    {'name': 'Ricardo Vargas', 'bank': 'Bancamiga', 'favorite': 'false'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: (isDark ? AppColors.backgroundDark : Colors.white).withOpacity(0.9),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            _CircularIconButton(
              icon: Icons.arrow_back_ios_new,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            const Text(
              'Directorio de Pago',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
            const Spacer(),
            _CircularIconButton(icon: Icons.filter_list, onPressed: () {}),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar contacto o banco...',
                prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                filled: true,
                fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Add New Contact Button
            BentoCard(
              backgroundColor: AppColors.purpleBlue,
              onTap: () => Navigator.pushNamed(context, '/create-contact'),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agregar Nuevo Contacto',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        'Crea un nuevo beneficiario para pagos',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tus Contactos',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('A-Z', style: TextStyle(color: AppColors.purpleBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Contact List
            ..._contacts.map((contact) => _ContactRow(
              name: contact['name']!,
              bank: contact['bank']!,
              isFavorite: contact['favorite'] == 'true',
              onTap: () {
                Navigator.pushNamed(context, '/contact-operations', arguments: contact);
              },
            )),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.purpleBlue,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircularIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.navy),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String name;
  final String bank;
  final bool isFavorite;
  final VoidCallback onTap;

  const _ContactRow({
    required this.name,
    required this.bank,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isDark ? AppColors.slate800 : AppColors.slate50)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy),
                ),
                Text(
                  bank,
                  style: TextStyle(color: AppColors.slate500, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? AppColors.orange : AppColors.slate300,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: AppColors.slate300),
          ],
        ),
      ),
    );
  }
}
