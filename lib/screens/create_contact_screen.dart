import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_select.dart';

class CreateContactScreen extends StatefulWidget {
  const CreateContactScreen({super.key});

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  final _nameController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  String _docType = 'V';
  String? _selectedBank;

  final List<String> _docTypes = ['V', 'E', 'J', 'P', 'G'];
  final List<Map<String, String>> _banks = [
    {'code': '0102', 'name': 'Banco de Venezuela'},
    {'code': '0105', 'name': 'Mercantil Banco'},
    {'code': '0108', 'name': 'Provincial'},
    {'code': '0134', 'name': 'Banesco'},
    {'code': '0172', 'name': 'Bancamiga'},
    {'code': '0163', 'name': 'Banco del Tesoro'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Nuevo Contacto',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInput(
              label: 'Nombre del Beneficiario',
              placeholder: 'Ej. Juan Pérez',
              controller: _nameController,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: AppSelect<String>(
                    label: 'Cédula',
                    value: _docType,
                    items: _docTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() => _docType = val!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 7,
                  child: AppInput(
                    label: '',
                    placeholder: 'Número de documento',
                    controller: _docNumberController,
                    keyboardType: TextInputType.number,
                    showPrefixIcon: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppSelect<String>(
              label: 'Banco',
              placeholder: 'Seleccione un banco',
              value: _selectedBank,
              items: _banks.map((bank) => DropdownMenuItem(value: bank['code'], child: Text(bank['name']!))).toList(),
              onChanged: (val) => setState(() => _selectedBank = val),
            ),
            const SizedBox(height: 24),
            AppInput(
              label: 'Número de Teléfono (Pago Móvil)',
              placeholder: '0412 000 0000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.smartphone,
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('O', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate400, letterSpacing: 1.2)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            AppInput(
              label: 'Número de Cuenta',
              placeholder: '0000 0000 00 0000000000',
              controller: _accountController,
              maxLength: 20,
              prefixIcon: Icons.credit_card,
            ),
            const SizedBox(height: 48),
            AppButton(
              text: 'Guardar Contacto',
              onPressed: () => Navigator.pop(context),
              icon: Icons.person_add,
            ),
            const SizedBox(height: 16),
            const Text(
              'Este contacto se guardará en tu directorio de pagos para futuras transacciones rápidas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
