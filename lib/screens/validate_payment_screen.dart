import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_select.dart';

class ValidatePaymentScreen extends StatefulWidget {
  const ValidatePaymentScreen({super.key});

  @override
  State<ValidatePaymentScreen> createState() => _ValidatePaymentScreenState();
}

class _ValidatePaymentScreenState extends State<ValidatePaymentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _docNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  String _docType = 'V';
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Validar Pago',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Custom Tab Bar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate200.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.purpleBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.navy,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Pago Móvil'),
                  Tab(text: 'Transferencia'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPagoMovilTab(),
                  _buildTransferenciaTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagoMovilTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDocInput(),
          const SizedBox(height: 24),
          AppInput(
            label: 'Número de Teléfono',
            placeholder: '412 1234567',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            showPrefixIcon: false,
          ),
          const SizedBox(height: 32),
          AppButton(
            text: 'Validar Pago',
            onPressed: () => Navigator.pushNamed(context, '/transaction-found'),
            icon: Icons.verified,
          ),
          const SizedBox(height: 24),
          const Text(
            'Asegúrese de que los datos coincidan exactamente con la operación realizada para evitar demoras en la validación.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferenciaTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDocInput(),
          const SizedBox(height: 24),
          AppSelect<String>(
            label: 'Banco',
            placeholder: 'Seleccione el banco emisor',
            value: _selectedBank,
            items: const [
              DropdownMenuItem(value: 'BDV', child: Text('Banco de Venezuela')),
              DropdownMenuItem(value: 'BANESCO', child: Text('Banesco')),
              DropdownMenuItem(value: 'MERCANTIL', child: Text('Mercantil')),
            ],
            onChanged: (val) => setState(() => _selectedBank = val),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: 'Validar Pago',
            onPressed: () => Navigator.pushNamed(context, '/transaction-found'),
            icon: Icons.verified,
          ),
          const SizedBox(height: 32),
          const Text(
            'Asegúrese de que los datos de la transferencia coincidan exactamente con la operación realizada para evitar demoras en la validación.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDocInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: AppSelect<String>(
            label: 'Cédula de Identidad',
            value: _docType,
            items: ['V', 'E', 'J'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (val) => setState(() => _docType = val!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 7,
          child: AppInput(
            label: '',
            placeholder: 'Ej. 28450123',
            controller: _docNumberController,
            keyboardType: TextInputType.number,
            showPrefixIcon: false,
          ),
        ),
      ],
    );
  }
}
