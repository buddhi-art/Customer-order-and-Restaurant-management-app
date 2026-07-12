import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/cafe_colors.dart';
import '../../providers/table_provider.dart';
import '../../providers/cart_provider.dart';
import '../../router.dart';
import '../../utils/qr_service.dart';

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
                if (code == null) return;

                // Verify the token SERVER-SIDE (the HMAC secret is not on the
                // client). redeem_table_qr returns the trusted table id, or
                // null for an invalid/forged/expired token.
                setState(() => _isScanned = true);
                String? tableId;
                try {
                  tableId = await QrService.redeemToken(code);
                } catch (e) {
                  tableId = null;
                }

                if (tableId == null) {
                  // Not a valid Kalpa table token — allow rescanning.
                  if (mounted) setState(() => _isScanned = false);
                  return;
                }

                HapticFeedback.heavyImpact();

                // Clear stale cart when scanning a new table
                ref.read(cartProvider.notifier).clearCart();

                // Save to global provider
                ref.read(tableProvider.notifier).setTable(tableId);

                try {
                  // Persist table id so the router guard passes.
                  // SharedPreferences is web-safe (unlike secure storage).
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(kTableIdKey, tableId);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Welcome to $tableId!')),
                  );
                  context.go('/home');
                } catch (e) {
                  // Reset the guard so the user can rescan, and surface the
                  // failure instead of silently locking up the scanner.
                  if (mounted) setState(() => _isScanned = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not start your session. Please try again.',
                        ),
                      ),
                    );
                  }
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
              color: CafeColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            gradient: RadialGradient(
              colors: [
                CafeColors.primary.withValues(alpha: 0.0),
                CafeColors.primary.withValues(
                  alpha: 0.2 * (1.0 - _controller.value),
                ),
                CafeColors.primary.withValues(alpha: 0.0),
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
                    color: CafeColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: CafeColors.primary.withValues(alpha: 0.8),
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
