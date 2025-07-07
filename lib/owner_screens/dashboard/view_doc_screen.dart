import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:vehicle_verified/owner_screens/dashboard/view_document_image_screen.dart';
import 'package:vehicle_verified/owner_screens/dashboard/add_edit_document_screen.dart'; // Import for navigation

class ViewAllDocumentsScreen extends StatefulWidget {
  // This screen now requires a specific vehicle's data to be passed to it.
  final Map<String, dynamic> vehicle;

  const ViewAllDocumentsScreen({super.key, required this.vehicle});

  @override
  State<ViewAllDocumentsScreen> createState() => _ViewAllDocumentsScreenState();
}

class _ViewAllDocumentsScreenState extends State<ViewAllDocumentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Deletes a specific document from Firestore and its corresponding file from Storage.
  Future<void> _deleteDocument(String documentId, String? imageUrl) async {
    final String vehicleId = widget.vehicle['id'];

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: const Text('Are you sure you want to permanently delete this document?'),
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

    if (confirmDelete == true && mounted) {
      try {
        // Delete the document from Firestore
        await _firestore
            .collection('vehicles')
            .doc(vehicleId)
            .collection('documents')
            .doc(documentId)
            .delete();

        // If an image URL exists, delete the file from Firebase Storage
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleData = widget.vehicle;
    final vehicleDetails = '${vehicleData['make'] ?? ''} ${vehicleData['model'] ?? ''}';
    final registrationNumber = vehicleData['registrationNumber'] ?? 'N/A';

    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        title: Text(vehicleData['model'] ?? 'Documents', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header with vehicle image and details
          SliverToBoxAdapter(
            child: _buildVehicleHeader(vehicleData, vehicleDetails, registrationNumber),
          ),
          // StreamBuilder for the list of documents
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('vehicles')
                .doc(widget.vehicle['id'])
                .collection('documents')
                .snapshots(),
            builder: (context, documentSnapshot) {
              if (documentSnapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!documentSnapshot.hasData || documentSnapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              final documents = documentSnapshot.data!.docs;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final doc = documents[index];
                    final docData = doc.data() as Map<String, dynamic>;
                    return _buildDocumentCard(
                      docId: doc.id,
                      docData: docData,
                    );
                  },
                  childCount: documents.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the header section displaying vehicle information.
  Widget _buildVehicleHeader(Map<String, dynamic> vehicleData, String vehicleDetails, String registrationNumber) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColorOwner,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            vehicleData['image'] ?? 'assets/image/car_sedan.png',
            height: 60,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicleDetails,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                registrationNumber,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a card for a single document with its details and actions.
  Widget _buildDocumentCard({
    required String docId,
    required Map<String, dynamic> docData,
  }) {
    final String docType = docData['documentType'] ?? 'Unknown Document';
    final String? imageUrl = docData['documentURL'];
    final Timestamp? expiryTimestamp = docData['expiryDate'];
    String expiryText = 'Lifetime';
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    if (expiryTimestamp != null) {
      final expiryDate = expiryTimestamp.toDate();
      if (expiryDate.isBefore(DateTime.now())) {
        expiryText = 'Expired on ${DateFormat.yMMMd().format(expiryDate)}';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
      } else if (expiryDate.isBefore(DateTime.now().add(const Duration(days: 30)))) {
        final daysLeft = expiryDate.difference(DateTime.now()).inDays;
        expiryText = 'Expires in $daysLeft days';
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber_rounded;
      } else {
        expiryText = 'Expires on ${DateFormat.yMMMd().format(expiryDate)}';
      }
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(docType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(expiryText, style: TextStyle(color: Colors.grey.shade600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined, color: AppColors.primaryColorOwner),
              tooltip: 'View Document',
              onPressed: () {
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewDocumentImageScreen(
                        imageUrl: imageUrl,
                        docType: docType,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document image not available.')),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
              tooltip: 'Delete Document',
              onPressed: () => _deleteDocument(docId, imageUrl),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the UI shown when no documents are available for the vehicle.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Documents Found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload documents for this vehicle to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text('Upload First Document', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditDocumentScreen(
                      documentType: 'Registration Certificate (RC)',
                      vehicleId: widget.vehicle['id'],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColorOwner,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
