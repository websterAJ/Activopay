import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_select.dart';
import '../services/operation_service.dart';

class ValidatePaymentScreen extends StatefulWidget {
  const ValidatePaymentScreen({super.key});

  @override
  State<ValidatePaymentScreen> createState() => _ValidatePaymentScreenState();
}

class _ValidatePaymentScreenState extends State<ValidatePaymentScreen> {
  final _docNumberController = TextEditingController();
  final _numCntController = TextEditingController();
  
  String _docType = 'V';
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _searchTransaction() async {
    final docNumber = _docNumberController.text.trim();
    final numCnt = _numCntController.text.trim();

    if (docNumber.isEmpty || numCnt.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    final cedula = '$_docType$docNumber';
    // Format date as DD/MM/YYYY (or what the backend expects, usually YYYY-MM-DD or DD/MM/YYYY)
    // Looking at the React Native app using standard HTML date input, it sends YYYY-MM-DD
    final fecha = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    setState(() => _isLoading = true);

    try {
      final result = await OperationService.searchTransactionToValidate(
        numCnt: numCnt,
        cedula: cedula,
        fecha: fecha,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final List<dynamic> transactions = result['data'] ?? [];
        Navigator.pushNamed(
          context, 
          '/transaction-found',
          arguments: transactions,
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Aviso'),
            content: Text(result['message'] ?? 'No se encontraron transacciones.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.purpleBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.purpleBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ingrese los datos del pagador y la fecha de la transacción para buscarla en el sistema.',
                    style: TextStyle(color: AppColors.slate500, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  _buildDocInput(),
                  const SizedBox(height: 24),
                  
                  AppInput(
                    label: 'Número de Teléfono o Cuenta',
                    placeholder: 'Ej. 04121234567 o 0102...',
                    controller: _numCntController,
                    keyboardType: TextInputType.number,
                    showPrefixIcon: false,
                  ),
                  const SizedBox(height: 24),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de la Transacción',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.slate800 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.slate700 : AppColors.slate200,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Seleccione una fecha'
                                    : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                style: TextStyle(
                                  color: _selectedDate == null ? AppColors.slate400 : (isDark ? Colors.white : AppColors.navy),
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(Icons.calendar_today, color: AppColors.slate400, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  AppButton(
                    text: 'Buscar Transacción',
                    onPressed: _searchTransaction,
                    icon: Icons.search,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Asegúrese de que los datos coincidan exactamente con la operación realizada para evitar demoras en la validación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.slate400, fontSize: 12),
                  ),
                ],
              ),
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
            label: 'Cédula',
            value: _docType,
            items: ['V', 'E', 'J', 'G', 'P'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
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

