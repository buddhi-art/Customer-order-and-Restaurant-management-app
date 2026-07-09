import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../theme/app_colors.dart';
import '../../providers/table_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/security_layer.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !_isScanned) {
                final String? code = barcodes.first.rawValue;
                if (code != null && SecurityLayer.verifyQrToken(code)) {
                  HapticFeedback.heavyImpact();
                  setState(() => _isScanned = true);
                  final tableId = SecurityLayer.extractTableId(code)!;

                  // Clear stale cart when scanning a new table
                  ref.read(cartProvider.notifier).clearCart();

                  // Save to global provider
                  ref.read(tableProvider.notifier).setTable(tableId);

                  // Write to secure storage so router guard passes
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'table_id', value: tableId);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Welcome to $tableId!')),
                  );
                  context.go('/home');
                }
              }
            },
          ),

          // UI Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Scan to Order',
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                const _PulsingRadar(),
                const Spacer(),
                // Flashlight toggle
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: GestureDetector(
                    onTap: () => cameraController.toggleTorch(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.flashlight_on,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

/// A futuristic pulsing radar effect overlay for the QR scanner
class _PulsingRadar extends StatefulWidget {
  const _PulsingRadar();

  @override
  State<_PulsingRadar> createState() => _PulsingRadarState();
}

class _PulsingRadarState extends State<_PulsingRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryAction.withValues(alpha: 0.5),
              width: 2,
            ),
            gradient: RadialGradient(
              colors: [
                AppColors.primaryAction.withValues(alpha: 0.0),
                AppColors.primaryAction.withValues(
                  alpha: 0.2 * (1.0 - _controller.value),
                ),
                AppColors.primaryAction.withValues(alpha: 0.0),
              ],
              stops: [0.0, _controller.value, _controller.value + 0.1],
            ),
          ),
          child: Stack(
            children: [
              // Scanning line
              Positioned(
                top: 250 * _controller.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAction,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAction.withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
