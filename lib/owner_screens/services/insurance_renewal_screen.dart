import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class InsuranceRenewalScreen extends StatefulWidget {
  const InsuranceRenewalScreen({super.key});

  @override
  State<InsuranceRenewalScreen> createState() => _InsuranceRenewalScreenState();
}

class _InsuranceRenewalScreenState extends State<InsuranceRenewalScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<Map<String, dynamic>>> _vehiclesFuture;
  String? _selectedVehicleId;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  File? _pickedFile;
  String? _uploadedFileUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _fetchUserVehicles();
  }

  Future<List<Map<String, dynamic>>> _fetchUserVehicles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('vehicles')
        .where('ownerID', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final displayString =
          '${data['make'] ?? ''} ${data['model'] ?? ''} - ${data['registrationNumber'] ?? 'N/A'}';
      return {'id': doc.id, 'display': displayString};
    }).toList();
  }

  Future<void> _pickAndUploadFile() async {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle first.')),
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
          _isUploading = true;
          _uploadedFileUrl = null;
        });

        final fileName = path.basename(_pickedFile!.path);
        final destination =
            'users/${_auth.currentUser!.uid}/insurance_policies/$_selectedVehicleId/$fileName';

        final ref = FirebaseStorage.instance.ref(destination);
        final uploadTask = ref.putFile(_pickedFile!);

        final snapshot = await uploadTask.whenComplete(() {});
        final url = await snapshot.ref.getDownloadURL();

        setState(() {
          _uploadedFileUrl = url;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('File uploaded successfully!'),
                backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  Future<void> _requestQuotes() async {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a vehicle.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore
          .collection('vehicles')
          .doc(_selectedVehicleId)
          .collection('serviceHistory')
          .add({
        'serviceType': 'Insurance Renewal',
        'serviceDate': Timestamp.now(),
        'notes': _notesController.text.trim(),
        'status': 'Quote Pending',
        'cost': 0.0,
        'createdAt': Timestamp.now(),
        'previousPolicyUrl': _uploadedFileUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Renewal request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundColorOwner,
          appBar: AppBar(
            title: const Text('Insurance Renewal',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _vehiclesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('No vehicles found.'));
              }
              final vehicles = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(
                      title: 'Renew Your Insurance',
                      subtitle:
                      'Get the best quotes and renew policy instantly.',
                      icon: Icons.shield,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Select Vehicle',
                      content: _buildVehicleSelectionCard(
                        vehicles: vehicles,
                        onVehicleChanged: (value) {
                          setState(() {
                            _selectedVehicleId = value;
                            _pickedFile = null;
                            _uploadedFileUrl = null;
                            _isUploading = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Upload Previous Policy (Optional)',
                      content: _buildFilePicker(),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: 'Additional Notes',
                        content: _buildNotesField(
                            'Any specific requirements? e.g. "Need zero depreciation cover"')),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: _buildBottomButton(
            label: 'Request Quotes',
            onPressed: _isLoading || _isUploading ? null : _requestQuotes,
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  SizedBox(height: 20),
                  Text(
                    'Submitting Request...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildVehicleSelectionCard({
    required List<Map<String, dynamic>> vehicles,
    required ValueChanged<String?> onVehicleChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<String>(
          value: _selectedVehicleId,
          hint: const Text('Select your vehicle'),
          isExpanded: true,
          decoration: const InputDecoration(
              labelText: 'Select Vehicle',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.directions_car)),
          items: vehicles.map((v) {
            return DropdownMenuItem<String>(
              value: v['id'] as String,
              child: Text(v['display'] as String,overflow: TextOverflow.ellipsis,),
            );
          }).toList(),
          onChanged: onVehicleChanged,
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.attach_file),
        title: Text(
          _pickedFile == null
              ? 'Select policy PDF/Image'
              : path.basename(_pickedFile!.path),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _isUploading
            ? const Text('Uploading...', style: TextStyle(color: Colors.blue))
            : null,
        trailing: _isUploading
            ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2))
            : (_pickedFile != null
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _pickedFile = null;
              _uploadedFileUrl = null;
              _isUploading = false;
            });
          },
        )
            : const Icon(Icons.arrow_forward_ios)),
        onTap: _isUploading ? null : _pickAndUploadFile,
      ),
    );
  }

  Widget _buildNotesField(String hint) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(8)),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
      {required String title,
        required String subtitle,
        required IconData icon,
        required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.send, color: Colors.white),
        label: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColorOwner,
          minimumSize: const Size(double.infinity, 50),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
