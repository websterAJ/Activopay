import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bento_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/app_bottom_nav_bar.dart';

class AccountMovementsScreen extends StatefulWidget {
  const AccountMovementsScreen({super.key});

  @override
  State<AccountMovementsScreen> createState() => _AccountMovementsScreenState();
}

class _AccountMovementsScreenState extends State<AccountMovementsScreen> {
  int _currentIndex = 2; // Assuming 'Actividad' is at index 2 or 3 in the nav bar
  final List<String> _months = ['Octubre', 'Septiembre', 'Agosto', 'Julio', 'Junio'];
  String _selectedMonth = 'Octubre';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark ? AppColors.slate800 : Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.navy),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movimientos de Cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
            Text(
              'Cuenta Corriente • **** 8291',
              style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            BentoCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance en Cuenta'.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bs. 12.450,00',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _months.map((month) {
                        final isSelected = month == _selectedMonth;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(month),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedMonth = month),
                            selectedColor: AppColors.purpleBlue,
                            backgroundColor: isDark ? AppColors.slate700 : AppColors.slate100,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.slate500),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transacciones',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Filtrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.purpleBlue,
                    elevation: 0,
                    minimumSize: const Size(90, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.slate100),
                    ),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Transactions List
            const TransactionTile(
              title: 'Farmatodo S.A.',
              subtitle: '25 Oct • 14:20 PM',
              amount: -840.00,
              date: '25 Oct',
              icon: Icons.shopping_bag,
            ),
            TransactionTile(
              title: 'Recarga Activo Pay',
              subtitle: '24 Oct • 11:45 AM',
              amount: 2500.00,
              date: '24 Oct',
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.successGreen,
            ),
            const TransactionTile(
              title: 'Restaurant La Piazzetta',
              subtitle: '24 Oct • 20:30 PM',
              amount: -1250.00,
              date: '24 Oct',
              icon: Icons.restaurant,
            ),
            const TransactionTile(
              title: 'Pago de Servicio Eléctrico',
              subtitle: '23 Oct • 09:15 AM',
              amount: -120.00,
              date: '23 Oct',
              icon: Icons.bolt,
            ),
            TransactionTile(
              title: 'Pago Móvil Recibido',
              subtitle: '22 Oct • 16:50 PM',
              amount: 5100.00,
              date: '22 Oct',
              icon: Icons.payments,
              iconColor: AppColors.successGreen,
            ),
            const TransactionTile(
              title: 'Estación de Servicio',
              subtitle: '22 Oct • 10:20 AM',
              amount: -450.00,
              date: '22 Oct',
              icon: Icons.local_gas_station,
            ),
            const SizedBox(height: 16),
            // Load more
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.slate200, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Cargar más movimientos (14 de 20)',
                  style: TextStyle(
                    color: AppColors.purpleBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
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

// Simple DashStyle extension if needed, or just regular OutlinedButton
extension DashStyleExtension on BorderSide {
  // Mocking dash style as it's not natively supported on simple BorderSide
}
