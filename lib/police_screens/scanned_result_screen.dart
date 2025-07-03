import 'package:flutter/material.dart';

class ScannedResultScreen extends StatefulWidget {
  final String vehicleId;
  const ScannedResultScreen({super.key, required this.vehicleId});

  @override
  State<ScannedResultScreen> createState() => _ScannedResultScreenState();
}

class _ScannedResultScreenState extends State<ScannedResultScreen> {
  // --- MOCK DATA ---
  // In a real app, this data would be fetched from Firestore based on widget.vehicleId
  late Map<String, dynamic> _scannedData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicleData();
  }

  void _fetchVehicleData() {
    // Simulate a network call to fetch data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _scannedData = {
          'ownerName': 'Ravi Kumar',
          'vehicleModel': 'Bajaj Pulsar',
          'vehicleNumber': 'BR01Z1234',
          'documents': [
            {'name': 'Registration (RC)', 'status': 'valid', 'expiry': 'Lifetime'},
            {'name': 'Insurance', 'status': 'valid', 'expiry': '15-Aug-2025'},
            {'name': 'Pollution (PUC)', 'status': 'expired', 'expiry': '01-Jan-2024'},
          ]
        };
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fetching Details...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<Map<String, String>> documents = List<Map<String, String>>.from(_scannedData['documents'] ?? []);
    final bool isVerified = documents.every((doc) => doc['status'] == 'valid');

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
              'Owner Name': _scannedData['ownerName'] ?? 'N/A',
              'Vehicle Model': _scannedData['vehicleModel'] ?? 'N/A',
              'Registration No.': _scannedData['vehicleNumber'] ?? 'N/A',
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

  Widget _buildDocumentStatusTile(Map<String, String> doc) {
    final status = doc['status'] ?? 'unknown';
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
        title: Text(doc['name'] ?? 'Unknown Document', style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          'Expires on: ${doc['expiry']}',
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
