import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';

class ViewAllDocumentsScreen extends StatefulWidget {
  const ViewAllDocumentsScreen({super.key});

  @override
  State<ViewAllDocumentsScreen> createState() => _ViewAllDocumentsScreenState();
}

class _ViewAllDocumentsScreenState extends State<ViewAllDocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- MOCK DATA ---
  // In a real app, this data would be fetched from Firestore and categorized.
  final List<Map<String, String>> _validDocuments = [
    {
      "type": "Registration Certificate (RC)",
      "vehicle": "Honda Activa - DL01AB1234",
      "expiry": "Lifetime",
      "status": "valid",
    },
    {
      "type": "Insurance Policy",
      "vehicle": "Maruti Swift - BR01CD5678",
      "expiry": "Expires on 15 Oct 2025",
      "status": "valid",
    },
  ];

  final List<Map<String, String>> _expiringSoonDocuments = [
    {
      "type": "Insurance Policy",
      "vehicle": "Honda Activa - DL01AB1234",
      "expiry": "Expires in 15 days",
      "status": "expiring",
    },
    {
      "type": "Pollution Certificate (PUC)",
      "vehicle": "Maruti Swift - BR01CD5678",
      "expiry": "Expires in 28 days",
      "status": "expiring",
    }
  ];

  final List<Map<String, String>> _expiredDocuments = [
    {
      "type": "Pollution Certificate (PUC)",
      "vehicle": "Honda Activa - DL01AB1234",
      "expiry": "Expired on 10 Jan 2024",
      "status": "expired",
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        title: const Text('All Documents', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Valid'),
            Tab(text: 'Expiring Soon'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocumentList(_validDocuments),
          _buildDocumentList(_expiringSoonDocuments),
          _buildDocumentList(_expiredDocuments),
        ],
      ),
    );
  }

  /// Builds a list view for a given list of documents.
  Widget _buildDocumentList(List<Map<String, String>> documents) {
    if (documents.isEmpty) {
      return const Center(
        child: Text(
          'No documents in this category.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _buildDocumentCard(
          type: doc['type']!,
          vehicle: doc['vehicle']!,
          expiry: doc['expiry']!,
          status: doc['status']!,
        );
      },
    );
  }

  /// Builds a card for a single document.
  Widget _buildDocumentCard({
    required String type,
    required String vehicle,
    required String expiry,
    required String status,
  }) {
    final Color statusColor;
    final IconData statusIcon;

    switch (status) {
      case 'expiring':
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'expired':
        statusColor = Colors.red.shade700;
        statusIcon = Icons.error_outline;
        break;
      default: // 'valid'
        statusColor = Colors.green.shade700;
        statusIcon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(statusIcon, color: Colors.white),
        ),
        title: Text(
          type,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '$vehicle\n$expiry',
          style: TextStyle(color: Colors.grey.shade600, height: 1.4),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
        isThreeLine: true,
        onTap: () {
          // TODO: Navigate to the specific document's detail/edit screen
        },
      ),
    );
  }
}
