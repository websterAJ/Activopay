import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../services/operation_service.dart';

class ReceivePaymentQrScreen extends StatefulWidget {
  const ReceivePaymentQrScreen({super.key});

  @override
  State<ReceivePaymentQrScreen> createState() => _ReceivePaymentQrScreenState();
}

class _ReceivePaymentQrScreenState extends State<ReceivePaymentQrScreen> {
  bool _isLoading = true;
  String? _qrData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQrData();
  }

  Future<void> _fetchQrData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await OperationService.generateReceiveQr();

    if (!mounted) return;

    if (result.success && result.referenceNumber != null) {
      setState(() {
        _qrData = result.referenceNumber;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.errorMessage ?? 'Error al generar el código QR';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.navy),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Recibir Pago QR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Mi Código QR',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escanea para enviarme un pago',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 48),
              
              // QR Code container
              Stack(
                alignment: Alignment.center,
                children: [
                  // Scanner frame brackets
                  SizedBox(
                    width: 340,
                    height: 340,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0, left: 0,
                          child: _buildCorner(isTop: true, isLeft: true),
                        ),
                        Positioned(
                          top: 0, right: 0,
                          child: _buildCorner(isTop: true, isLeft: false),
                        ),
                        Positioned(
                          bottom: 0, left: 0,
                          child: _buildCorner(isTop: false, isLeft: true),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: _buildCorner(isTop: false, isLeft: false),
                        ),
                      ],
                    ),
                  ),
                  
                  // QR Code background
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColors.purpleBlue)
                          : _error != null
                              ? SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                      const SizedBox(height: 8),
                                      Text(
                                        _error!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _fetchQrData,
                                        child: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : QrImageView(
                                  data: _qrData ?? '',
                                  version: QrVersions.auto,
                                  size: 260.0,
                                  backgroundColor: Colors.transparent,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                  embeddedImage: const AssetImage('lib/assets/suiche7b.png'),
                                  embeddedImageStyle: const QrEmbeddedImageStyle(
                                    size: Size(45, 45),
                                  ),
                                  eyeStyle: QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  dataModuleStyle: QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                'Muestra este código para cobrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons (Compartir, Guardar)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Compartir',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Icons.download_outlined,
                    label: 'Guardar',
                    onTap: () {},
                  ),
                ],
              ),
              

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.purpleBlue, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.purpleBlue, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.purpleBlue, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.purpleBlue, width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(24) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(24) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(24) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(24) : Radius.zero,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.navy),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
