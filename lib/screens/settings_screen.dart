import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart' as app_api;
import '../theme/app_colors.dart';
import '../services/secure_storage_service.dart';
import '../services/biometric_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<app_api.UserData> _userFuture;
  bool _isBiometricEnabled = false;
  bool _isPushNotificationsEnabled = true;
  bool _isLoadingBiometrics = true;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
    _loadSettings();
  }

  Future<app_api.UserData> _loadUser() async {
    try {
      final userData = await app_api.ApiService.getCurrentUser();
      return app_api.UserData(
        id: userData['id'] ?? '',
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
      );
    } catch (e) {
      return app_api.UserData(id: '', email: 'alex.t@activopay.com', name: 'Alex Thompson');
    }
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
            SnackBar(content: Text(result.message), backgroundColor: Colors.red),
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
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.slate800 : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.purpleBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(textColor),
            const SizedBox(height: 24),
            _buildSectionHeader('SEGURIDAD'),
            _buildSettingsGroup([
              _buildToggleItem(
                icon: Icons.fingerprint,
                label: 'Biometría (Face ID)',
                value: _isBiometricEnabled,
                onChanged: _isLoadingBiometrics ? null : _toggleBiometrics,
              ),
              _buildNavigationItem(
                icon: Icons.lock_outline,
                label: 'Cambiar Contraseña',
                onTap: () => Navigator.pushNamed(context, '/change-operations-pin'),
              ),
            ], cardColor, textColor),
            const SizedBox(height: 24),
            _buildSectionHeader('PREFERENCIAS'),
            _buildSettingsGroup([
              _buildToggleItem(
                icon: Icons.notifications_none,
                label: 'Notificaciones Push',
                value: _isPushNotificationsEnabled,
                onChanged: (value) => setState(() => _isPushNotificationsEnabled = value),
              ),
              _buildNavigationItem(
                icon: Icons.language,
                label: 'Idioma',
                trailing: 'Español',
                onTap: () {},
              ),
            ], cardColor, textColor),
            const SizedBox(height: 24),
            _buildSectionHeader('CUENTA'),
            _buildSettingsGroup([
              _buildNavigationItem(
                icon: Icons.account_balance_outlined,
                label: 'Cuentas Bancarias Vinculadas',
                onTap: () => Navigator.pushNamed(context, '/payment-directory'),
              ),
              _buildActionItem(
                icon: Icons.logout,
                label: 'Cerrar Sesión',
                color: Colors.red,
                onTap: () async {
                  await AuthService.logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ], cardColor, Colors.red),
            const SizedBox(height: 48),
            _buildFooter(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color textColor) {
    return FutureBuilder<app_api.UserData>(
      future: _userFuture,
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? 'Cargando...';
        final email = snapshot.data?.email ?? '...';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark : Colors.white,
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.purpleBlue.withOpacity(0.1), width: 4),
                  image: DecorationImage(
                    image: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuChUThFdVR0O1QS-mDhu0uMS3x9WtpDbwnTONJPBbxJ6VILG--3-mUpfIQ2SShfqIBKglzvn4SI6gQMojopoAfuLsN9ezOTvp7BksYyOeCCmuS2aVcObGl_HV-rThgFGVRAjw0RPpxofBP4YjxtrDmxPW2OiS9z72qX2YU2pV17D0kxdzVw0KXa1e3pjsux3wMYDSz_1cvKE-7Kk5--iyr3dIKXATQVqfMRyYBIXnOAps0ivii0qwadzPYqmRJfTyF3o7yiWVh2xKI'),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) => debugPrint('Error loading profile image'),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
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
                          Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.purpleBlue),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildSettingsGroup(List<Widget> items, Color backgroundColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: items,
      ),
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
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
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
          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
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

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            _buildIconContainer(icon, color: color.withOpacity(0.1), iconColor: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
              ),
            ),
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
          style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
