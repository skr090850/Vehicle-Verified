import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_verified/owner_screens/dashboard/add_edit_document_screen.dart';
import 'package:vehicle_verified/themes/color.dart';

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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehicleInfoCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Vehicle Documents'),
                  const SizedBox(height: 12),
                  // --- START: FIREBASE DATA FETCH ---
                  _buildDocumentsList(),
                  // --- END: FIREBASE DATA FETCH ---
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildDeleteVehicleButton(), // Delete button
    );
  }

  /// Documents ki list fetch aur display karne ke liye naya widget
  Widget _buildDocumentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicle['id'])
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildMissingDocumentCard();
        }

        // Documents ki list ko build karein
        final documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final doc = documents[index];
            final docData = doc.data() as Map<String, dynamic>;
            return _buildDocumentCard(docData);
          },
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: AppColors.primaryColorOwner,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          '${widget.vehicle['make']} ${widget.vehicle['model']}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Image.asset(
          widget.vehicle['image'] ?? 'assets/image/car_sedan.png',
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.2),
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
            _buildInfoRow('Registration No.:', widget.vehicle['registrationNumber'] ?? 'N/A'),
            _buildInfoRow('Company name:', widget.vehicle['make']??'N/A'),
            _buildInfoRow('Model No.:', widget.vehicle['model']??'N/A'),
            _buildInfoRow('Engine No.:', widget.vehicle['engineNumber'] ?? 'N/A'),
            _buildInfoRow('Chassis No.:', widget.vehicle['chassisNumber'] ?? 'N/A'),
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

  /// Document card jo ab real data lega
  Widget _buildDocumentCard(Map<String, dynamic> docData) {
    final String docType = docData['documentType'] ?? 'Unknown Document';
    final Timestamp? expiryTimestamp = docData['expiryDate'];
    final DateTime? expiryDate = expiryTimestamp?.toDate();

    String status = 'valid';
    String expiryText = 'Lifetime';
    Color statusColor = Colors.green.shade700;
    IconData statusIcon = Icons.check_circle;
    String actionText = 'View';

    if (expiryDate != null) {
      expiryText = DateFormat('dd MMM, yyyy').format(expiryDate);
      if (expiryDate.isBefore(DateTime.now())) {
        status = 'expired';
        statusColor = Colors.red.shade700;
        statusIcon = Icons.error;
        actionText = 'Update';
      } else if (expiryDate.isBefore(DateTime.now().add(const Duration(days: 30)))) {
        status = 'expiring';
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.warning_amber_rounded;
        actionText = 'Renew';
      }
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
                  Text(docType, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Expires: $expiryText',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (status == 'expired') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditDocumentScreen(
                        documentType: docType,
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

  /// Jab koi document na ho to yeh card dikhega
  Widget _buildMissingDocumentCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.folder_off_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'No Documents Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload documents for this vehicle to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload First Document'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditDocumentScreen(
                      documentType: 'Registration Certificate (RC)', // Default type
                      vehicleId: widget.vehicle['id'],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Delete button
  Widget _buildDeleteVehicleButton() {
    return Padding(
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
    );
  }
}
