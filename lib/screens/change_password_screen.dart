import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/settings_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _obscurePin = true;
  bool _isLoading = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _onChangePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final pin = _pinController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || pin.isEmpty) {
      _showError('Por favor completa todos los campos.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Las nuevas contraseñas no coinciden.');
      return;
    }

    if (pin.length != 4) {
      _showError('El PIN debe tener exactamente 4 dígitos.');
      return;
    }

    setState(() => _isLoading = true);

    final result = await SettingsService.changeAccessPassword(currentPassword, newPassword, pin);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Éxito'),
          content: Text(result.message ?? 'Contraseña cambiada exitosamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      _showError(result.message ?? 'No se pudo cambiar la contraseña.');
    }
  }

  Widget _buildField({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[400] : AppColors.navy,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRequirement(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 12, color: isDark ? Colors.grey[400] : Colors.grey),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresar Nueva Contraseña de Acceso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.navy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu contraseña actual y define tu nueva contraseña. Requerirás tu PIN de operaciones para autorizar este cambio.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildField(
              label: 'CONTRASEÑA ACTUAL',
              hint: '••••••••',
              controller: _currentPasswordController,
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            _buildField(
              label: 'NUEVA CONTRASEÑA',
              hint: '••••••••',
              controller: _newPasswordController,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            _buildField(
              label: 'CONFIRMAR NUEVA CONTRASEÑA',
              hint: '••••••••',
              controller: _confirmPasswordController,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildField(
              label: 'PIN DE OPERACIONES (AUTORIZACIÓN)',
              hint: '••••',
              controller: _pinController,
              obscure: _obscurePin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              onToggle: () => setState(() => _obscurePin = !_obscurePin),
            ),
            const SizedBox(height: 16),
            _buildRequirement('Al menos 8 caracteres'),
            _buildRequirement('Contiene un número'),
            _buildRequirement('Contiene una letra mayúscula y minúscula'),
            _buildRequirement('Contiene un símbolo (ej. \$#&¡!)'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.purpleBlue.withOpacity(0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
