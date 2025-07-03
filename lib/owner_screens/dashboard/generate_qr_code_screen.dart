import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add 'qr_flutter' to your pubspec.yaml
import 'package:vehicle_verified/themes/color.dart';

class GenerateQrCodeScreen extends StatefulWidget {
  // FIX: Added optional vehicle parameter
  final Map<String, String>? vehicle;

  const GenerateQrCodeScreen({super.key, this.vehicle});

  @override
  State<GenerateQrCodeScreen> createState() => _GenerateQrCodeScreenState();
}

class _GenerateQrCodeScreenState extends State<GenerateQrCodeScreen> {
  // --- MOCK DATA ---
  // In a real app, this data would be fetched from Firebase/Firestore.
  final List<Map<String, String>> _vehicles = [
    {
      "id": "doc_id_honda_activa_123",
      "make": "Honda Activa",
      "number": "DL01AB1234",
    },
    {
      "id": "doc_id_maruti_swift_456",
      "make": "Maruti Swift",
      "number": "BR01CD5678",
    }
  ];

  Map<String, String>? _selectedVehicle;
  String? _qrCodeData;

  @override
  void initState() {
    super.initState();
    // FIX: If a vehicle is passed directly, generate its QR code immediately.
    if (widget.vehicle != null) {
      _selectedVehicle = widget.vehicle;
      _generateQr();
    }
  }

  void _generateQr() {
    if (_selectedVehicle != null) {
      setState(() {
        _qrCodeData = _selectedVehicle!['id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_qrCodeData == null ? 'Select Vehicle' : 'Vehicle QR Code', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColorOwner,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _qrCodeData == null
              ? _buildVehicleSelector()
              : _buildQrCodeDisplay(),
        ),
      ),
    );
  }

  /// Widget to show when the user needs to select a vehicle.
  Widget _buildVehicleSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.directions_car, size: 80, color: AppColors.primaryColorOwner),
        const SizedBox(height: 20),
        const Text(
          'Select a vehicle to generate its verification QR code.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, String>>(
              value: _selectedVehicle,
              isExpanded: true,
              hint: const Text('Choose your vehicle'),
              onChanged: (Map<String, String>? newValue) {
                setState(() {
                  _selectedVehicle = newValue;
                });
              },
              items: _vehicles.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> vehicle) {
                return DropdownMenuItem<Map<String, String>>(
                  value: vehicle,
                  child: Text('${vehicle["make"]} (${vehicle["number"]})'),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: _selectedVehicle == null ? null : _generateQr,
          icon: const Icon(Icons.qr_code_2, color: Colors.white),
          label: const Text('Generate QR Code', style: TextStyle(color: Colors.white, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColorOwner,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  /// Widget to show after the QR code has been generated.
  Widget _buildQrCodeDisplay() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Show this code to the traffic official for verification.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                )
              ],
            ),
            child: QrImageView(
              data: _qrCodeData!,
              version: QrVersions.auto,
              size: 250.0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedVehicle!['make']!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedVehicle!['number']!,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () {
              // If the screen was opened with a vehicle, pop back.
              // Otherwise, go back to the selection view.
              if (widget.vehicle != null) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _qrCodeData = null;
                  _selectedVehicle = null;
                });
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: Text(widget.vehicle != null ? 'Go Back' : 'Generate Another Code'),
          )
        ],
      ),
    );
  }
}
