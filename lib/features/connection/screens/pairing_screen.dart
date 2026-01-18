import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../services/connection_service.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isConnecting = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isConnecting) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isConnecting = true);
        final address = barcode.rawValue!;
        
        final success = await ConnectionService().connectToDevice(address);
        
        if (success && mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        } else {
          if (mounted) {
            setState(() => _isConnecting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to connect to workstation')),
            );
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Text(
                  _isConnecting ? 'Establishing Link' : 'Pair Device',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Text(
                  _isConnecting 
                    ? 'Syncing with workstation...'
                    : 'Scan the QR code displayed on your PC application to link your device.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
              const Spacer(),
              _buildScannerUI(context),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isConnecting) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      _isConnecting ? 'Handshaking...' : 'Ready to scan',
                      style: TextStyle(
                        color: _isConnecting 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                          : Colors.white24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_isConnecting)
            // Hidden scanner layer that fills the box
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerUI(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(
          color: _isConnecting 
            ? Colors.greenAccent.withOpacity(0.5)
            : Theme.of(context).colorScheme.primary.withOpacity(0.3), 
          width: 2
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!_isConnecting)
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),
            ..._buildCornerMarkers(context, _isConnecting ? Colors.greenAccent : Theme.of(context).colorScheme.primary),
            if (_isConnecting)
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 140,
                color: Colors.greenAccent,
              ),
            if (!_isConnecting)
              const ScanningLineAnimation(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers(BuildContext context, Color color) {
    return [
      Positioned(top: 24, left: 24, child: _corner(color, top: true, left: true)),
      Positioned(top: 24, right: 24, child: _corner(color, top: true, left: false)),
      Positioned(bottom: 24, left: 24, child: _corner(color, top: false, left: true)),
      Positioned(bottom: 24, right: 24, child: _corner(color, top: false, left: false)),
    ];
  }

  Widget _corner(Color color, {required bool top, required bool left}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: 4) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: 4) : BorderSide.none,
          left: left ? BorderSide(color: color, width: 4) : BorderSide.none,
          right: !left ? BorderSide(color: color, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}

class ScanningLineAnimation extends StatefulWidget {
  const ScanningLineAnimation({super.key});

  @override
  State<ScanningLineAnimation> createState() => _ScanningLineAnimationState();
}

class _ScanningLineAnimationState extends State<ScanningLineAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
        return Positioned(
          top: 40 + (180 * _controller.value),
          child: Container(
            width: 200,
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}
