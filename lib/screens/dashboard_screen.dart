import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

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
                  const SizedBox(width: 8),
                  _CircularIconButton(
                    icon: Icons.logout,
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildListDelegate([
                _QuickAction(
                  icon: Icons.payments,
                  label: 'Vuelto',
                  onTap: () => Navigator.pushNamed(context, '/account-movements'),
                ),
                _QuickAction(
                  icon: Icons.request_quote,
                  label: 'Cobro',
                  onTap: () => Navigator.pushNamed(context, '/contact-operations'),
                ),
                _QuickAction(
                  icon: Icons.fact_check,
                  label: 'Validar pago',
                  onTap: () => Navigator.pushNamed(context, '/validate-payment'),
                ),
                _QuickAction(
                  icon: Icons.local_atm,
                  label: 'Pagos de Servicios',
                  onTap: () => Navigator.pushNamed(context, '/payment-directory'),
                ),
                _QuickAction(
                  icon: Icons.bar_chart,
                  label: 'Reportes',
                  onTap: () => Navigator.pushNamed(context, '/account-movements'),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.pushNamed(context, '/settings');
          } else {
            setState(() => _currentIndex = index);
          }
        },
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
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
            child: Icon(icon, color: AppColors.purpleBlue, size: 42),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 86,
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
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _CircularIconButton({
    required this.icon,
    this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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
        child: Icon(icon, size: size * 0.55, color: AppColors.navy),
      ),
    );
  }
}
