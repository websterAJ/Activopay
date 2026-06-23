import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../data/banks.dart';
import '../services/operation_service.dart';
import 'operation_success_screen.dart';

class AmountPinScreen extends StatefulWidget {
  final String operationId;
  final String operationName;
  final Map<String, dynamic>? params;
  final double? initialAmount;

  const AmountPinScreen({
    super.key,
    required this.operationId,
    required this.operationName,
    this.params,
    this.initialAmount,
  });

  @override
  State<AmountPinScreen> createState() => _AmountPinScreenState();
}

class _AmountPinScreenState extends State<AmountPinScreen> {
  String _amount = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      // Convert double back to string format without decimal points (e.g. 50.0 -> "5000")
      _amount = (widget.initialAmount! * 100).toInt().toString();
    }
  }

  String get _displayAmount {
    if (_amount.isEmpty) return '0,00';
    final intPart = _amount.length > 2 ? _amount.substring(0, _amount.length - 2) : '0';
    final decPart = _amount.padLeft(3, '0');
    final dec = decPart.substring(decPart.length - 2);
    return '${intPart.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')},$dec';
  }

  void _onKey(String key) {
    if (key == 'del') {
      if (_amount.isNotEmpty) {
        setState(() => _amount = _amount.substring(0, _amount.length - 1));
      }
      return;
    }
    if (_amount.length >= 10) return;
    setState(() => _amount += key);
  }

  void _onConfirm() {
    if (_amount.isEmpty) return;
    final amountValue = _amount.isEmpty ? 0.0 : int.parse(_amount) / 100.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperationFormScreen(
          operationId: widget.operationId,
          operationName: widget.operationName,
          amount: amountValue,
          params: widget.params,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: Text(widget.operationName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text('Monto', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColors.slate500, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Bs. $_displayAmount',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.navy),
            ),
            const Spacer(flex: 2),
            _buildNumpad(isDark),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _amount.isEmpty ? null : _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.slate300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad(bool isDark) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Row(
          children: row.map((key) {
            if (key == '') return const Expanded(child: SizedBox.shrink());
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Material(
                  color: key == 'del' ? Colors.transparent : (isDark ? AppColors.slate800 : AppColors.slate100),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _onKey(key),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: key == 'del'
                          ? Icon(Icons.backspace_outlined, color: isDark ? Colors.white70 : AppColors.slate500, size: 24)
                          : Text(key, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.navy)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )).toList(),
    );
  }
}

// ---------- OperationFormScreen ----------

class OperationFormScreen extends StatefulWidget {
  final String operationId;
  final String operationName;
  final double amount;
  final Map<String, dynamic>? params;

  const OperationFormScreen({
    super.key,
    required this.operationId,
    required this.operationName,
    required this.amount,
    this.params,
  });

  @override
  State<OperationFormScreen> createState() => _OperationFormScreenState();
}

class _OperationFormScreenState extends State<OperationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Map<String, TextEditingController> _controllers = {};
  String _cedulaPrefix = 'V';

  @override
  void initState() {
    super.initState();
    if (widget.params != null && widget.params!['tpdocument'] != null) {
      final tp = widget.params!['tpdocument']?.toString().toUpperCase() ?? 'V';
      _cedulaPrefix = ['V', 'E', 'P', 'J', 'G', 'C'].contains(tp) ? tp : 'V';
    }
    _initControllers();
  }

  void _initControllers() {
    final params = widget.params;
    for (final field in _getFields()) {
      String initialValue = '';
      if (params != null) {
        if (field.name == 'nombre_beneficiario' ||
            field.name == 'providerName' ||
            field.name == 'nombre_pagador') {
          initialValue = params['name'] ?? '';
        } else if (field.name == 'cedula_beneficiario' ||
            field.name == 'cedula_pagador') {
          initialValue = params['document'] ?? '';
        } else if (field.name == 'accountNumber' ||
            field.name == 'numero_cuenta_pagador' ||
            field.name == 'numero_cuenta') {
          initialValue = params['account'] ?? params['phone'] ?? '';
        } else if (field.name == 'cod_banco' ||
            field.name == 'bank' ||
            field.name == 'cod_banco_pagador') {
          initialValue = params['bank'] ?? '';
        } else if (field.name == 'telefono') {
          initialValue = params['phone'] ?? '';
        }
      }
      _controllers[field.name] = TextEditingController(text: initialValue);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<_FormFieldDef> _getFields() {
    return _fieldDefinitions[widget.operationId] ?? [];
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar operación'),
        content: const Text('¿Está seguro de que desea continuar con esta operación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processOperation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleBlue),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _requestOtp() async {
    if (widget.operationId == '6') {
      final nombre = _controllers['nombre_pagador']?.text.trim() ?? '';
      final cedula = _controllers['cedula_pagador']?.text.trim() ?? '';
      final cuenta = _controllers['numero_cuenta_pagador']?.text.trim() ?? '';
      final descripcion = _controllers['descripcion']?.text.trim() ?? '';
      
      if (nombre.isEmpty || cedula.isEmpty || cuenta.isEmpty || descripcion.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor completa todos los campos (Nombre, Cédula, Cuenta y Descripción) antes de solicitar el OTP.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    
    final data = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      if (entry.key == 'cedula_beneficiario' || entry.key == 'cedula_pagador' || entry.key == 'cedula_titular' || entry.key == 'cedula_pago') {
         data[entry.key] = '$_cedulaPrefix${entry.value.text}';
      } else {
         data[entry.key] = entry.value.text;
      }
    }

    OperationResult? result;
    if (widget.operationId == '2') {
      final cedulaPago = data['cedula_pago'] ?? '';
      final telefonoPago = data['telefono_pago'] ?? '';
      result = await OperationService.requestC2pOtp(cedulaPago, telefonoPago);
    } else if (widget.operationId == '6') {
      final telefonoPago = data['numero_cuenta_pagador'] ?? '';
      result = await OperationService.requestDinmediatoOtp(data, telefonoPago, widget.amount);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null && result.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP enviado con éxito'), backgroundColor: Colors.green));
      // Auto-completar el OTP (Comportamiento legado para pruebas)
      if (result.referenceNumber != null && result.referenceNumber!.isNotEmpty) {
        if (_controllers.containsKey('otp')) {
          _controllers['otp']!.text = result.referenceNumber!;
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(result?.errorMessage ?? 'No se pudo solicitar el OTP'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Aceptar')),
          ],
        ),
      );
    }
  }

  Future<void> _processOperation() async {
    setState(() => _isLoading = true);
    
    final data = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      if (entry.key == 'cedula_beneficiario' || entry.key == 'cedula_pagador' || entry.key == 'cedula_titular' || entry.key == 'cedula_pago') {
         data[entry.key] = '$_cedulaPrefix${entry.value.text}';
      } else {
         data[entry.key] = entry.value.text;
      }
    }
    
    OperationResult? result;
    if (widget.operationId == '1') {
      result = await OperationService.processPagoMovil(data, widget.amount);
    } else if (widget.operationId == '2') {
      result = await OperationService.processC2p(data, widget.amount);
    } else if (widget.operationId == '3') {
      result = await OperationService.processTransferencia(data, widget.amount);
    } else if (widget.operationId == '6') {
      result = await OperationService.processDinmediato(data, widget.amount);
    } else {
      // Dummy result para otras operaciones por ahora
      await Future.delayed(const Duration(seconds: 2));
      result = OperationResult(success: true, referenceNumber: '1234567890');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null && result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OperationSuccessScreen(
            type: SuccessScreenType.payment,
            title: 'Pago Exitoso',
            subtitle: 'Tu transferencia ha sido procesada',
            amount: widget.amount,
            reference: result!.referenceNumber,
            date: result.date ?? DateTime.now(),
            recipientName: result.recipientName ?? data['nombre_beneficiario'] ?? 'Destinatario',
            bankName: result.bank ?? data['bank'] ?? data['banco_destino'],
            concept: result.concept ?? 'Pago de servicios',
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(result?.errorMessage ?? 'Error desconocido'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fields = _getFields();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: Text(widget.operationName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.purpleBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: AppColors.purpleBlue, size: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monto', style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text('Bs. ${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.purpleBlue)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.purpleBlue),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildField(f, isDark),
              )),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Realizar Operación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(_FormFieldDef field, bool isDark) {
    switch (field.type) {
      case _FieldType.text:
        return TextFormField(
          controller: _controllers[field.name],
          decoration: _inputDecoration(field.label, isDark),
          validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        );
      case _FieldType.number:
        return TextFormField(
          controller: _controllers[field.name],
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(field.label, isDark),
          validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        );
      case _FieldType.cedula:
        return _buildCedulaInput(field, isDark);
      case _FieldType.bank:
        return _buildBankSelector(field, isDark);
      case _FieldType.phone:
        return TextFormField(
          controller: _controllers[field.name],
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(field.label, isDark),
          validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        );
      case _FieldType.otp:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _controllers[field.name],
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(field.label, isDark),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52, // match typical input height
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slate200,
                    foregroundColor: AppColors.navy,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Solicitar\nOTP', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildCedulaInput(_FormFieldDef field, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: DropdownButtonFormField<String>(
            value: _cedulaPrefix,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.navy),
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'V', child: Text('V')),
              DropdownMenuItem(value: 'E', child: Text('E')),
              DropdownMenuItem(value: 'P', child: Text('P')),
              DropdownMenuItem(value: 'J', child: Text('J')),
              DropdownMenuItem(value: 'G', child: Text('G')),
              DropdownMenuItem(value: 'C', child: Text('C')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _cedulaPrefix = v);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _controllers[field.name],
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(field.label, isDark),
            validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBankSelector(_FormFieldDef field, bool isDark) {
    final currentValue = _controllers[field.name]?.text;
    final hasMatch = currentValue != null && banks.any((b) => b.code == currentValue);
    return DropdownButtonFormField<String>(
      value: hasMatch ? currentValue : null,
      decoration: _inputDecoration(field.label, isDark),
      isExpanded: true,
      items: banks.where((b) => b.code != '0000').map((b) => DropdownMenuItem(value: b.code, child: Text(b.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (v) {
        setState(() {
          _controllers[field.name]?.text = v ?? '';
        });
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Selecciona un banco' : null,
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.purpleBlue, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

enum _FieldType { text, number, cedula, bank, phone, otp }

class _FormFieldDef {
  final String name;
  final String label;
  final _FieldType type;
  const _FormFieldDef({required this.name, required this.label, this.type = _FieldType.text});
}



const _fieldDefinitions = <String, List<_FormFieldDef>>{
  '1': [
    _FormFieldDef(name: 'nombre_beneficiario', label: 'Nombre del Beneficiario'),
    _FormFieldDef(name: 'cedula_beneficiario', label: 'Cédula', type: _FieldType.cedula),
    _FormFieldDef(name: 'telefono', label: 'Teléfono', type: _FieldType.phone),
    _FormFieldDef(name: 'cod_banco', label: 'Banco', type: _FieldType.bank),
    _FormFieldDef(name: 'descripcion', label: 'Descripción'),
  ],
  '2': [
    _FormFieldDef(name: 'cedula_pago', label: 'Cédula del Pagador', type: _FieldType.cedula),
    _FormFieldDef(name: 'telefono_pago', label: 'Teléfono del Pagador', type: _FieldType.phone),
    _FormFieldDef(name: 'bco_pago', label: 'Banco del Pagador', type: _FieldType.bank),
    _FormFieldDef(name: 'motivo', label: 'Motivo / Descripción'),
    _FormFieldDef(name: 'otp', label: 'Código OTP', type: _FieldType.otp),
  ],
  '3': [
    _FormFieldDef(name: 'bank', label: 'Banco de Destino', type: _FieldType.bank),
    _FormFieldDef(name: 'accountNumber', label: 'Número de Cuenta', type: _FieldType.number),
    _FormFieldDef(name: 'providerName', label: 'Titular de la Cuenta'),
    _FormFieldDef(name: 'cedula_beneficiario', label: 'Cédula del Titular', type: _FieldType.cedula),
    _FormFieldDef(name: 'descripcion', label: 'Descripción'),
  ],
  '6': [
    _FormFieldDef(name: 'nombre_pagador', label: 'Nombre del Pagador'),
    _FormFieldDef(name: 'cedula_pagador', label: 'Cédula del Pagador', type: _FieldType.cedula),
    _FormFieldDef(name: 'cod_banco_pagador', label: 'Banco del Pagador', type: _FieldType.bank),
    _FormFieldDef(name: 'numero_cuenta_pagador', label: 'Número de Cuenta / Teléfono del Pagador', type: _FieldType.number),
    _FormFieldDef(name: 'descripcion', label: 'Descripción'),
    _FormFieldDef(name: 'otp', label: 'Código OTP', type: _FieldType.otp),
  ],
};
