import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_colors.dart';
import '../services/operation_service.dart';
import 'amount_pin_screen.dart';

class MakePaymentQrScreen extends StatefulWidget {
  const MakePaymentQrScreen({super.key});

  @override
  State<MakePaymentQrScreen> createState() => _MakePaymentQrScreenState();
}

class _MakePaymentQrScreenState extends State<MakePaymentQrScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });
    
    _scannerController.stop();

    try {
      final decryptedData = await OperationService.decryptQr(rawValue);

      if (!mounted) return;

      final rawAmountStr = decryptedData['amount']?.toString() ?? '0';
      final double amount = double.tryParse(rawAmountStr) ?? 0.0;
      
      final params = {
        'document': decryptedData['id'] ?? '',
        'phone': decryptedData['phone'] ?? '',
        'bank': decryptedData['bank'] ?? '',
        'name': decryptedData['name'] ?? '',
      };

      // Go to AmountPinScreen always, passing the amount to be prefilled
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AmountPinScreen(
            operationId: '1',
            operationName: 'Pago Móvil (QR)',
            params: params,
            initialAmount: amount > 0 ? amount : null,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al leer QR: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isProcessing = false;
      });
      _scannerController.start();
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
          'Pago QR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: _processBarcode,
                    ),
                  ),
                  
                  CustomPaint(
                    size: Size.infinite,
                    painter: _ScannerOverlayPainter(),
                  ),

                  Column(
                    children: [
                      const SizedBox(height: 64),
                      const Text(
                        'Escanea el código QR',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ubica el código QR dentro del recuadro',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      Center(
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: Stack(
                            children: [
                              Positioned(top: 0, left: 0, child: _buildCorner(isTop: true, isLeft: true)),
                              Positioned(top: 0, right: 0, child: _buildCorner(isTop: true, isLeft: false)),
                              Positioned(bottom: 0, left: 0, child: _buildCorner(isTop: false, isLeft: true)),
                              Positioned(bottom: 0, right: 0, child: _buildCorner(isTop: false, isLeft: false)),
                              
                              if (!_isProcessing)
                                AnimatedBuilder(
                                  animation: _animation,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 20 + (_animation.value * 240),
                                      left: 20,
                                      right: 20,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: AppColors.purpleBlue,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.purpleBlue.withOpacity(0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Camera Controls (Gallery & Flashlight)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CameraControlButton(
                              icon: Icons.image_outlined,
                              label: 'Galería',
                              onTap: () {},
                            ),
                            const SizedBox(width: 48),
                            _CameraControlButton(
                              icon: Icons.flashlight_on_outlined,
                              label: 'Linterna',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
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
          topLeft: isTop && isLeft ? const Radius.circular(16) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(16) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(16) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(16) : Radius.zero,
        ),
      ),
    );
  }
}

class _CameraControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CameraControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.navy, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 280,
      height: 280,
    );
    final cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)));

    final path = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
