import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Data model for a single document's status
class DocumentStatus {
  final String name;
  final String status;
  final String expiry;

  DocumentStatus({required this.name, required this.status, required this.expiry});
}

class ScannedResultScreen extends StatefulWidget {
  final String vehicleId;
  const ScannedResultScreen({super.key, required this.vehicleId});

  @override
  State<ScannedResultScreen> createState() => _ScannedResultScreenState();
}

class _ScannedResultScreenState extends State<ScannedResultScreen> {
  late Future<Map<String, dynamic>> _scannedDataFuture;

  @override
  void initState() {
    super.initState();
    _scannedDataFuture = _fetchVehicleData();
  }

  /// Fetches all vehicle, owner, and document data from Firestore.
  Future<Map<String, dynamic>> _fetchVehicleData() async {
    try {
      // 1. Fetch vehicle data
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (!vehicleDoc.exists) {
        throw Exception('Vehicle not found.');
      }
      final vehicleData = vehicleDoc.data() as Map<String, dynamic>;

      // 2. Fetch owner data using ownerID from vehicle data
      final ownerId = vehicleData['ownerID'];
      String ownerName = 'Unknown Owner';
      if (ownerId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(ownerId)
            .get();
        if (userDoc.exists) {
          ownerName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown Owner';
        }
      }

      // 3. Fetch documents and determine their status
      final documentsSnapshot = await vehicleDoc.reference.collection('documents').get();
      final List<DocumentStatus> documents = [];
      bool allDocsVerified = documentsSnapshot.docs.isNotEmpty;

      for (var doc in documentsSnapshot.docs) {
        final docData = doc.data();
        final expiryTimestamp = docData['expiryDate'] as Timestamp?;
        String status = 'valid';
        String expiryText = 'Lifetime';

        if (expiryTimestamp != null) {
          final expiryDate = expiryTimestamp.toDate();
          expiryText = DateFormat.yMMMd().format(expiryDate);
          if (expiryDate.isBefore(DateTime.now())) {
            status = 'expired';
            allDocsVerified = false;
          }
        }
        documents.add(DocumentStatus(
          name: docData['documentType'] ?? 'Unknown Document',
          status: status,
          expiry: expiryText,
        ));
      }

      // 4. Combine all data into a single map
      return {
        'ownerName': ownerName,
        'vehicleModel': '${vehicleData['make'] ?? ''} ${vehicleData['model'] ?? ''}',
        'vehicleNumber': vehicleData['registrationNumber'] ?? 'N/A',
        'documents': documents,
        'isVerified': allDocsVerified,
      };
    } catch (e) {
      // Propagate error to FutureBuilder
      throw Exception('Failed to load vehicle data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _scannedDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Fetching Details...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('${snapshot.error}')),
          );
        }

        final scannedData = snapshot.data!;
        final List<DocumentStatus> documents = scannedData['documents'];
        final bool isVerified = scannedData['isVerified'];

        return Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            title: const Text('Verification Result', style: TextStyle(color: Colors.white)),
            backgroundColor: isVerified ? Colors.green.shade700 : Colors.red.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatusBanner(isVerified),
              const SizedBox(height: 24),
              _buildInfoCard(
                title: 'Owner & Vehicle Details',
                details: {
                  'Owner Name': scannedData['ownerName'],
                  'Vehicle Model': scannedData['vehicleModel'],
                  'Registration No.': scannedData['vehicleNumber'],
                },
              ),
              const SizedBox(height: 24),
              const Text('Document Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...documents.map((doc) => _buildDocumentStatusTile(doc)),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text('Scan Next Vehicle', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade700 : Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isVerified ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Text(
            isVerified ? 'VERIFIED' : 'NOT VERIFIED',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Map<String, String> details}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...details.entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(color: Colors.grey)),
                    Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentStatusTile(DocumentStatus doc) {
    final status = doc.status;
    final Color color;
    final IconData icon;

    switch (status) {
      case 'valid':
        color = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;
      case 'expired':
        color = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.orange.shade700;
        icon = Icons.warning_amber_rounded;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          'Expires on: ${doc.expiry}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          status.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
