import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vehicle_verified/police_screens/scanned_result_screen.dart';

class PoliceScannerScreen extends StatefulWidget {
  const PoliceScannerScreen({super.key});

  @override
  State<PoliceScannerScreen> createState() => _PoliceScannerScreenState();
}

class _PoliceScannerScreenState extends State<PoliceScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isFlashOn = false;

  void _onDetect(BarcodeCapture capture) {
    final String? vehicleId = capture.barcodes.first.rawValue;
    if (vehicleId != null) {
      _scannerController.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScannedResultScreen(vehicleId: vehicleId),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Scanner Overlay UI
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Flashlight toggle button
          Positioned(
            bottom: 50,
            child: IconButton(
              onPressed: () {
                _scannerController.toggleTorch();
                setState(() => _isFlashOn = !_isFlashOn);
              },
              icon: Icon(
                _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                color: Colors.white,
                size: 32,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
