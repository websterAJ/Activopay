import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../services/secure_storage_service.dart';
import 'limits_bottom_sheet.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = '';
  String _userEmail = '';
  bool _isBiometricEnabled = false;
  bool _isLoadingBiometrics = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadSettings();
  }

  Future<void> _loadUser() async {
    final name = await SecureStorageService.getUserName() ?? '';
    final email = await SecureStorageService.getEmailAliado() ?? '';
    if (mounted) setState(() { _userName = name; _userEmail = email; });
  }

  Future<void> _loadSettings() async {
    final biometricEnabled = await SecureStorageService.isBiometricEnabled();
    setState(() {
      _isBiometricEnabled = biometricEnabled;
      _isLoadingBiometrics = false;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      final result = await AuthService.enrollBiometric();
      if (result.success) {
        setState(() => _isBiometricEnabled = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      await SecureStorageService.setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.slate800 : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Configuración',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(textColor),
                    const SizedBox(height: 24),
                    _buildSectionHeader('SEGURIDAD'),
                    _buildSettingsGroup(
                      [
                        _buildToggleItem(
                          icon: Icons.fingerprint,
                          label: 'Biometría (Face ID)',
                          value: _isBiometricEnabled,
                          onChanged: _isLoadingBiometrics ? null : _toggleBiometrics,
                        ),
                        _buildNavigationItem(
                          icon: Icons.lock_outline,
                          label: 'Cambiar Contraseña',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                          ),
                        ),
                        _buildNavigationItem(
                          icon: Icons.pin_outlined,
                          label: 'Cambiar PIN de Operaciones',
                          onTap: () =>
                              Navigator.pushNamed(context, '/change-operations-pin'),
                        ),
                        _buildNavigationItem(
                          icon: Icons.tune,
                          label: 'Límites de Operaciones',
                          onTap: () => showLimitsBottomSheet(context),
                        ),
                      ],
                      cardColor,
                      textColor,
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    _buildFooter(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.purpleBlue.withOpacity(0.1),
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName.isNotEmpty ? _userName : 'Cargando...',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userEmail.isNotEmpty ? _userEmail : '...',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver Perfil',
                        style: TextStyle(
                          color: AppColors.purpleBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: AppColors.purpleBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    List<Widget> items,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          _buildIconContainer(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.purpleBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            _buildIconContainer(icon),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, {Color? color, Color? iconColor}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color ?? AppColors.purpleBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor ?? AppColors.purpleBlue, size: 22),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Términos de Servicio',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
            Text('•', style: TextStyle(color: Colors.grey[300])),
            TextButton(
              onPressed: () {},
              child: Text(
                'Política de Privacidad',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Activo Pay Versión 4.12.0 (2024)',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
