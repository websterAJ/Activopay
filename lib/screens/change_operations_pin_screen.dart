import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ChangeOperationsPinScreen extends StatefulWidget {
  const ChangeOperationsPinScreen({super.key});

  @override
  State<ChangeOperationsPinScreen> createState() => _ChangeOperationsPinScreenState();
}

class _ChangeOperationsPinScreenState extends State<ChangeOperationsPinScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _obscureSpecial = true;

  Widget _buildField({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String hint,
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
            obscureText: obscure,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
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
          'Cambiar Clave',
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
              'Ingresar Nueva Clave de Operaciones',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.navy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu clave actual, define tu nueva clave y la clave de operaciones especiales para mayor seguridad.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildField(
              label: 'CLAVE ACTUAL',
              hint: '••••••',
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            _buildField(
              label: 'NUEVA CLAVE',
              hint: '••••••',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            _buildField(
              label: 'CONFIRMAR NUEVA CLAVE',
              hint: '••••••',
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            _buildField(
              label: 'CLAVE DE OPERACIONES ESPECIALES',
              hint: '••••••',
              obscure: _obscureSpecial,
              onToggle: () => setState(() => _obscureSpecial = !_obscureSpecial),
            ),
            const SizedBox(height: 16),
            _buildRequirement('Debe tener exactamente 6 dígitos'),
            _buildRequirement('No debe tener números repetidos (ej: 111111)'),
            _buildRequirement('No debe ser una secuencia (ej: 123456)'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/password-change-success');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 128,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
