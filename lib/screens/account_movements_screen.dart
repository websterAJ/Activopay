import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bento_card.dart';

import '../widgets/app_bottom_nav_bar.dart';

class AccountMovementsScreen extends StatefulWidget {
  const AccountMovementsScreen({super.key});

  @override
  State<AccountMovementsScreen> createState() => _AccountMovementsScreenState();
}

class _AccountMovementsScreenState extends State<AccountMovementsScreen> {
  int _currentIndex =
      2; // Assuming 'Actividad' is at index 2 or 3 in the nav bar
  final List<String> _months = [
    'Octubre',
    'Septiembre',
    'Agosto',
    'Julio',
    'Junio',
  ];
  String _selectedMonth = 'Octubre';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark ? AppColors.slate800 : Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.navy,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movimientos de Cuenta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            Text(
              'Cuenta Corriente • **** 8291',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500,
              ),
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
                    'Bs. 0,00',
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
                            onSelected: (val) =>
                                setState(() => _selectedMonth = month),
                            selectedColor: AppColors.purpleBlue,
                            backgroundColor: isDark
                                ? AppColors.slate700
                                : AppColors.slate100,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white
                                        : AppColors.slate500),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
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
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No hay movimientos registrados',
                style: TextStyle(color: AppColors.slate500, fontSize: 14),
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
