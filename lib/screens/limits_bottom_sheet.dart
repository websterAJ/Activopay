import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';

Future<void> showLimitsBottomSheet(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  // Paso 1: Validar PIN
  final String? pin = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ValidatePinSheet(isDark: isDark),
  );

  if (pin == null || pin.isEmpty) return;

  // Si el PIN fue retornado, significa que ya se validó.
  // Proceder a cargar y mostrar los límites.
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const Center(child: CircularProgressIndicator()),
  );

  final result = await SettingsService.getLimits(pin);
  Navigator.pop(context); // Cerrar loading

  if (!result.success) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(result.message ?? 'No se pudieron cargar los límites.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    return;
  }

  // Paso 2: Mostrar límites para editar
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditLimitsSheet(
      isDark: isDark,
      pin: pin,
      initialData: result.data,
    ),
  );
}

class _ValidatePinSheet extends StatefulWidget {
  final bool isDark;

  const _ValidatePinSheet({required this.isDark});

  @override
  State<_ValidatePinSheet> createState() => _ValidatePinSheetState();
}

class _ValidatePinSheetState extends State<_ValidatePinSheet> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    final pin = _pinController.text;
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener 4 dígitos'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await SettingsService.validateOperationPin(pin);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pop(context, pin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'PIN incorrecto'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Validar PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : AppColors.navy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu PIN de operaciones de 4 dígitos para consultar los límites.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _pinController,
                obscureText: _obscure,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : AppColors.navy,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '••••',
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Continuar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditLimitsSheet extends StatefulWidget {
  final bool isDark;
  final String pin;
  final dynamic initialData;

  const _EditLimitsSheet({
    required this.isDark,
    required this.pin,
    required this.initialData,
  });

  @override
  State<_EditLimitsSheet> createState() => _EditLimitsSheetState();
}

class _EditLimitsSheetState extends State<_EditLimitsSheet> {
  final _p2pController = TextEditingController();
  final _c2pController = TextEditingController();
  final _ppController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    if (data != null) {
      _p2pController.text = (data['limite_p2p'] ?? data['limite_vuelto'] ?? '').toString();
      _c2pController.text = (data['limite_c2p'] ?? '').toString();
      _ppController.text = (data['limite_pago_proveedor'] ?? data['limitePP'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _p2pController.dispose();
    _c2pController.dispose();
    _ppController.dispose();
    super.dispose();
  }

  Future<void> _saveLimits() async {
    final p2p = double.tryParse(_p2pController.text) ?? 0.0;
    final c2p = double.tryParse(_c2pController.text) ?? 0.0;
    final pp = double.tryParse(_ppController.text) ?? 0.0;

    setState(() => _isLoading = true);
    final result = await SettingsService.updateLimits(widget.pin, p2p, c2p, pp);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Límites actualizados'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Error actualizando límites'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.grey[400] : AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: widget.isDark ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Límites de Operaciones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : AppColors.navy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildField('LÍMITE PAGO MÓVIL (VUELTO)', _p2pController),
              _buildField('LÍMITE COBRO C2P', _c2pController),
              _buildField('LÍMITE TRANSFERENCIAS', _ppController),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLimits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
