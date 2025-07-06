import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/themes/color.dart';

class GenerateQrCodeScreen extends StatefulWidget {
  // Yeh optional vehicle parameter waise hi rahega
  final Map<String, dynamic>? vehicle;

  const GenerateQrCodeScreen({super.key, this.vehicle});

  @override
  State<GenerateQrCodeScreen> createState() => _GenerateQrCodeScreenState();
}

class _GenerateQrCodeScreenState extends State<GenerateQrCodeScreen> {
  Map<String, dynamic>? _selectedVehicle;
  String? _qrCodeData;
  late Future<List<Map<String, dynamic>>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    // Agar vehicle pehle se pass kiya gaya hai, to QR generate karein
    if (widget.vehicle != null) {
      _selectedVehicle = widget.vehicle;
      _generateQr();
    } else {
      // Warna, Firebase se vehicles fetch karein
      _vehiclesFuture = _fetchUserVehicles();
    }
  }

  /// User ke vehicles ko Firestore se fetch karne ka function
  Future<List<Map<String, dynamic>>> _fetchUserVehicles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Agar user logged in nahi hai, to khaali list return karein
      return [];
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerID', isEqualTo: user.uid)
          .get();

      // Documents ko Map ki list mein convert karein
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Document ID ko bhi save karein
        return data;
      }).toList();
    } catch (e) {
      // Error handle karein
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vehicles: $e')),
      );
      return [];
    }
  }

  void _generateQr() {
    if (_selectedVehicle != null) {
      setState(() {
        // QR code ke liye vehicle ki document ID ka istemaal karein
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
          // Agar QR code generate ho gaya hai, to use dikhayein
          child: _qrCodeData != null
              ? _buildQrCodeDisplay()
          // Agar vehicle pass nahi kiya gaya, to FutureBuilder se list dikhayein
              : (widget.vehicle == null ? _buildVehicleSelector() : const CircularProgressIndicator()),
        ),
      ),
    );
  }

  /// Vehicle select karne wala UI
  Widget _buildVehicleSelector() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _vehiclesFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Error state
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Data na hone par
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No vehicles found. Please add a vehicle first.'));
        }

        final vehicles = snapshot.data!;

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
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedVehicle,
                  isExpanded: true,
                  hint: const Text('Choose your vehicle'),
                  onChanged: (Map<String, dynamic>? newValue) {
                    setState(() {
                      _selectedVehicle = newValue;
                    });
                  },
                  items: vehicles.map<DropdownMenuItem<Map<String, dynamic>>>((vehicle) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: vehicle,
                      child: Text('${vehicle["make"]} ${vehicle["model"]} (${vehicle["registrationNumber"]})'),
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
      },
    );
  }

  /// QR code dikhane wala UI
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
            '${_selectedVehicle!['make']} ${_selectedVehicle!['model']}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedVehicle!['registrationNumber']!,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () {
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
