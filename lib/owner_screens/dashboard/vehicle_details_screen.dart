import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vehicle_verified/owner_screens/dashboard/add_edit_document_screen.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {

  Future<void> _deleteVehicle() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to permanently delete this vehicle and all its data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Delete
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final vehicleRef = FirebaseFirestore.instance.collection('vehicles').doc(widget.vehicle['id']);

        final documentsSnapshot = await vehicleRef.collection('documents').get();
        for (var doc in documentsSnapshot.docs) {
          await doc.reference.delete();
        }

        await vehicleRef.delete();

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted successfully'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete vehicle: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  final List<Map<String, dynamic>> _documents = [
    {
      "type": "Registration Certificate (RC)",
      "status": "valid",
      "expiry": "Lifetime",
    },
    {
      "type": "Insurance Policy",
      "status": "expiring",
      "expiry": "2024-07-28",
    },
    {
      "type": "Pollution Under Control (PUC)",
      "status": "expired",
      "expiry": "2024-05-10",
    },
    {
      "type": "Owner's Manual",
      "status": "missing",
      "expiry": "N/A",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVehicleInfoCard(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Vehicle Documents'),
                      const SizedBox(height: 12),
                      ..._documents.map((doc) => _buildDocumentCard(doc)).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.delete_forever, color: Colors.white),
          label: const Text('Delete Vehicle', style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: _deleteVehicle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: AppColors.primaryColorOwner,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          '${widget.vehicle['make']} ${widget.vehicle['model']}',
          style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Image.asset(
          widget.vehicle['image'] ?? 'assets/image/car_sedan.png',
          // fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.1),
          colorBlendMode: BlendMode.darken,
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildInfoRow('Registration No.', widget.vehicle['number'] ?? 'N/A'),
            _buildInfoRow('Make', widget.vehicle['make'] ?? 'N/A'),
            _buildInfoRow('Model', widget.vehicle['model'] ?? 'N/A'),
            // Add more details from your data model here
            _buildInfoRow('Engine No.', 'ENG12345XYZ'),
            _buildInfoRow('Chassis No.', 'CHS67890ABC'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  // vehicle_details_screen.dart mein is function ko replace karein

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final status = doc['status'];
    final Color statusColor;
    final IconData statusIcon;
    final String actionText;

    switch (status) {
      case 'valid':
        statusColor = Colors.green.shade700;
        statusIcon = Icons.check_circle;
        actionText = 'View';
        break;
      case 'expiring':
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.warning_amber_rounded;
        actionText = 'Renew';
        break;
      case 'expired':
        statusColor = Colors.red.shade700;
        statusIcon = Icons.error;
        actionText = 'Update';
        break;
      default: // missing
        statusColor = Colors.grey.shade600;
        statusIcon = Icons.add_circle_outline;
        actionText = 'Upload';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Expires: ${doc['expiry']}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (status == 'missing' || status == 'expired') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditDocumentScreen(
                        documentType: doc['type'],
                        vehicleId: widget.vehicle['id'],
                      ),
                    ),
                  );
                }
                // TODO: Add logic for 'View' and 'Renew'
              },
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}
