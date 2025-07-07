import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/police_screens/scanned_result_screen.dart';

class PoliceScannerScreen extends StatefulWidget {
  const PoliceScannerScreen({super.key});

  @override
  State<PoliceScannerScreen> createState() => _PoliceScannerScreenState();
}

class _PoliceScannerScreenState extends State<PoliceScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isProcessing = false; // To prevent multiple detections

  /// Handles the detected barcode, verifies it with Firestore, and navigates.
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return; // If already processing a code, do nothing.

    setState(() {
      _isProcessing = true;
    });

    final String? vehicleId = capture.barcodes.first.rawValue;

    if (vehicleId != null && vehicleId.isNotEmpty) {
      try {
        // Stop the camera while we verify the ID
        _scannerController.stop();

        // Check if the vehicle exists in Firestore
        final vehicleDoc = await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleId)
            .get();

        if (vehicleDoc.exists) {
          // If vehicle exists, navigate to the result screen
          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScannedResultScreen(vehicleId: vehicleId),
              ),
            );
          }
        } else {
          // If vehicle does not exist, show an error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid QR Code: Vehicle not found.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      } finally {
        // Restart the camera after a short delay, whether successful or not
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _scannerController.start();
              setState(() {
                _isProcessing = false;
              });
            }
          });
        }
      }
    } else {
      // If the QR code is empty, just restart processing
      setState(() {
        _isProcessing = false;
      });
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
          // Show a processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Verifying QR Code...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
