import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/police_screens/scanned_result_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  /// Searches for a vehicle in Firestore using its registration number.
  Future<void> _searchVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleNumber = _vehicleNumberController.text.trim().toUpperCase();

      // Query Firestore for a vehicle with the matching registration number.
      final querySnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('registrationNumber', isEqualTo: vehicleNumber)
          .limit(1) // We only expect one vehicle per registration number.
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a vehicle is found, get its document ID.
        final vehicleId = querySnapshot.docs.first.id;
        if (mounted) {
          // Navigate to the result screen with the real vehicle ID.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScannedResultScreen(vehicleId: vehicleId),
            ),
          );
        }
      } else {
        // If no vehicle is found, show a message.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No vehicle found with this registration number.'),
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Vehicle Entry',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the vehicle registration number below to fetch its details.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _vehicleNumberController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number (e.g., BR01Z1234)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a vehicle number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text('Search Vehicle',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _searchVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
