import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bento_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/app_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.8),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.transparent),
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.navy.withOpacity(0.05),
                    child: const Icon(Icons.person, color: AppColors.navy, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, Carlos',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.slate500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Activo Pay',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _CircularIconButton(icon: Icons.notifications),
                  const SizedBox(width: 8),
                  _CircularIconButton(icon: Icons.settings),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Balance Card
                BentoCard(
                  backgroundColor: AppColors.navy,
                  padding: const EdgeInsets.all(24),
                  child: Stack(
                    children: [
                      // Background decorative elements (simplified)
                      Positioned(
                        right: -40,
                        top: -40,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.purpleBlue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saldo Principal'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isBalanceVisible ? 'Bs. 12.450,00' : 'Bs. ••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuickAction(icon: Icons.payments, label: 'Vuelto'),
                    _QuickAction(icon: Icons.request_quote, label: 'Cobro'),
                    _QuickAction(icon: Icons.fact_check, label: 'Validar pago'),
                    _QuickAction(icon: Icons.more_horiz, label: 'Más'),
                  ],
                ),
                const SizedBox(height: 32),
                // Recent Activity Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Actividad Reciente',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Ver todo',
                        style: TextStyle(
                          color: AppColors.purpleBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Activity List
                const TransactionTile(
                  title: 'Farmatodo S.A.',
                  subtitle: 'Hace 2 horas • Pago Móvil',
                  amount: -840.00,
                  date: 'Hace 2 horas',
                  icon: Icons.shopping_cart,
                ),
                TransactionTile(
                  title: 'Transferencia recibida',
                  subtitle: 'Ayer • De Maria Perez',
                  amount: 908.75,
                  date: 'Ayer',
                  icon: Icons.person,
                  iconColor: AppColors.purpleBlue,
                ),
                const TransactionTile(
                  title: 'Restaurant La Piazzetta',
                  subtitle: '24 Oct • Tarjeta',
                  amount: -1250.00,
                  date: '24 Oct',
                  icon: Icons.restaurant,
                ),
                const TransactionTile(
                  title: 'Estación de Servicio',
                  subtitle: '23 Oct • Biopago',
                  amount: -450.00,
                  date: '23 Oct',
                  icon: Icons.local_gas_station,
                ),
                const SizedBox(height: 80), // Padding for bottom bar
              ]),
            ),
          ),
        ],
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

  const _CircularIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.slate100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: AppColors.navy),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.slate100),
          ),
          child: Icon(icon, color: AppColors.purpleBlue, size: 32),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 76,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
